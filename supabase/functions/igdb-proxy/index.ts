import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const IGDB_BASE = "https://api.igdb.com/v4";
const TWITCH_TOKEN_URL = "https://id.twitch.tv/oauth2/token";

const DEFAULT_FIELDS =
  "name,cover.url,first_release_date,summary,screenshots.url,videos.video_id," +
  "total_rating,total_rating_count,platforms,genres";

function upgradeImageUrl(url: string): string {
  if (!url || typeof url !== "string") return url;
  return url
    .replace(/t_thumb/g, "t_720p")
    .replace(/t_cover_small/g, "t_720p")
    .replace(/t_cover_big/g, "t_720p")
    .replace(/t_screenshot_med/g, "t_720p");
}

function upgradeImageUrls<T>(obj: T): T {
  if (obj === null || obj === undefined) return obj;
  if (Array.isArray(obj)) return obj.map(upgradeImageUrls) as T;
  if (typeof obj === "object") {
    const result: Record<string, unknown> = {};
    for (const [k, v] of Object.entries(obj)) {
      result[k] = k === "url" || k.endsWith(".url")
        ? upgradeImageUrl(String(v))
        : upgradeImageUrls(v);
    }
    return result as T;
  }
  return obj;
}

function buildSearchQuery(
  search: string,
  filters?: { platformIds?: number[]; genreIds?: number[]; limit?: number },
): string {
  const parts: string[] = [];

  if (search) {
    parts.push(`search "${search.replace(/"/g, '\\"')}";`);
  }

  parts.push(`fields ${DEFAULT_FIELDS};`);

  const conditions: string[] = ["cover != null"];
  if (filters?.platformIds?.length) {
    conditions.push(`platforms = (${filters.platformIds.join(",")})`);
  }
  if (filters?.genreIds?.length) {
    conditions.push(`genres = (${filters.genreIds.join(",")})`);
  }
  parts.push(`where ${conditions.join(" & ")};`);

  if (!search) {
    parts.push("sort first_release_date asc;");
  }

  parts.push(`limit ${filters?.limit || 50};`);
  return parts.join("\n");
}

function buildListQuery(
  listType: "popular" | "upcoming" | "top" | "recent",
  search: string,
  filters?: { platformIds?: number[]; genreIds?: number[]; limit?: number },
): string {
  if (search) return buildSearchQuery(search, filters);

  const now = Math.floor(Date.now() / 1000);
  const limit = filters?.limit || 50;

  const conditions: string[] = ["cover != null"];
  if (filters?.platformIds?.length) {
    conditions.push(`platforms = (${filters.platformIds.join(",")})`);
  }
  if (filters?.genreIds?.length) {
    conditions.push(`genres = (${filters.genreIds.join(",")})`);
  }

  const year2020 = 1577836800;
  let sortClause: string;
  switch (listType) {
    case "popular":
      conditions.push("(first_release_date >= " + year2020 + " | first_release_date > " + now + ")");
      conditions.push("total_rating_count > 0");
      sortClause = "sort first_release_date desc;";
      break;
    case "upcoming":
      conditions.push(`first_release_date > ${now}`);
      sortClause = "sort first_release_date asc;";
      break;
    case "top":
      conditions.push("total_rating_count > 10");
      sortClause = "sort total_rating desc;";
      break;
    case "recent":
      conditions.push(`first_release_date < ${now}`);
      sortClause = "sort first_release_date desc;";
      break;
    default:
      sortClause = "sort first_release_date desc;";
  }

  return `fields ${DEFAULT_FIELDS};
where ${conditions.join(" & ")};
${sortClause}
limit ${limit};`;
}

async function getTwitchToken(clientId: string, clientSecret: string): Promise<string> {
  const params = new URLSearchParams({
    client_id: clientId,
    client_secret: clientSecret,
    grant_type: "client_credentials",
  });
  const res = await fetch(`${TWITCH_TOKEN_URL}?${params}`, { method: "POST" });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Twitch token failed: ${res.status} ${text}`);
  }
  const data = await res.json();
  return data.access_token;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
      },
    });
  }

  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { "Content-Type": "application/json" },
    });
  }

  const clientId = Deno.env.get("IGDB_CLIENT_ID");
  const clientSecret = Deno.env.get("IGDB_CLIENT_SECRET");
  if (!clientId || !clientSecret) {
    return new Response(
      JSON.stringify({ error: "IGDB credentials not configured" }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }

  try {
    const body = await req.json();
    const { endpoint, query, search, filters, listType } = body as {
      endpoint: string;
      query?: string;
      search?: string;
      filters?: { platformIds?: number[]; genreIds?: number[]; limit?: number };
      listType?: "popular" | "upcoming" | "top" | "recent";
    };

    if (!endpoint) {
      return new Response(
        JSON.stringify({ error: "endpoint is required" }),
        { status: 400, headers: { "Content-Type": "application/json" } },
      );
    }

    const igdbQuery = query ?? buildListQuery(listType ?? "popular", search ?? "", filters);

    const token = await getTwitchToken(clientId, clientSecret);
    const igdbRes = await fetch(`${IGDB_BASE}/${endpoint}`, {
      method: "POST",
      headers: {
        "Client-ID": clientId,
        Authorization: `Bearer ${token}`,
        "Content-Type": "text/plain",
      },
      body: igdbQuery,
    });

    if (!igdbRes.ok) {
      const text = await igdbRes.text();
      return new Response(
        JSON.stringify({ error: `IGDB error: ${igdbRes.status}`, details: text }),
        { status: igdbRes.status, headers: { "Content-Type": "application/json" } },
      );
    }

    const data = await igdbRes.json();
    const upgraded = upgradeImageUrls(data);

    return new Response(JSON.stringify(upgraded), {
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
    });
  } catch (e) {
    return new Response(
      JSON.stringify({ error: String(e) }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }
});

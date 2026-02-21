import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const IGDB_BASE = "https://api.igdb.com/v4";
const TWITCH_TOKEN_URL = "https://id.twitch.tv/oauth2/token";

interface Env {
  IGDB_CLIENT_ID: string;
  IGDB_CLIENT_SECRET: string;
}

function upgradeImageUrl(url: string): string {
  if (!url || typeof url !== "string") return url;
  return url
    .replace(/t_thumb/g, "t_cover_big")
    .replace(/t_cover_small/g, "t_cover_big")
    .replace(/t_screenshot_med/g, "t_cover_big");
}

function upgradeImageUrls<T>(obj: T): T {
  if (obj === null || obj === undefined) return obj;
  if (Array.isArray(obj)) {
    return obj.map(upgradeImageUrls) as T;
  }
  if (typeof obj === "object") {
    const result: Record<string, unknown> = {};
    for (const [k, v] of Object.entries(obj)) {
      if (k === "url" || k.endsWith(".url")) {
        result[k] = upgradeImageUrl(String(v));
      } else {
        result[k] = upgradeImageUrls(v);
      }
    }
    return result as T;
  }
  return obj;
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
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }

  try {
    const body = await req.json();
    const { endpoint, query } = body as { endpoint: string; query: string };
    if (!endpoint || !query) {
      return new Response(
        JSON.stringify({ error: "endpoint and query required" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    const token = await getTwitchToken(clientId, clientSecret);
    const url = `${IGDB_BASE}/${endpoint}`;
    const igdbRes = await fetch(url, {
      method: "POST",
      headers: {
        "Client-ID": clientId,
        Authorization: `Bearer ${token}`,
        "Content-Type": "text/plain",
      },
      body: query,
    });

    if (!igdbRes.ok) {
      const text = await igdbRes.text();
      return new Response(
        JSON.stringify({ error: `IGDB error: ${igdbRes.status}`, details: text }),
        { status: igdbRes.status, headers: { "Content-Type": "application/json" } }
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
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});

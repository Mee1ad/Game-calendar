-- user_favorites table for syncing favorites with Supabase (Anonymous Auth)
create table if not exists public.user_favorites (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  game_id bigint not null,
  created_at timestamptz default now(),
  unique(user_id, game_id)
);

alter table public.user_favorites enable row level security;

create policy "Users can manage own favorites"
  on public.user_favorites
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create index if not exists idx_user_favorites_user_id on public.user_favorites(user_id);

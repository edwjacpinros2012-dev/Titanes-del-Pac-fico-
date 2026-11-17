-- Foundation for cloud profiles, game progress and Google Play Games identity linking.
-- Apply only after reviewing the schema and policies in a dedicated Supabase project.
-- Do not expose service_role credentials in the Godot client.
-- Client-side writes are intentionally not granted: use authenticated server functions
-- that validate snapshots and platform identity before writing these tables.

create table if not exists public.player_cloud_saves (
  user_id uuid primary key references auth.users(id) on delete cascade,
  schema_version integer not null default 1 check (schema_version > 0),
  snapshot jsonb not null default '{}'::jsonb,
  revision bigint not null default 1 check (revision > 0),
  updated_at timestamptz not null default now(),
  constraint player_cloud_saves_snapshot_size
    check (pg_column_size(snapshot) <= 262144)
);

create table if not exists public.player_platform_links (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  provider text not null check (provider in ('google_play_games')),
  provider_player_id text not null unique,
  linked_at timestamptz not null default now(),
  last_verified_at timestamptz not null default now(),
  unique (user_id, provider)
);

create table if not exists public.player_region_progress (
  user_id uuid not null references auth.users(id) on delete cascade,
  region_id text not null check (region_id ~ '^[a-z0-9_]{2,48}$'),
  status text not null default 'locked' check (status in ('locked','available','contested','secured','lost')),
  reputation integer not null default 0 check (reputation >= 0),
  updated_at timestamptz not null default now(),
  primary key (user_id, region_id)
);

create index if not exists player_region_progress_region_idx
  on public.player_region_progress (region_id, status);

alter table public.player_cloud_saves enable row level security;
alter table public.player_platform_links enable row level security;
alter table public.player_region_progress enable row level security;

-- Authenticated users can read only their own cloud snapshot and linked platform identity.
create policy "cloud_saves_read_own"
  on public.player_cloud_saves for select to authenticated
  using (auth.uid() = user_id);

create policy "platform_links_read_own"
  on public.player_platform_links for select to authenticated
  using (auth.uid() = user_id);

create policy "region_progress_read_own"
  on public.player_region_progress for select to authenticated
  using (auth.uid() = user_id);

-- No direct INSERT/UPDATE/DELETE grants are issued to anon/authenticated.
-- Server-side functions must validate auth.uid(), verify Google Play Games tokens
-- against Google's backend, enforce progression rules, and write transactionally.
revoke all on public.player_cloud_saves from anon, authenticated;
revoke all on public.player_platform_links from anon, authenticated;
revoke all on public.player_region_progress from anon, authenticated;
grant select on public.player_cloud_saves to authenticated;
grant select on public.player_platform_links to authenticated;
grant select on public.player_region_progress to authenticated;

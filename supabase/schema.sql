-- TITANES DEL PACÍFICO — secure multiplayer foundation
-- Preparation only: this file has NOT been applied to a Supabase project.
-- Authoritative writes (economy, trades, mission rewards, alliances and chat)
-- must go through validated Edge Functions using server-side credentials.

create extension if not exists pgcrypto;

create table if not exists public.players (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null check (char_length(display_name) between 3 and 24),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.player_saves (
  user_id uuid primary key references auth.users(id) on delete cascade,
  save_data jsonb not null default '{}'::jsonb check (jsonb_typeof(save_data) = 'object'),
  revision bigint not null default 1 check (revision > 0),
  updated_at timestamptz not null default now()
);

create table if not exists public.player_inventory (
  user_id uuid primary key references auth.users(id) on delete cascade,
  inventory jsonb not null default '{}'::jsonb check (jsonb_typeof(inventory) = 'object'),
  updated_at timestamptz not null default now()
);

create table if not exists public.alliances (
  id uuid primary key default gen_random_uuid(),
  name text not null unique check (char_length(name) between 3 and 24),
  owner_id uuid not null references public.players(id) on delete restrict,
  created_at timestamptz not null default now()
);

create table if not exists public.alliance_members (
  alliance_id uuid not null references public.alliances(id) on delete cascade,
  user_id uuid not null references public.players(id) on delete cascade,
  role text not null default 'member' check (role in ('owner', 'officer', 'member')),
  joined_at timestamptz not null default now(),
  primary key (alliance_id, user_id)
);

create table if not exists public.global_messages (
  id uuid primary key default gen_random_uuid(),
  channel text not null default 'global' check (channel in ('global', 'alliance', 'operations')),
  user_id uuid not null references public.players(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 300),
  created_at timestamptz not null default now()
);

create index if not exists global_messages_channel_created_idx
  on public.global_messages (channel, created_at desc);

create table if not exists public.mission_results (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.players(id) on delete cascade,
  mission_id integer not null check (mission_id between 1 and 12),
  outcome text not null check (outcome in ('victory', 'defeat', 'retreat')),
  result_data jsonb not null default '{}'::jsonb check (jsonb_typeof(result_data) = 'object'),
  created_at timestamptz not null default now()
);

create index if not exists mission_results_user_created_idx
  on public.mission_results (user_id, created_at desc);

create table if not exists public.resource_transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.players(id) on delete cascade,
  transaction_type text not null check (transaction_type in ('trade', 'purchase', 'production', 'mission_reward', 'contract')),
  resource_delta jsonb not null check (jsonb_typeof(resource_delta) = 'object'),
  reference_id text,
  created_at timestamptz not null default now()
);

create index if not exists resource_transactions_user_created_idx
  on public.resource_transactions (user_id, created_at desc);

create table if not exists public.world_events (
  id uuid primary key default gen_random_uuid(),
  event_key text not null,
  status text not null default 'scheduled' check (status in ('scheduled', 'active', 'completed', 'cancelled')),
  payload jsonb not null default '{}'::jsonb check (jsonb_typeof(payload) = 'object'),
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  created_at timestamptz not null default now(),
  check (ends_at > starts_at)
);

create index if not exists world_events_active_window_idx
  on public.world_events (status, starts_at, ends_at);

alter table public.players enable row level security;
alter table public.player_saves enable row level security;
alter table public.player_inventory enable row level security;
alter table public.alliances enable row level security;
alter table public.alliance_members enable row level security;
alter table public.global_messages enable row level security;
alter table public.mission_results enable row level security;
alter table public.resource_transactions enable row level security;
alter table public.world_events enable row level security;

-- Profiles: a signed-in player can only read and edit their own profile.
create policy "players_read_own" on public.players
  for select to authenticated using ((select auth.uid()) = id);
create policy "players_insert_own" on public.players
  for insert to authenticated with check ((select auth.uid()) = id);
create policy "players_update_own" on public.players
  for update to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

-- Client reads are owner-scoped. Writes are reserved for trusted Edge Functions.
create policy "player_saves_read_own" on public.player_saves
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "player_inventory_read_own" on public.player_inventory
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "mission_results_read_own" on public.mission_results
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "resource_transactions_read_own" on public.resource_transactions
  for select to authenticated using ((select auth.uid()) = user_id);

-- Shared data is readable to authenticated users; mutations stay server-side.
create policy "alliances_read_authenticated" on public.alliances
  for select to authenticated using (true);
create policy "alliance_members_read_authenticated" on public.alliance_members
  for select to authenticated using (true);
create policy "global_messages_read_authenticated" on public.global_messages
  for select to authenticated using (true);
create policy "world_events_read_authenticated" on public.world_events
  for select to authenticated using (
    status = 'active' or status = 'scheduled'
  );

revoke all on public.players, public.player_saves, public.player_inventory,
  public.alliances, public.alliance_members, public.global_messages,
  public.mission_results, public.resource_transactions, public.world_events
  from anon;

grant select on public.players, public.player_saves, public.player_inventory,
  public.alliances, public.alliance_members, public.global_messages,
  public.mission_results, public.resource_transactions, public.world_events
  to authenticated;

grant insert, update on public.players to authenticated;

-- No client INSERT/UPDATE/DELETE grants are given for saves, inventory,
-- alliances, membership, chat, mission results, ledgers or world events.
-- Add Edge Functions with authentication, validation, rate limits and moderation
-- before enabling these systems in the live game.

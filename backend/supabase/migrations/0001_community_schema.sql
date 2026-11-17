-- Titanes del Pacífico: community schema v1
-- Apply only to a configured Supabase project after reviewing policies.
-- Never place service_role keys in the Godot client.

create extension if not exists pgcrypto;

create table if not exists public.player_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  handle text not null unique check (handle ~ '^[a-zA-Z0-9_]{3,20}$'),
  display_name text not null check (char_length(display_name) between 1 and 24),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  global_chat_enabled boolean not null default false
);

create table if not exists public.alliances (
  id uuid primary key default gen_random_uuid(),
  name text not null unique check (char_length(name) between 3 and 32),
  tag text not null unique check (tag ~ '^[A-Z0-9]{2,5}$'),
  description text not null default '' check (char_length(description) <= 240),
  leader_id uuid not null references auth.users(id) on delete restrict,
  is_public boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.alliance_members (
  alliance_id uuid not null references public.alliances(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'member' check (role in ('leader','officer','member')),
  status text not null default 'pending' check (status in ('pending','active')),
  joined_at timestamptz not null default now(),
  primary key (alliance_id, user_id)
);

create table if not exists public.alliance_invites (
  id uuid primary key default gen_random_uuid(),
  alliance_id uuid not null references public.alliances(id) on delete cascade,
  invited_user_id uuid not null references auth.users(id) on delete cascade,
  invited_by uuid not null references auth.users(id) on delete cascade,
  status text not null default 'pending' check (status in ('pending','accepted','declined','revoked')),
  created_at timestamptz not null default now(),
  unique (alliance_id, invited_user_id)
);

create table if not exists public.chat_messages (
  id bigint generated always as identity primary key,
  channel text not null check (channel in ('global','alliance','system')),
  alliance_id uuid references public.alliances(id) on delete cascade,
  sender_id uuid references auth.users(id) on delete set null,
  body text not null check (char_length(body) between 1 and 240),
  moderation_state text not null default 'pending' check (moderation_state in ('pending','visible','removed')),
  created_at timestamptz not null default now(),
  constraint chat_channel_alliance_consistency check (
    (channel = 'alliance' and alliance_id is not null) or
    (channel in ('global','system') and alliance_id is null)
  )
);

create table if not exists public.player_blocks (
  blocker_id uuid not null references auth.users(id) on delete cascade,
  blocked_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  check (blocker_id <> blocked_id)
);

create table if not exists public.player_reports (
  id bigint generated always as identity primary key,
  reporter_id uuid not null references auth.users(id) on delete cascade,
  reported_user_id uuid references auth.users(id) on delete set null,
  message_id bigint references public.chat_messages(id) on delete set null,
  category text not null check (category in ('harassment','spam','inappropriate_content','personal_information','cheating','other')),
  details text not null default '' check (char_length(details) <= 500),
  review_state text not null default 'open' check (review_state in ('open','reviewing','resolved','dismissed')),
  created_at timestamptz not null default now()
);

create table if not exists public.chat_restrictions (
  user_id uuid primary key references auth.users(id) on delete cascade,
  reason_code text not null,
  expires_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists chat_messages_global_idx
  on public.chat_messages (created_at desc)
  where channel = 'global' and moderation_state = 'visible';
create index if not exists chat_messages_alliance_idx
  on public.chat_messages (alliance_id, created_at desc)
  where channel = 'alliance' and moderation_state = 'visible';
create index if not exists alliance_members_user_idx
  on public.alliance_members (user_id, status);

alter table public.player_profiles enable row level security;
alter table public.alliances enable row level security;
alter table public.alliance_members enable row level security;
alter table public.alliance_invites enable row level security;
alter table public.chat_messages enable row level security;
alter table public.player_blocks enable row level security;
alter table public.player_reports enable row level security;
alter table public.chat_restrictions enable row level security;

-- Clients may edit only public display fields. The chat permission flag is server-managed.
revoke all on public.player_profiles from anon, authenticated;
grant select, insert on public.player_profiles to authenticated;
grant update (handle, display_name) on public.player_profiles to authenticated;

-- Public game identity only; do not add private account fields to this table.
create policy "profiles_read_authenticated"
  on public.player_profiles for select to authenticated using (true);
create policy "profiles_insert_self"
  on public.player_profiles for insert to authenticated
  with check (auth.uid() = user_id and global_chat_enabled = false);
create policy "profiles_update_self"
  on public.player_profiles for update to authenticated
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "alliances_read_public"
  on public.alliances for select to authenticated using (is_public = true);
-- Alliance creation and membership changes must use validated server functions.
create policy "members_read_self_or_shared"
  on public.alliance_members for select to authenticated
  using (
    user_id = auth.uid()
    or exists (
      select 1 from public.alliance_members mine
      where mine.alliance_id = alliance_members.alliance_id
        and mine.user_id = auth.uid() and mine.status = 'active'
    )
  );
create policy "invites_read_recipient_or_sender"
  on public.alliance_invites for select to authenticated
  using (invited_user_id = auth.uid() or invited_by = auth.uid());

create policy "read_moderated_chat"
  on public.chat_messages for select to authenticated
  using (
    moderation_state = 'visible'
    and (
      channel in ('global','system')
      or (channel = 'alliance' and exists (
        select 1 from public.alliance_members m
        where m.alliance_id = chat_messages.alliance_id
          and m.user_id = auth.uid() and m.status = 'active'
      ))
    )
  );

-- Chat access defaults OFF. A trusted moderation workflow must explicitly enable it.
create policy "submit_chat_for_moderation"
  on public.chat_messages for insert to authenticated
  with check (
    sender_id = auth.uid()
    and moderation_state = 'pending'
    and exists (
      select 1 from public.player_profiles p
      where p.user_id = auth.uid() and p.global_chat_enabled = true
    )
    and not exists (
      select 1 from public.chat_restrictions r
      where r.user_id = auth.uid()
        and (r.expires_at is null or r.expires_at > now())
    )
    and (
      channel = 'global'
      or (channel = 'alliance' and exists (
        select 1 from public.alliance_members m
        where m.alliance_id = chat_messages.alliance_id
          and m.user_id = auth.uid() and m.status = 'active'
      ))
    )
  );

create policy "blocks_read_own"
  on public.player_blocks for select to authenticated using (blocker_id = auth.uid());
create policy "blocks_add_own"
  on public.player_blocks for insert to authenticated with check (blocker_id = auth.uid());
create policy "blocks_remove_own"
  on public.player_blocks for delete to authenticated using (blocker_id = auth.uid());

create policy "reports_submit_own"
  on public.player_reports for insert to authenticated with check (reporter_id = auth.uid());
create policy "reports_read_own"
  on public.player_reports for select to authenticated using (reporter_id = auth.uid());

-- Intentionally no client policies for chat_restrictions.
-- Production follow-up: server-only RPC/Edge Functions for create/join/leave alliance,
-- invite review, moderation, report review, rate limits, and authoritative game rewards.

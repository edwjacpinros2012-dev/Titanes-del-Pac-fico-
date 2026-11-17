-- Server-validated alliance lifecycle functions.
-- Apply after 0001_community_schema.sql.

create or replace function public.create_alliance(p_name text, p_tag text, p_description text default '')
returns uuid
language plpgsql
security definer
set search_path = public, auth, pg_temp
as $$
declare
  v_user uuid := auth.uid();
  v_alliance uuid;
begin
  if v_user is null then raise exception 'authentication_required'; end if;
  if char_length(trim(p_name)) not between 3 and 32 then raise exception 'invalid_name'; end if;
  if p_tag !~ '^[A-Z0-9]{2,5}$' then raise exception 'invalid_tag'; end if;
  if exists (select 1 from public.alliance_members where user_id = v_user and status = 'active') then
    raise exception 'already_in_alliance';
  end if;
  insert into public.alliances(name, tag, description, leader_id)
  values (trim(p_name), p_tag, left(coalesce(p_description,''),240), v_user)
  returning id into v_alliance;
  insert into public.alliance_members(alliance_id,user_id,role,status)
  values (v_alliance,v_user,'leader','active');
  return v_alliance;
end;
$$;

create or replace function public.request_join_alliance(p_alliance_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public, auth, pg_temp
as $$
declare v_user uuid := auth.uid();
begin
  if v_user is null then raise exception 'authentication_required'; end if;
  if exists (select 1 from public.alliance_members where user_id=v_user and status='active') then
    raise exception 'already_in_alliance';
  end if;
  if not exists (select 1 from public.alliances where id=p_alliance_id and is_public=true) then
    raise exception 'alliance_not_found_or_private';
  end if;
  insert into public.alliance_members(alliance_id,user_id,role,status)
  values(p_alliance_id,v_user,'member','pending')
  on conflict(alliance_id,user_id) do update set status='pending';
  return true;
end;
$$;

create or replace function public.review_alliance_request(p_alliance_id uuid, p_user_id uuid, p_approve boolean)
returns boolean
language plpgsql
security definer
set search_path = public, auth, pg_temp
as $$
begin
  if not exists (
    select 1 from public.alliance_members
    where alliance_id=p_alliance_id and user_id=auth.uid()
      and role in ('leader','officer') and status='active'
  ) then raise exception 'not_authorized'; end if;
  if p_approve then
    update public.alliance_members set status='active'
    where alliance_id=p_alliance_id and user_id=p_user_id and status='pending';
  else
    delete from public.alliance_members
    where alliance_id=p_alliance_id and user_id=p_user_id and status='pending';
  end if;
  return found;
end;
$$;

create or replace function public.leave_alliance(p_alliance_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public, auth, pg_temp
as $$
begin
  delete from public.alliance_members
  where alliance_id=p_alliance_id and user_id=auth.uid() and role <> 'leader';
  if not found then raise exception 'leader_must_transfer_or_disband'; end if;
  return true;
end;
$$;

revoke all on function public.create_alliance(text,text,text) from public;
revoke all on function public.request_join_alliance(uuid) from public;
revoke all on function public.review_alliance_request(uuid,uuid,boolean) from public;
revoke all on function public.leave_alliance(uuid) from public;
grant execute on function public.create_alliance(text,text,text) to authenticated;
grant execute on function public.request_join_alliance(uuid) to authenticated;
grant execute on function public.review_alliance_request(uuid,uuid,boolean) to authenticated;
grant execute on function public.leave_alliance(uuid) to authenticated;

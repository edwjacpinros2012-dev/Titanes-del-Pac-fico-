-- Moderator-only controls. Moderator status comes from trusted app_metadata JWT claims.
create or replace function public.moderate_chat_message(p_message_id bigint, p_visible boolean)
returns boolean language plpgsql security definer
set search_path = public, auth, pg_temp
as $$
begin
  if coalesce(auth.jwt()->'app_metadata'->>'role','') not in ('moderator','admin') then
    raise exception 'moderator_required';
  end if;
  update public.chat_messages
  set moderation_state = case when p_visible then 'visible' else 'removed' end
  where id = p_message_id and moderation_state = 'pending';
  return found;
end;
$$;

create or replace function public.set_player_chat_permission(p_user_id uuid, p_enabled boolean)
returns boolean language plpgsql security definer
set search_path = public, auth, pg_temp
as $$
begin
  if coalesce(auth.jwt()->'app_metadata'->>'role','') not in ('moderator','admin') then
    raise exception 'moderator_required';
  end if;
  update public.player_profiles set global_chat_enabled = p_enabled, updated_at = now()
  where user_id = p_user_id;
  return found;
end;
$$;

revoke all on function public.moderate_chat_message(bigint,boolean) from public;
revoke all on function public.set_player_chat_permission(uuid,boolean) from public;
grant execute on function public.moderate_chat_message(bigint,boolean) to authenticated;
grant execute on function public.set_player_chat_permission(uuid,boolean) to authenticated;

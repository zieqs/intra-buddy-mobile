-- Broadcasts live only in broadcast_messages. The mobile inbox reads
-- notifications, so fan out one per-student copy when a broadcast targets
-- students, and keep those copies in sync.

-- 1. Image support on the per-student copies.
alter table public.notifications
  add column if not exists image_paths text[] not null default '{}';

-- 2. One copy per student per broadcast. NULLs (personal notifications) are
--    distinct in Postgres unique indexes, so personal rows are unaffected.
create unique index if not exists notifications_broadcast_recipient_uidx
  on public.notifications (broadcast_id, recipient_id);

-- 3. Fan out on send.
create or replace function public.fan_out_broadcast()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.target_roles is null
     or not (new.target_roles && array['students_all', 'student_all', 'students']::text[]) then
    return new;
  end if;

  insert into public.notifications
    (recipient_id, title, body, type, is_read, created_at, broadcast_id, image_paths)
  select
    u.id,
    new.title,
    new.body,
    'broadcast',
    false,
    coalesce(new.sent_at, now()),
    new.id,
    coalesce(new.image_paths, '{}')
  from public.users u
  where u.role = 'student'
  on conflict (broadcast_id, recipient_id) do nothing;

  return new;
end;
$$;

drop trigger if exists broadcast_fan_out on public.broadcast_messages;
create trigger broadcast_fan_out
  after insert on public.broadcast_messages
  for each row execute function public.fan_out_broadcast();

-- 4. Keep copies in sync when the coordinator edits a broadcast.
create or replace function public.sync_broadcast_notifications()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.notifications
  set title = new.title,
      body = new.body,
      image_paths = coalesce(new.image_paths, '{}')
  where broadcast_id = new.id;

  return new;
end;
$$;

drop trigger if exists broadcast_sync on public.broadcast_messages;
create trigger broadcast_sync
  after update of title, body, image_paths on public.broadcast_messages
  for each row execute function public.sync_broadcast_notifications();

-- 5. Remove copies when the broadcast is deleted.
create or replace function public.delete_broadcast_notifications()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  delete from public.notifications where broadcast_id = old.id;
  return old;
end;
$$;

drop trigger if exists broadcast_cleanup on public.broadcast_messages;
create trigger broadcast_cleanup
  before delete on public.broadcast_messages
  for each row execute function public.delete_broadcast_notifications();

-- 6. Backfill this semester's broadcasts (idempotent).
insert into public.notifications
  (recipient_id, title, body, type, is_read, created_at, broadcast_id, image_paths)
select
  u.id,
  b.title,
  b.body,
  'broadcast',
  false,
  coalesce(b.sent_at, now()),
  b.id,
  coalesce(b.image_paths, '{}')
from public.broadcast_messages b
cross join public.users u
where u.role = 'student'
  and b.target_roles && array['students_all', 'student_all', 'students']::text[]
  and b.sent_at >= (
    select start_date from public.semesters where is_active limit 1
  )
on conflict (broadcast_id, recipient_id) do nothing;

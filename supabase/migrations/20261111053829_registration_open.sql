-- Separate "session currently running" (is_active) from "new signups join this
-- session" (registration_open). Coordinators open registration on the next
-- intake before briefing its students, while the current session is still
-- running.
--
-- Applied to the shared project as migration 20261111053829.
alter table public.semesters
  add column if not exists registration_open boolean not null default false;

-- At most one session can accept new signups at a time, so the trigger and the
-- signup screen always have a single unambiguous answer.
create unique index if not exists semesters_one_open_registration
  on public.semesters (registration_open)
  where registration_open;

-- `student_semesters (student_id, semester_id)` is already unique in the shared
-- project; the ON CONFLICT below relies on that constraint.

-- New accounts join the open-for-registration session, not the running one.
-- Only students are enrolled; coordinator accounts are managed in the dashboard.
create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.users (id, email, full_name, role, student_id, phone_number)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    coalesce(new.raw_user_meta_data->>'role', 'student'),
    new.raw_user_meta_data->>'student_id',
    new.raw_user_meta_data->>'phone_number'
  )
  on conflict (id) do update
  set email = excluded.email,
      full_name = excluded.full_name,
      role = excluded.role,
      student_id = excluded.student_id,
      phone_number = excluded.phone_number,
      updated_at = now();

  if coalesce(new.raw_user_meta_data->>'role', 'student') = 'student' then
    insert into public.student_semesters (student_id, semester_id)
    select new.id, s.id
    from public.semesters s
    where s.registration_open
    order by s.start_date desc
    limit 1
    on conflict (student_id, semester_id) do nothing;
  end if;

  return new;
end;
$$;

-- Pre-auth lookup for the signup screen. Returns only the open session's
-- public details, so the app never needs anonymous read access to the table.
create or replace function public.get_open_semester()
returns table (id int, name text, start_date date, end_date date)
language sql
stable
security definer
set search_path = ''
as $$
  select s.id, s.name, s.start_date, s.end_date
  from public.semesters s
  where s.registration_open
  order by s.start_date desc
  limit 1;
$$;

revoke all on function public.get_open_semester() from public;
grant execute on function public.get_open_semester() to anon, authenticated;

-- Open the current session for registration. Move this to the next intake
-- before its briefing.
update public.semesters set registration_open = false where registration_open;
update public.semesters set registration_open = true where id = 1;

-- One-time reconciliation, if any accounts ever predate this change:
--   select u.id, u.email
--   from public.users u
--   where u.role = 'student'
--     and not exists (
--       select 1 from public.student_semesters ss where ss.student_id = u.id
--     );
-- Assign those students from the dashboard; do not guess their session.

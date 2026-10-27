-- Realtime postgres_changes filters on a non-primary-key column
-- (recipient_id) need the full old row for UPDATE/DELETE events to match.
-- INSERT events already work with the default replica identity.
alter table public.notifications replica identity full;

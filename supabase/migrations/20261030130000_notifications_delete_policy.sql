-- Students may delete their own notification copies (personal messages and
-- their per-student broadcast fan-out rows). Deleting a copy does not touch
-- the broadcast or anyone else's copy.
drop policy if exists notifications_delete_own on public.notifications;

create policy notifications_delete_own
  on public.notifications
  for delete
  to authenticated
  using (recipient_id = auth.uid());

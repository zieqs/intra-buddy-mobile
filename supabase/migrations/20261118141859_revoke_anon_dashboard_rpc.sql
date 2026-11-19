-- Remove the anonymous grant left over from Supabase's default privileges.
-- `revoke ... from public` in 20261118141803 does not remove an explicit
-- grant to the `anon` role, so it is revoked directly here.

revoke all on function public.get_student_dashboard(uuid) from anon;

# Database

The mobile app reads and writes through Supabase (Postgres + Auth + Storage).
This folder holds the local migration history for the project.

## Current status — read before running `supabase db push`

The repository migration chain does **not** match the project's applied
migration history. Do not run `supabase db push` against the linked project
until the chain is reconciled; it would try to re-apply migrations that have
already run and create duplicate history entries.

Two problems:

1. **Seven applied migrations have no file in this folder.**
2. **Seven files use a different timestamp** from the version recorded in
   `supabase_migrations.schema_migrations`.

The live project is the source of truth right now.

### Applied history (`supabase_migrations.schema_migrations`)

| Version | Name | In repo |
|---|---|---|
| 20260706030408 | add_chat_delete_policies | no |
| 20260706090323 | auto_enroll_active_semester | filename differs |
| 20260706093557 | drop_old_cohort_trigger | filename differs |
| 20260706093841 | drop_old_checklist_trigger | filename differs |
| 20261022132151 | coordinator_dashboard_summary | no |
| 20261027023346 | coordinator_student_management | no |
| 20261027085634 | notifications_realtime_replica_identity | filename differs |
| 20261029155835 | broadcast_image_paths | no |
| 20261029164436 | broadcast_fanout | filename differs |
| 20261029170055 | notifications_delete_policy | filename differs |
| 20261029171944 | notifications_archive | filename differs |
| 20261030050243 | super_coordinator_student_management | no |
| 20261030070225 | add_checklist_template_phase_due_date | no |
| 20261104090000 | checklist_phase_due_date | no |
| 20261111053829 | registration_open | yes |
| 20261118141803 | harden_definer_functions | yes |
| 20261118141859 | revoke_anon_dashboard_rpc | yes |

## Security changes already applied

**20261118141803 / 20261118141859** — `get_student_dashboard(uuid)`:

- was executable by `anon` and accepted any student id;
- now requires `auth.uid()` (the caller) to be that student or a coordinator;
- pins `search_path = ''`;
- `anon` no longer has `EXECUTE`; `authenticated` keeps it with the guard.

The signup trigger does not use `public.handle_new_user`; it calls
`private.handle_new_user`, which was already hardened (`search_path = ''`,
`ON CONFLICT`, registration-open enrollment). The public
`handle_new_user` and `handle_new_auth_user` functions are unused duplicates
(no triggers reference them) and can be dropped in a cleanup migration.

## Baseline a new environment (recommended)

Requires the Supabase CLI and the project's database password. The CLI may
also need Docker for `db dump`, depending on its version.

```bash
supabase login
supabase link --project-ref <project-ref>

# 1. Schema snapshot (public schema only)
supabase db dump --schema public -f supabase/baseline/0001_public_schema.sql

# 2. Seed data worth keeping (reference tables only)
supabase db dump --data-only \
  -t public.faqs -t public.faq_categories -t public.checklist_templates \
  -f supabase/baseline/0002_seed.sql
```

The `storage` schema is managed by Supabase — do not dump it wholesale.
Capture the app-owned objects separately:

```sql
-- Storage buckets
select id, name, public, file_size_limit, allowed_mime_types from storage.buckets;

-- RLS policies on storage.objects
select policyname, cmd, roles, qual, with_check
from pg_policies where schemaname = 'storage' order by policyname;
```

Recreate the buckets in the new project and paste the policies into
`0003_storage.sql`.

## Reconcile the migration chain

After the baseline exists, treat it as the new root and retire the old chain:

```bash
mkdir -p supabase/legacy_migrations
git mv supabase/migrations/2026*.sql supabase/legacy_migrations/

git mv supabase/baseline/0001_public_schema.sql \
  supabase/migrations/20261118000000_baseline.sql
```

Then record the baseline and the old versions as applied on **existing**
projects so the CLI stops treating them as pending:

```bash
supabase migration repair --status applied 20261118000000
supabase migration repair --status applied 20260706030408
# ... one per version in the table above
```

On a **new** project, apply only the baseline and the new migrations; the
historical versions are already contained in the baseline.

## Verification

```bash
# Security and performance advisories
# (Dashboard → Advisors, or via the MCP/API)

# RLS must be on for every table
select c.relname, c.relrowsecurity
from pg_class c join pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'public' and c.relkind = 'r'
order by 1;
```

### Known advisories (2026-11-18)

| Advisory | Detail | Action |
|---|---|---|
| `rls_enabled_no_policy` | `coordinator_student_assignments`, `student_management_audit` have RLS with no policies (deny-all) | Decide with the web dashboard: policies, or service-role only |
| `extension_in_public` | `vector` installed in `public` | Move to a dedicated schema when convenient |
| `anon_security_definer_function_executable` | Remaining entries are trigger functions (not callable through PostgREST), `get_open_semester` (needed before signup) and `is_coordinator` (no arguments) | No action; consider dropping the unused `handle_new_*` duplicates |
| `auth_leaked_password_protection` | HaveIBeenPwned check disabled | Enable in Authentication → Providers → Email |

-- Drop old trigger and function referencing renamed columns
-- checklist_templates.cohort_id was renamed to semester_id
-- student_semesters.cohort_id was renamed to semester_id
DROP TRIGGER IF EXISTS after_student_enrolls ON public.student_semesters;
DROP FUNCTION IF EXISTS create_student_checklists;

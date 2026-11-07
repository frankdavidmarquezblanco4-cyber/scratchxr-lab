-- ScratchXR Lab · Fase 11-D
-- Ejecutar en Supabase Dashboard > SQL Editor.
-- Los docentes se crean previamente como cuentas Auth por el administrador.
create table if not exists public.scratchxr_student_progress (
  id uuid primary key default gen_random_uuid(),
  teacher_id uuid not null references auth.users(id) on delete cascade,
  local_student_id text not null check (length(local_student_id) between 1 and 100),
  nickname text not null check (length(nickname) between 1 and 40),
  grade smallint not null check (grade between 3 and 11),
  xp integer not null default 0 check (xp >= 0 and xp <= 10000000),
  completed_mission_ids text[] not null default '{}',
  quiz_summary jsonb not null default '[]'::jsonb,
  game_ids text[] not null default '{}',
  updated_at timestamptz not null default now(),
  unique (teacher_id, local_student_id),
  constraint quiz_summary_is_array check (jsonb_typeof(quiz_summary) = 'array')
);

alter table public.scratchxr_student_progress enable row level security;
revoke all on table public.scratchxr_student_progress from anon, authenticated;
grant select, insert, update, delete on table public.scratchxr_student_progress to authenticated;

drop policy if exists "Teachers read own class progress" on public.scratchxr_student_progress;
drop policy if exists "Teachers add own class progress" on public.scratchxr_student_progress;
drop policy if exists "Teachers update own class progress" on public.scratchxr_student_progress;
drop policy if exists "Teachers delete own class progress" on public.scratchxr_student_progress;
create policy "Teachers read own class progress"
  on public.scratchxr_student_progress for select to authenticated
  using ((select auth.uid()) = teacher_id);
create policy "Teachers add own class progress"
  on public.scratchxr_student_progress for insert to authenticated
  with check ((select auth.uid()) = teacher_id);
create policy "Teachers update own class progress"
  on public.scratchxr_student_progress for update to authenticated
  using ((select auth.uid()) = teacher_id)
  with check ((select auth.uid()) = teacher_id);
create policy "Teachers delete own class progress"
  on public.scratchxr_student_progress for delete to authenticated
  using ((select auth.uid()) = teacher_id);

-- Defensa adicional: no exponer datos escolares a usuarios no autenticados.
comment on table public.scratchxr_student_progress is
  'Progress records owned by one authenticated teacher. Stores nickname, grade, XP, completed mission IDs, quiz best scores, and game IDs only.';

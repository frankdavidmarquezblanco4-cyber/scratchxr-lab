-- SCRATCHXR LAB · Fase 12: aprobación docente y sincronización en línea
-- Ejecutar en Supabase Dashboard > SQL Editor después de phase-11d.sql.
-- Nunca usar service_role en la app. La web solo usa la publishable/anon key.
-- Los estudiantes no crean cuentas Auth: usan un secreto aleatorio de alta entropía,
-- generado en su dispositivo y verificado mediante funciones RPC acotadas.

create schema if not exists extensions;
create extension if not exists pgcrypto with schema extensions;

create table if not exists public.scratchxr_classrooms (
  teacher_id uuid primary key references auth.users(id) on delete cascade,
  invite_code_hash text not null unique check (invite_code_hash ~ '^[0-9a-f]{64}$'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.scratchxr_access_requests (
  request_id uuid primary key,
  teacher_id uuid not null references auth.users(id) on delete cascade,
  nickname text not null check (length(btrim(nickname)) between 1 and 40),
  grade smallint not null check (grade between 3 and 11),
  request_secret_hash text not null check (request_secret_hash ~ '^[0-9a-f]{64}$'),
  status text not null default 'pending' check (status in ('pending','approved','denied','revoked','cancelled')),
  created_at timestamptz not null default now(),
  decided_at timestamptz,
  constraint request_nickname_has_no_control_chars check (nickname !~ '[[:cntrl:]]')
);
alter table public.scratchxr_access_requests drop constraint if exists scratchxr_access_requests_status_check;
alter table public.scratchxr_access_requests add constraint scratchxr_access_requests_status_check check (status in ('pending','approved','denied','revoked','cancelled'));

create index if not exists scratchxr_access_requests_teacher_recent
  on public.scratchxr_access_requests (teacher_id, created_at desc);
create index if not exists scratchxr_access_requests_teacher_pending
  on public.scratchxr_access_requests (teacher_id, status, created_at desc);

-- Tabla mínima publicada por Realtime para avisar que hay un cambio.
-- No contiene apodo, grado, secretos ni progreso. El docente obtiene los detalles
-- con scratchxr_teacher_list_access_requests(), que comprueba auth.uid().
create table if not exists public.scratchxr_access_events (
  id uuid primary key default gen_random_uuid(),
  teacher_id uuid not null references auth.users(id) on delete cascade,
  request_id uuid not null,
  event_kind text not null default 'request_created' check (event_kind in ('request_created')),
  created_at timestamptz not null default now()
);
create index if not exists scratchxr_access_events_teacher_recent
  on public.scratchxr_access_events (teacher_id, created_at desc);

create table if not exists public.scratchxr_live_progress (
  request_id uuid primary key references public.scratchxr_access_requests(request_id) on delete cascade,
  teacher_id uuid not null references auth.users(id) on delete cascade,
  nickname text not null check (length(btrim(nickname)) between 1 and 40),
  grade smallint not null check (grade between 3 and 11),
  xp integer not null default 0 check (xp between 0 and 10000000),
  completed_mission_ids text[] not null default '{}',
  quiz_summary jsonb not null default '[]'::jsonb check (jsonb_typeof(quiz_summary) = 'array'),
  game_ids text[] not null default '{}',
  activity_history jsonb not null default '[]'::jsonb check (jsonb_typeof(activity_history) = 'array'),
  updated_at timestamptz not null default now()
);
create index if not exists scratchxr_live_progress_teacher_grade
  on public.scratchxr_live_progress (teacher_id, grade, nickname);

alter table public.scratchxr_classrooms enable row level security;
alter table public.scratchxr_access_requests enable row level security;
alter table public.scratchxr_access_events enable row level security;
alter table public.scratchxr_live_progress enable row level security;

revoke all on table public.scratchxr_classrooms from public, anon, authenticated;
revoke all on table public.scratchxr_access_requests from public, anon, authenticated;
revoke all on table public.scratchxr_access_events from public, anon, authenticated;
revoke all on table public.scratchxr_live_progress from public, anon, authenticated;
grant select on table public.scratchxr_access_events to authenticated;
grant select on table public.scratchxr_live_progress to authenticated;

drop policy if exists "Teacher reads own access notifications" on public.scratchxr_access_events;
create policy "Teacher reads own access notifications"
  on public.scratchxr_access_events for select to authenticated
  using ((select auth.uid()) = teacher_id);
drop policy if exists "Teacher reads own live student progress" on public.scratchxr_live_progress;
create policy "Teacher reads own live student progress"
  on public.scratchxr_live_progress for select to authenticated
  using ((select auth.uid()) = teacher_id);

create or replace function public.scratchxr_emit_access_event()
returns trigger
language plpgsql
security definer
set search_path = public, extensions, pg_temp
as $$
begin
  delete from public.scratchxr_access_events where teacher_id = new.teacher_id and created_at < now() - interval '90 days';
  insert into public.scratchxr_access_events (teacher_id, request_id, event_kind)
  values (new.teacher_id, new.request_id, 'request_created');
  return new;
end;
$$;
revoke all on function public.scratchxr_emit_access_event() from public, anon, authenticated;
drop trigger if exists scratchxr_access_request_notification on public.scratchxr_access_requests;
create trigger scratchxr_access_request_notification
  after insert on public.scratchxr_access_requests
  for each row execute function public.scratchxr_emit_access_event();

create or replace function public.scratchxr_teacher_set_invite_code(p_invite_code text)
returns void
language plpgsql
security definer
set search_path = public, extensions, pg_temp
as $$
begin
  if auth.uid() is null or length(coalesce(p_invite_code,'')) <> 12
     or upper(p_invite_code) !~ '^[ABCDEFGHJKLMNPQRSTUVWXYZ23456789]{12}$' then
    raise exception 'No se pudo crear el enlace de aula.' using errcode = '22023';
  end if;
  insert into public.scratchxr_classrooms (teacher_id, invite_code_hash, updated_at)
  values (auth.uid(), encode(digest(convert_to(upper(p_invite_code), 'UTF8'), 'sha256'), 'hex'), now())
  on conflict (teacher_id) do update
    set invite_code_hash = excluded.invite_code_hash, updated_at = now();
end;
$$;
revoke all on function public.scratchxr_teacher_set_invite_code(text) from public, anon, authenticated;
grant execute on function public.scratchxr_teacher_set_invite_code(text) to authenticated;

create or replace function public.scratchxr_submit_access_request(
  p_request_id uuid, p_secret text, p_invite_code text, p_nickname text, p_grade smallint
)
returns uuid
language plpgsql
security definer
set search_path = public, extensions, pg_temp
as $$
declare
  v_teacher_id uuid;
  v_name text := regexp_replace(btrim(coalesce(p_nickname,'')), '[[:space:]]+', ' ', 'g');
  v_secret_hash text;
  v_pending integer;
begin
  if p_request_id is null or length(coalesce(p_secret,'')) < 40 or length(p_secret) > 160
     or length(v_name) < 1 or length(v_name) > 40 or v_name ~ '[[:cntrl:]]'
     or p_grade is null or p_grade not between 3 and 11
     or length(coalesce(p_invite_code,'')) <> 12
     or upper(p_invite_code) !~ '^[ABCDEFGHJKLMNPQRSTUVWXYZ23456789]{12}$' then
    raise exception 'Revisa el apodo, el grado y el enlace de aula.' using errcode = '22023';
  end if;
  v_secret_hash := encode(digest(convert_to(p_secret, 'UTF8'), 'sha256'), 'hex');
  select c.teacher_id into v_teacher_id
    from public.scratchxr_classrooms c
    where c.invite_code_hash = encode(digest(convert_to(upper(p_invite_code), 'UTF8'), 'sha256'), 'hex');
  if v_teacher_id is null then
    raise exception 'El enlace de aula no es válido o fue renovado.' using errcode = '22023';
  end if;
  select count(*) into v_pending from public.scratchxr_access_requests r
    where r.teacher_id = v_teacher_id and r.status = 'pending';
  if v_pending >= 300 then
    raise exception 'El aula alcanzó el límite de solicitudes pendientes. Avísale al docente.' using errcode = '54000';
  end if;
  insert into public.scratchxr_access_requests
    (request_id, teacher_id, nickname, grade, request_secret_hash, status)
  values (p_request_id, v_teacher_id, v_name, p_grade, v_secret_hash, 'pending');
  return p_request_id;
end;
$$;
revoke all on function public.scratchxr_submit_access_request(uuid,text,text,text,smallint) from public;
grant execute on function public.scratchxr_submit_access_request(uuid,text,text,text,smallint) to anon, authenticated;

create or replace function public.scratchxr_student_access_status(p_request_id uuid, p_secret text)
returns text
language plpgsql
security definer
set search_path = public, extensions, pg_temp
as $$
declare v_status text;
begin
  if p_request_id is null or length(coalesce(p_secret,'')) < 40 or length(p_secret) > 160 then
    return 'unknown';
  end if;
  select r.status into v_status
    from public.scratchxr_access_requests r
    where r.request_id = p_request_id
      and r.request_secret_hash = encode(digest(convert_to(p_secret, 'UTF8'), 'sha256'), 'hex');
  return coalesce(v_status, 'unknown');
end;
$$;
revoke all on function public.scratchxr_student_access_status(uuid,text) from public;
grant execute on function public.scratchxr_student_access_status(uuid,text) to anon, authenticated;

create or replace function public.scratchxr_teacher_list_access_requests()
returns table(request_id uuid, nickname text, grade smallint, status text, created_at timestamptz, decided_at timestamptz)
language sql
security definer
set search_path = public, extensions, pg_temp
as $$
  select r.request_id, r.nickname, r.grade, r.status, r.created_at, r.decided_at
  from public.scratchxr_access_requests r
  where auth.uid() is not null and r.teacher_id = auth.uid()
  order by r.created_at desc
  limit 500;
$$;
revoke all on function public.scratchxr_teacher_list_access_requests() from public, anon, authenticated;
grant execute on function public.scratchxr_teacher_list_access_requests() to authenticated;

create or replace function public.scratchxr_teacher_decide_access_request(p_request_id uuid, p_decision text)
returns boolean
language plpgsql
security definer
set search_path = public, extensions, pg_temp
as $$
declare v_count integer;
begin
  if auth.uid() is null or p_request_id is null or p_decision is null or p_decision not in ('approved','denied','revoked') then
    return false;
  end if;
  update public.scratchxr_access_requests r
    set status = p_decision, decided_at = now()
    where r.request_id = p_request_id and r.teacher_id = auth.uid()
      and ((r.status = 'pending' and p_decision in ('approved','denied'))
        or (r.status = 'approved' and p_decision = 'revoked'));
  get diagnostics v_count = row_count;
  return v_count = 1;
end;
$$;
revoke all on function public.scratchxr_teacher_decide_access_request(uuid,text) from public, anon, authenticated;
grant execute on function public.scratchxr_teacher_decide_access_request(uuid,text) to authenticated;

create or replace function public.scratchxr_student_cancel_access_request(p_request_id uuid, p_secret text)
returns boolean
language plpgsql
security definer
set search_path = public, extensions, pg_temp
as $$
declare v_count integer;
begin
  if p_request_id is null or length(coalesce(p_secret,'')) < 40 or length(p_secret) > 160 then
    return false;
  end if;
  update public.scratchxr_access_requests r
    set status = 'cancelled', decided_at = now()
    where r.request_id = p_request_id and r.status = 'pending'
      and r.request_secret_hash = encode(digest(convert_to(p_secret, 'UTF8'), 'sha256'), 'hex');
  get diagnostics v_count = row_count;
  return v_count = 1;
end;
$$;
revoke all on function public.scratchxr_student_cancel_access_request(uuid,text) from public;
grant execute on function public.scratchxr_student_cancel_access_request(uuid,text) to anon, authenticated;

create or replace function public.scratchxr_student_sync_progress(
  p_request_id uuid, p_secret text, p_nickname text, p_grade smallint, p_xp integer,
  p_missions text[], p_quizzes jsonb, p_games text[], p_activity_history jsonb
)
returns void
language plpgsql
security definer
set search_path = public, extensions, pg_temp
as $$
declare
  v_teacher_id uuid;
  v_name text := regexp_replace(btrim(coalesce(p_nickname,'')), '[[:space:]]+', ' ', 'g');
  v_secret_hash text;
begin
  if p_request_id is null or length(coalesce(p_secret,'')) < 40 or length(p_secret) > 160
     or length(v_name) < 1 or length(v_name) > 40 or v_name ~ '[[:cntrl:]]'
     or p_grade is null or p_grade not between 3 and 11
     or p_xp is null or p_xp not between 0 and 10000000
     or p_missions is null or cardinality(p_missions) > 500
     or exists (select 1 from unnest(p_missions) as x where x is null or length(x) < 1 or length(x) > 120 or x !~ '^[A-Za-z0-9_-]+$')
     or p_games is null or cardinality(p_games) > 500
     or exists (select 1 from unnest(p_games) as x where x is null or length(x) < 1 or length(x) > 120 or x !~ '^[A-Za-z0-9_-]+$')
     or p_quizzes is null or jsonb_typeof(p_quizzes) <> 'array' or (case when jsonb_typeof(p_quizzes) = 'array' then jsonb_array_length(p_quizzes) > 250 else true end)
     or octet_length(p_quizzes::text) > 40000
     or (case when jsonb_typeof(p_quizzes) = 'array' then exists (
       select 1 from jsonb_array_elements(p_quizzes) q
       where case when jsonb_typeof(q) <> 'object' then true else
         (select count(*) from jsonb_object_keys(q)) <> 2 or not (q ? 'id') or not (q ? 'best')
         or jsonb_typeof(q->'id') <> 'string' or (q->>'id') !~ '^[A-Za-z0-9_-]{1,120}$'
         or case when jsonb_typeof(q->'best') = 'number' then (q->>'best')::numeric not between 0 and 10000 else true end
       end
     ) else false end)
     or p_activity_history is null or jsonb_typeof(p_activity_history) <> 'array'
     or (case when jsonb_typeof(p_activity_history) = 'array' then jsonb_array_length(p_activity_history) > 1000 else true end) or octet_length(p_activity_history::text) > 150000
     or (case when jsonb_typeof(p_activity_history) = 'array' then exists (
       select 1 from jsonb_array_elements(p_activity_history) e
       where case when jsonb_typeof(e) <> 'object' then true else
         (select count(*) from jsonb_object_keys(e)) not between 3 and 5
         or (e - array['tipo','referencia','fecha','correctas','total']) <> '{}'::jsonb
         or not (e ? 'tipo') or not (e ? 'referencia') or not (e ? 'fecha')
         or jsonb_typeof(e->'tipo') <> 'string'
         or e->>'tipo' not in ('mission','quiz','game','daily','ascension')
         or jsonb_typeof(e->'referencia') <> 'string'
         or length(e->>'referencia') > 120 or (e->>'referencia') !~ '^[A-Za-z0-9_-]*$'
         or jsonb_typeof(e->'fecha') <> 'string'
         or (e->>'fecha') !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]{1,3})?Z$'
         or (e ? 'correctas' and case when jsonb_typeof(e->'correctas') = 'number' then (e->>'correctas')::numeric not between 0 and 100 else true end)
         or (e ? 'total' and case when jsonb_typeof(e->'total') = 'number' then (e->>'total')::numeric not between 0 and 100 else true end)
       end
     ) else false end) then
    raise exception 'El progreso enviado no cumple los límites permitidos.' using errcode = '22023';
  end if;
  v_secret_hash := encode(digest(convert_to(p_secret, 'UTF8'), 'sha256'), 'hex');
  update public.scratchxr_access_requests r
    set nickname = v_name, grade = p_grade
    where r.request_id = p_request_id and r.request_secret_hash = v_secret_hash and r.status = 'approved'
    returning r.teacher_id into v_teacher_id;
  if v_teacher_id is null then
    raise exception 'El acceso no está aprobado o ya fue revocado.' using errcode = '42501';
  end if;
  insert into public.scratchxr_live_progress
    (request_id, teacher_id, nickname, grade, xp, completed_mission_ids, quiz_summary, game_ids, activity_history, updated_at)
  values
    (p_request_id, v_teacher_id, v_name, p_grade, p_xp, p_missions, p_quizzes, p_games, p_activity_history, now())
  on conflict (request_id) do update set
    teacher_id = excluded.teacher_id, nickname = excluded.nickname, grade = excluded.grade,
    xp = excluded.xp, completed_mission_ids = excluded.completed_mission_ids,
    quiz_summary = excluded.quiz_summary, game_ids = excluded.game_ids,
    activity_history = excluded.activity_history, updated_at = now();
end;
$$;
revoke all on function public.scratchxr_student_sync_progress(uuid,text,text,smallint,integer,text[],jsonb,text[],jsonb) from public;
grant execute on function public.scratchxr_student_sync_progress(uuid,text,text,smallint,integer,text[],jsonb,text[],jsonb) to anon, authenticated;

comment on table public.scratchxr_access_requests is
  'Private student enrollment requests. Contains nickname, grade, state and a SHA-256 hash of a random per-request bearer secret; no student email or legal name.';
comment on table public.scratchxr_access_events is
  'Minimal teacher-scoped Realtime signal containing only teacher/request IDs and event type.';
comment on table public.scratchxr_live_progress is
  'Approved classroom progress: nickname, grade, XP, activity IDs and bounded dated activity history; readable only by the owning authenticated teacher.';

-- Realtime es solo notificación/actualización; RLS sigue siendo obligatorio.
do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    if not exists (select 1 from pg_publication_tables where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'scratchxr_access_events') then
      execute 'alter publication supabase_realtime add table public.scratchxr_access_events';
    end if;
    if not exists (select 1 from pg_publication_tables where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'scratchxr_live_progress') then
      execute 'alter publication supabase_realtime add table public.scratchxr_live_progress';
    end if;
  end if;
end;
$$;

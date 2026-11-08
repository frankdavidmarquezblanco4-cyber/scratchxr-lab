-- SCRATCHXR LAB · Fase 13: publicación segura de quizzes docentes
-- Ejecutar en Supabase SQL Editor después de phase-12-access-realtime.sql.
-- Sin datos de estudiantes: solo contenido de quizzes creado/publicado por docentes.
-- No se concede acceso directo a la tabla; todas las operaciones pasan por RPC.

create table if not exists public.scratchxr_classroom_quizzes (
  teacher_id uuid not null references public.scratchxr_classrooms(teacher_id) on delete cascade,
  quiz_id text not null check (quiz_id ~ '^teacher-quiz-[A-Za-z0-9_-]{1,100}$'),
  payload jsonb not null check (jsonb_typeof(payload) = 'object'),
  updated_at timestamptz not null default now(),
  primary key (teacher_id, quiz_id)
);

alter table public.scratchxr_classroom_quizzes enable row level security;
revoke all on table public.scratchxr_classroom_quizzes from public, anon, authenticated;

create or replace function public.scratchxr_teacher_publish_quizzes(p_quizzes jsonb)
returns integer
language plpgsql
security definer
set search_path = public, extensions, pg_temp
as $$
declare
  v_teacher_id uuid := auth.uid();
  v_quiz jsonb;
  v_id text;
  v_count integer := 0;
  v_question_count integer;
begin
  if v_teacher_id is null then
    raise exception 'Inicia sesión con una cuenta docente para publicar quizzes.' using errcode = '42501';
  end if;
  if p_quizzes is null or jsonb_typeof(p_quizzes) is distinct from 'array' then
    raise exception 'El contenido de quizzes debe ser una lista.' using errcode = '22023';
  end if;
  if jsonb_array_length(p_quizzes) > 100 or octet_length(p_quizzes::text) > 350000 then
    raise exception 'El paquete de quizzes supera el límite permitido.' using errcode = '54000';
  end if;
  perform 1 from public.scratchxr_classrooms c where c.teacher_id = v_teacher_id for update;
  if not found then
    raise exception 'Crea primero el enlace de aula en Ajustes docentes.' using errcode = '22023';
  end if;

  for v_quiz in select value from jsonb_array_elements(p_quizzes) loop
    if jsonb_typeof(v_quiz) is distinct from 'object'
       or not (v_quiz ?& array['id','titulo','grados','nivel','preguntas'])
       or jsonb_typeof(v_quiz->'id') is distinct from 'string'
       or jsonb_typeof(v_quiz->'titulo') is distinct from 'string'
       or jsonb_typeof(v_quiz->'grados') is distinct from 'array'
       or jsonb_typeof(v_quiz->'nivel') is distinct from 'number'
       or jsonb_typeof(v_quiz->'preguntas') is distinct from 'array' then
      raise exception 'Un quiz tiene una estructura incompleta.' using errcode = '22023';
    end if;
    v_id := v_quiz->>'id';
    v_question_count := jsonb_array_length(v_quiz->'preguntas');
    if v_id !~ '^teacher-quiz-[A-Za-z0-9_-]{1,100}$'
       or length(v_quiz->>'titulo') not between 1 and 100
       or (v_quiz->>'nivel') !~ '^[1-9]$'
       or jsonb_array_length(v_quiz->'grados') < 1
       or jsonb_array_length(v_quiz->'grados') > 9
       or v_question_count < 1 or v_question_count > 12
       or exists (
         select 1 from jsonb_array_elements(v_quiz->'grados') g(value)
         where jsonb_typeof(g.value) <> 'number' or (g.value #>> '{}') !~ '^(3|4|5|6|7|8|9|10|11)$'
       ) then
      raise exception 'Un quiz contiene título, nivel, grado o cantidad de preguntas fuera de los límites.' using errcode = '22023';
    end if;
    if exists (
      select 1 from jsonb_array_elements(v_quiz->'preguntas') q(value)
      where jsonb_typeof(q.value) is distinct from 'object'
         or not (q.value ?& array['enunciado','opciones','correcta','explicacion'])
         or jsonb_typeof(q.value->'enunciado') is distinct from 'string'
         or length(coalesce(q.value->>'enunciado','')) not between 1 and 1200
         or jsonb_typeof(q.value->'opciones') is distinct from 'array'
         or jsonb_array_length(case when jsonb_typeof(q.value->'opciones') = 'array' then q.value->'opciones' else '[]'::jsonb end) < 2
         or jsonb_array_length(case when jsonb_typeof(q.value->'opciones') = 'array' then q.value->'opciones' else '[]'::jsonb end) > 6
         or jsonb_typeof(q.value->'correcta') is distinct from 'number'
         or jsonb_typeof(q.value->'explicacion') is distinct from 'string'
    ) then
      raise exception 'Una pregunta del quiz no es válida.' using errcode = '22023';
    end if;
    insert into public.scratchxr_classroom_quizzes (teacher_id, quiz_id, payload, updated_at)
    values (v_teacher_id, v_id, v_quiz, now())
    on conflict (teacher_id, quiz_id) do update
      set payload = excluded.payload, updated_at = now();
    v_count := v_count + 1;
  end loop;

  -- Quitar quizzes propios borrados en el editor, sin tocar bancos base ni otros docentes.
  delete from public.scratchxr_classroom_quizzes q
    where q.teacher_id = v_teacher_id
      and not exists (
        select 1 from jsonb_array_elements(p_quizzes) incoming(value)
        where incoming.value->>'id' = q.quiz_id
      );
  return v_count;
end;
$$;
revoke all on function public.scratchxr_teacher_publish_quizzes(jsonb) from public, anon, authenticated;
grant execute on function public.scratchxr_teacher_publish_quizzes(jsonb) to authenticated;

create or replace function public.scratchxr_student_list_classroom_quizzes(p_request_id uuid, p_secret text)
returns setof jsonb
language plpgsql
security definer
set search_path = public, extensions, pg_temp
as $$
declare
  v_teacher_id uuid;
  v_grade smallint;
begin
  if p_request_id is null or length(coalesce(p_secret,'')) < 40 or length(p_secret) > 160 then
    return;
  end if;
  select r.teacher_id, r.grade into v_teacher_id, v_grade
  from public.scratchxr_access_requests r
  where r.request_id = p_request_id
    and r.request_secret_hash = encode(digest(convert_to(p_secret, 'UTF8'), 'sha256'), 'hex')
    and r.status = 'approved';
  if v_teacher_id is null or v_grade is null then
    return;
  end if;
  return query
    select q.payload
    from public.scratchxr_classroom_quizzes q
    where q.teacher_id = v_teacher_id
      and q.payload->'grados' @> jsonb_build_array(v_grade)
    order by q.payload->>'titulo';
end;
$$;
revoke all on function public.scratchxr_student_list_classroom_quizzes(uuid,text) from public;
grant execute on function public.scratchxr_student_list_classroom_quizzes(uuid,text) to anon, authenticated;

comment on table public.scratchxr_classroom_quizzes is
  'Quizzes docentes compartidos por aula. Acceso directo revocado; el RPC de lectura exige solicitud estudiantil aprobada y secreto bearer.';
comment on function public.scratchxr_teacher_publish_quizzes(jsonb) is
  'Publica/reemplaza solo el banco teacher-quiz del docente autenticado para su aula.';
comment on function public.scratchxr_student_list_classroom_quizzes(uuid,text) is
  'Devuelve quizzes compatibles con el grado solo si el secreto bearer corresponde a una solicitud aprobada.';

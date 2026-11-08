-- SCRATCHXR LAB · Fase 14: permisos de cámara individuales
-- Ejecutar en Supabase SQL Editor después de phase-12-access-realtime.sql.
-- Cada solicitud estudiantil aprobada tiene su propio permiso, denegado por defecto.
-- El permiso del docente NO sustituye consentimiento del estudiante ni el permiso del navegador.

alter table public.scratchxr_access_requests
  add column if not exists camera_allowed boolean not null default false;

create or replace function public.scratchxr_teacher_list_camera_permissions()
returns table(request_id uuid, nickname text, grade smallint, camera_allowed boolean)
language sql
security definer
set search_path = public, extensions, pg_temp
as $$
  select r.request_id, r.nickname, r.grade, r.camera_allowed
  from public.scratchxr_access_requests r
  where auth.uid() is not null
    and r.teacher_id = auth.uid()
    and r.status = 'approved'
  order by r.grade, r.nickname;
$$;
revoke all on function public.scratchxr_teacher_list_camera_permissions() from public, anon, authenticated;
grant execute on function public.scratchxr_teacher_list_camera_permissions() to authenticated;

create or replace function public.scratchxr_teacher_set_camera_permission(
  p_request_id uuid,
  p_allowed boolean
)
returns boolean
language plpgsql
security definer
set search_path = public, extensions, pg_temp
as $$
declare
  v_count integer;
begin
  if auth.uid() is null or p_request_id is null or p_allowed is null then
    return false;
  end if;
  update public.scratchxr_access_requests r
    set camera_allowed = p_allowed
    where r.request_id = p_request_id
      and r.teacher_id = auth.uid()
      and r.status = 'approved';
  get diagnostics v_count = row_count;
  return v_count = 1;
end;
$$;
revoke all on function public.scratchxr_teacher_set_camera_permission(uuid,boolean) from public, anon, authenticated;
grant execute on function public.scratchxr_teacher_set_camera_permission(uuid,boolean) to authenticated;

create or replace function public.scratchxr_student_camera_permission(
  p_request_id uuid,
  p_secret text
)
returns boolean
language plpgsql
security definer
set search_path = public, extensions, pg_temp
as $$
declare
  v_allowed boolean;
begin
  if p_request_id is null or length(coalesce(p_secret,'')) < 40 or length(p_secret) > 160 then
    return false;
  end if;
  select r.camera_allowed into v_allowed
    from public.scratchxr_access_requests r
    where r.request_id = p_request_id
      and r.request_secret_hash = encode(digest(convert_to(p_secret, 'UTF8'), 'sha256'), 'hex')
      and r.status = 'approved';
  return coalesce(v_allowed, false);
end;
$$;
revoke all on function public.scratchxr_student_camera_permission(uuid,text) from public;
grant execute on function public.scratchxr_student_camera_permission(uuid,text) to anon, authenticated;

comment on column public.scratchxr_access_requests.camera_allowed is
  'Permiso individual otorgado o retirado por el docente; false por defecto. No reemplaza consentimiento del estudiante ni permiso del navegador.';
comment on function public.scratchxr_teacher_list_camera_permissions() is
  'Lista solo estudiantes aprobados del docente autenticado y su autorización individual de cámara.';
comment on function public.scratchxr_teacher_set_camera_permission(uuid,boolean) is
  'Otorga o retira el permiso de cámara a una solicitud aprobada que pertenece al docente autenticado.';
comment on function public.scratchxr_student_camera_permission(uuid,text) is
  'Devuelve true solo si la solicitud aprobada coincide con su secreto aleatorio y el docente autorizó cámara.';

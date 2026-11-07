# ScratchXR Lab · fase 11-D: Supabase y privacidad

## Qué se sincroniza

La aplicación solo envía registros cuando el docente pulsa **Sincronizar perfiles locales ahora** y hay una sesión autenticada. Por perfil se guardan: apodo (máximo 40 caracteres), grado (3–11), XP, IDs de misiones completadas, IDs de juegos y, para cada quiz, su ID y mejor puntuación. No se envían deliberadamente nombre legal, correo del estudiante, fecha de nacimiento, escuela, ubicación, texto de respuestas, insignias, rachas, proyectos, PIN local, imágenes, audio ni vídeo. El correo de la cuenta docente lo gestiona Supabase Auth y no forma parte de la tabla de progreso.

Se recomienda sustituir nombres reales por apodos no identificables. Evita apodos que incluyan nombre completo, iniciales con apellido, correo, fecha de nacimiento o cualquier otro dato personal. La aplicación local todavía puede tener datos más amplios en el navegador; este módulo remoto exporta solo el subconjunto descrito.

## Crear y configurar el proyecto

1. Crea un proyecto en [Supabase Dashboard](https://supabase.com/dashboard). La organización conserva la contraseña de base de datos; no la copies al sitio.
2. En **SQL Editor**, ejecuta `supabase/phase-11d.sql`. El script crea `public.scratchxr_student_progress`, habilita RLS, revoca permisos de `anon` y otorga las operaciones necesarias solo a `authenticated`. Cada política limita filas a `teacher_id = auth.uid()`.
3. En **Authentication → Providers / Sign In**, desactiva los registros públicos si la configuración lo permite. Crea manualmente las cuentas docentes autorizadas y verifica sus direcciones. No habilites inicios anónimos para acceder a esta tabla. La cuenta docente debe ser una cuenta permanente.
4. En **Settings → API Keys**, copia el Project URL y la **publishable key** (`sb_publishable_…`) o la antigua **anon key**. En el panel docente del sitio, abre **Ajustes**, pega esos valores, pulsa **Configurar conexión** e inicia sesión con la cuenta docente. Nunca introduzcas `service_role` o `sb_secret_…` en un archivo web.
5. Comprueba que el dominio publicado está servido por HTTPS. Tras revisar los perfiles locales y confirmar que usan apodos, pulsa manualmente **Sincronizar perfiles locales ahora**. El panel solo muestra los registros accesibles bajo las políticas de la cuenta autenticada.
6. No dejes la sesión docente activa en equipos públicos o compartidos con estudiantes. Cierra sesión después de usarla. Habilita MFA para las cuentas docentes cuando esté disponible. Limita quién puede crear cuentas y revisa periódicamente Database → Policies y los hallazgos del Security Advisor.

La URL y la clave pública quedan en `localStorage` de ese navegador. La contraseña no se guarda en las preferencias de la interfaz. Supabase Auth conserva una sesión en el navegador; no uses el mismo navegador autenticado en una máquina abierta al alumnado. La clave pública no es un secreto: la protección depende de permisos SQL y políticas RLS. RLS restringe a cada cuenta docente a sus propios registros, pero no puede impedir que una persona que controla una sesión docente reutilice esa misma sesión.

## Recuperar el PIN docente y corregir un perfil local

En Ajustes, el PIN docente puede cambiarse ingresando un PIN nuevo de 4–12 dígitos y confirmándolo. El PIN local sigue guardado solo en el navegador; no se envía ni se conserva en Supabase.

Para recuperar el PIN por email, configura primero la URL del proyecto y la clave publicable de Supabase en ese mismo navegador, crea una cuenta Auth docente con correo verificado y habilita el proveedor de email. En **Authentication → URL Configuration**, agrega como Redirect URL el origen y la ruta publicada del sitio (por ejemplo, `https://tu-usuario.github.io/tu-repo/`). Si vas a usar dominio propio, agrega también ese origen. El acceso para recuperación usa un magic link de Supabase (`signInWithOtp` con `shouldCreateUser: false`): al abrirlo en el mismo navegador/dispositivo, la app verifica la cuenta y permite elegir un PIN local nuevo; nunca manda el PIN en el correo. Si se abre en otro navegador o dispositivo, allí solo se actualizará el almacenamiento local de esa copia del sitio.

Supabase debe poder enviar correo. Su remitente de prueba tiene límites bajos y es best-effort; configura SMTP propio para uso regular. Si no se configuró Supabase antes de olvidar el PIN, no hay recuperación remota disponible desde este HTML estático: debe recuperarlo el administrador local o reconfigurar el navegador. La cuenta Auth debe estar limitada a docentes; mantén deshabilitados los registros públicos si no son necesarios.

El estudiante puede editar su nombre/apodo y grado desde **Editar mi perfil**. La app modifica esos campos del perfil activo sin crear otro ID ni borrar puntos, quizzes, misiones o insignias. Los perfiles siguen siendo locales y no están protegidos por una identidad individual: en un dispositivo compartido, cualquier persona que pueda seleccionar un perfil puede editarlo.

## Identidad y sincronización entre equipos

Esta integración usa una sesión docente autenticada como propietaria del grupo. El docente debe iniciar sesión en el navegador desde el que va a sincronizar o consultar. No utiliza perfiles anónimos para los estudiantes, porque una cuenta Auth anónima no se puede recuperar tras borrar el almacenamiento del navegador y no representa por sí misma un grupo docente. Para un quiosco compartido con alumnado, no mantengas una sesión docente de Supabase abierta. Si se necesita envío automático desde dispositivos estudiantiles, hace falta diseñar y desplegar un backend o Edge Function con identidad de aula, enrolamiento y controles contra abuso; no se debe resolver poniendo la clave `service_role` en el HTML.

La sincronización es de subida y consulta: esta fase no sobrescribe los perfiles locales con resultados remotos ni sincroniza toda la base de datos a la app del estudiante. El identificador local se utiliza solo como clave de upsert junto con el propietario docente. No contiene el nombre del estudiante.

## RLS y datos de menores

La tabla no tiene política para el rol `anon`; todas las políticas se aplican a cuentas `authenticated` y comparan `auth.uid()` con `teacher_id`. La tabla no debe exponerse mediante vistas con `SECURITY DEFINER` ni políticas adicionales que permitan acceso público. No deshabilites RLS y no concedas permisos de lectura a `anon`. La aplicación usa una clave publicable/anon solo para identificar el proyecto. Una clave `service_role` omite RLS y permitiría acceso privilegiado; nunca debe publicarse en navegador, repositorio, URL o chat.

Minimiza también los datos de origen: pide autorización institucional y familiar cuando corresponda, informa del propósito, fija un periodo de conservación, elimina registros al terminar su necesidad y revisa las normas de privacidad aplicables en tu país. El producto no ofrece por sí solo cumplimiento legal ni certificación escolar. No subas contenidos sensibles de menores.

## Plan gratuito y mantenimiento

El nivel Free de Supabase incluye límites de uso y pausa proyectos inactivos; estos límites y la disponibilidad pueden cambiar. Revisa [precios y límites vigentes](https://supabase.com/pricing), configura alertas y conserva una exportación institucional autorizada. No asumas que “gratuito” significa disponibilidad, copias de seguridad o retención garantizadas.

## Modelo 3D del gato

El archivo `assets/models/scratch-cat.glb` procede del GLB adjuntado por el usuario. Se usa como modelo inicial del visor 3D y continúa siendo un archivo del mismo sitio para evitar depender de un enlace externo. Confirma que tienes derecho a publicarlo y añade aquí la atribución o licencia correspondiente antes de redistribuirlo. La marca y los gráficos oficiales de Scratch pertenecen a sus titulares; no implica que este proyecto esté afiliado ni respaldado por Scratch.

# SCRATCHXR LAB · Supabase, acceso docente y sincronización

## Qué ofrece la integración

La aplicación conserva dos caminos. La sincronización de **Fase 11-D** continúa disponible para importar o subir, manualmente desde el panel docente, perfiles locales existentes. La **Fase 12** añade el flujo en línea para nuevas solicitudes: el docente autenticado crea un enlace de aula; el estudiante solicita acceso usando un apodo y su grado; el docente ve la solicitud en tiempo real y permite, deniega o revoca el acceso. Después de aprobarse, el progreso del perfil se guarda localmente y se envía automáticamente a Supabase cuando hay conexión. El informe docente combina perfiles del dispositivo con perfiles aprobados en línea.

La notificación se muestra en el panel docente mientras la página está abierta y conectada. El docente puede pedir permiso al navegador para recibir una notificación del sistema; esto **no** es una notificación push y no funciona si el sitio está cerrado, suspendido o sin internet. Las solicitudes pendientes permanecen en Supabase para que el docente las encuentre al volver a abrir Ajustes.

## Configurar Supabase

1. Crea un proyecto en [Supabase Dashboard](https://supabase.com/dashboard). No copies la contraseña de base de datos al sitio.
2. En **SQL Editor**, ejecuta en este orden `supabase/phase-11d.sql` y luego `supabase/phase-12-access-realtime.sql`. La segunda migración crea códigos de aula, solicitudes privadas, eventos mínimos para Realtime y progreso en línea; revoca accesos directos de `anon` a solicitudes y concede lectura de progreso solo al docente propietario mediante RLS.
3. En **Authentication → Providers / Sign In**, desactiva los registros públicos si no son necesarios. Crea manualmente cuentas permanentes para docentes; no habilites usuarios anónimos como sustituto de una cuenta docente.
4. En **Settings → API Keys**, copia el Project URL y la **publishable key** (`sb_publishable_…`) o la antigua **anon key**. En SCRATCHXR LAB, entra como docente con el PIN, abre **Ajustes**, pega ambos valores, pulsa **Configurar conexión** e inicia sesión con la cuenta docente. Nunca uses `service_role` o `sb_secret_…` en el HTML, un enlace o el repositorio.
5. En Ajustes, pulsa **Crear o renovar enlace de aula** y comparte el enlace con el grupo previsto. El enlace lleva un código aleatorio de 12 caracteres y la clave publicable del proyecto; la clave publicable no es un secreto. Renovar el enlace invalida el código anterior. La persona que presenta el código todavía requiere aprobación docente.
6. Confirma en **Database → Publications** que `scratchxr_access_events` y `scratchxr_live_progress` pertenecen a `supabase_realtime`. El SQL intenta añadir ambas tablas a la publicación si existe; revisa el resultado en el Dashboard. No deshabilites RLS ni concedas lectura pública de las tablas.
7. Mantén Ajustes abierto para recibir solicitudes en vivo. Para avisos del sistema, pulsa **Activar notificaciones del navegador** y permite el permiso del sitio. Realtime avisa; el panel vuelve a consultar los detalles mediante RPC con comprobación del docente autenticado.

## Experiencia de acceso del estudiante

El estudiante abre el enlace del aula, escribe un **apodo no identificable**, elige grado y confirma qué datos se compartirán. Debe tener conexión para enviar la solicitud y recibir una decisión. Hasta que Supabase confirme que el docente aprobó, la interfaz normal permanece bloqueada. Puede cancelar una solicitud pendiente desde su dispositivo; el servidor verifica el secreto de esa solicitud antes de cambiar su estado.

El apodo, el grado y el progreso aprobado se vinculan a un identificador aleatorio de solicitud. El navegador genera un secreto aleatorio de alta entropía; la solicitud y la sincronización lo envían por HTTPS a funciones RPC y la base almacena su hash SHA-256, no el secreto en claro. El secreto de uso sí se guarda en `localStorage` para que esa instalación pueda consultar el estado y subir avances; `localStorage` no está cifrado. No uses esa misma sesión de estudiante o docente en un equipo público, y borra el almacenamiento si el equipo deja de pertenecer al estudiante. Al aprobarse, la aplicación vincula y conserva un único perfil local que coincida con el apodo y grado; XP, misiones, quizzes y logros no se reinician. Si el equipo contiene varios perfiles ambiguos con los mismos datos, no se mezclan automáticamente. Si el grado guardado era erróneo, conserva primero el grado anterior para vincular el perfil y después edítalo desde la app.

Si el sitio está sin conexión, no se pueden crear solicitudes nuevas, aprobarlas ni recibir revocaciones. Un estudiante que ya fue aprobado en ese dispositivo puede continuar usando los datos locales y la PWA; al reconectar, sus avances pendientes se sincronizan. La autorización guardada localmente no puede confirmar una revocación mientras el dispositivo permanezca desconectado.

## Datos guardados y privacidad

La fase 12 almacena en Supabase únicamente lo necesario para el aula: apodo (máximo 40 caracteres), grado (3–11), estado/fecha de la solicitud y hash de un secreto aleatorio; tras la aprobación, XP, IDs de misiones, IDs de juegos, mejor puntuación por quiz y hasta 1.000 eventos educativos fechados. No se envían deliberadamente nombre legal, email del estudiante, fecha de nacimiento, ubicación, escuela, texto de respuestas, PIN local, imagen, cámara, micrófono, audio ni vídeo. El correo docente solo pertenece a Supabase Auth.

No pidas apellidos, correo, fecha de nacimiento ni datos sensibles. Informa a la escuela y a las familias del propósito, solicita las autorizaciones institucionales/familiares que correspondan, limita el periodo de conservación y elimina datos cuando dejen de ser necesarios. El producto no certifica cumplimiento legal escolar.

## Seguridad y límites técnicos

- La clave publicable es visible por diseño. La seguridad depende de RLS y de RPCs con alcance limitado, no de ocultar la clave.
- El código de aula se conserva en la base como hash; el enlace compartido sí contiene el código. Trátalo como invitación privada y renuévalo si se reenvía fuera del grupo. El código permite **solicitar**, no autoaprobarse.
- El rol docente para operaciones remotas exige una sesión Auth docente y las funciones derivan al propietario desde `auth.uid()`. No confían en un `teacher_id` escrito por el navegador.
- El PIN local y la puerta visual no son autenticación fuerte. GitHub Pages es una aplicación estática y el código/contenido público puede ser inspeccionado o alterado por una persona técnica. La puerta evita el ingreso normal sin aprobación, y Supabase sí protege las filas remotas con permisos del servidor, pero no convierte los recursos estáticos o el progreso que ya está en un dispositivo en contenido secreto.
- Las descargas de avances y la plantilla de notas se generan desde el panel docente. La plantilla CSV está protegida por el control de rol de la interfaz y no contiene datos de estudiantes. Para registros remotos se requiere la sesión docente de Supabase. No dejes esa sesión Auth abierta en equipos compartidos; usa MFA para docentes si está disponible.
- Realtime avisa solo al docente propietario y transmite un evento mínimo (IDs, no apodo ni grado). La vista consulta los detalles mediante RPC/RLS. Realtime no reemplaza la autorización.
- En el modo en línea, las solicitudes, decisiones y progreso de los estudiantes aprobados se actualizan automáticamente. Las ediciones de lecciones/quizzes, las preferencias y otras personalizaciones que el docente cambia en el navegador **siguen siendo locales** en esta versión; no se afirma que se sincronicen a todos los dispositivos. La cámara y MediaPipe se procesan en el dispositivo.
- Para sistemas con acceso público más estricto, notificaciones aunque el docente cierre la página o sincronización de todo el contenido, hace falta desplegar infraestructura adicional (por ejemplo, notificaciones push/backend y sincronización del contenido). No pongas `service_role` en el navegador como atajo.

## Fase 11-D, PIN y perfiles locales

La tabla `scratchxr_student_progress` de Fase 11-D sirve para la sincronización manual voluntaria del dispositivo docente. Contiene apodo, grado, XP, IDs de misiones/juegos y resumen de quizzes. Las políticas permiten a cada cuenta docente leer y modificar solo sus filas. No se envían perfiles de estudiantes a esa tabla por el solo hecho de abrir el panel.

El PIN docente local puede cambiarse en Ajustes con confirmación. Para recuperarlo por correo, configura un proveedor Auth/email de Supabase y agrega el origen publicado en **Authentication → URL Configuration**; la app usa un magic link sin crear cuentas (`shouldCreateUser: false`) y nunca envía el PIN. Configura SMTP propio para uso regular; los correos de prueba de Supabase pueden tener límites.

Los estudiantes pueden editar apodo y grado sin perder XP, misiones, quizzes o logros. En un perfil aprobado en línea, los cambios se envían en la siguiente sincronización automática. En perfiles antiguos locales, la edición continúa en ese navegador.

## Modo PWA y disponibilidad

Los recursos del sitio y el modelo Scratch Cat se precargan para usarse sin conexión. Las funciones en la nube necesitan internet; las solicitudes nuevas y las aprobaciones no se procesan offline. El nivel gratuito de Supabase puede pausar proyectos inactivos y sus cuotas/disponibilidad pueden cambiar; consulta [precios y límites](https://supabase.com/pricing), alertas, retención y copias de seguridad.

## Modelo 3D del gato

`assets/models/scratch-cat.glb` es el GLB adjuntado por el usuario. Confirma que tienes derecho a redistribuirlo y añade atribución/licencia antes de redistribuirlo. Los nombres, marcas y gráficos oficiales de Scratch pertenecen a sus titulares; SCRATCHXR LAB no implica afiliación ni respaldo oficial.

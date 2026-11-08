# SCRATCHXR LAB

Plataforma educativa web para aprender programación por bloques creando, practicando y explorando modelos 3D, realidad aumentada (RA) y realidad virtual (RV). Está diseñada para estudiantes de **3.º a 11.º grado**. Funciona como una aplicación estática: no necesita servidor propio ni instalación.

## Qué incluye

### Para estudiantes

- **Misiones progresivas** organizadas por grado, con explicaciones, actividades y reflexión.
- **Teoría ampliada** por bandas de grado, con conceptos explicados, ejemplos paso a paso, errores frecuentes, glosario y reto guiado.
- **Retos**: quizzes, ordenar código y encontrar errores, con retroalimentación y progreso.
- **Laboratorio XR**: visor 3D, acceso a RA cuando el dispositivo lo admite, escena RV con A-Frame y Taller de bloques 3D con ratón, tacto, gestos de mano y controladores WebXR.
- **Logros y gamificación**: XP, insignias, racha diaria, reto diario, desafío de ascenso y tabla de líderes local.
- **Lectura en voz alta** del navegador y preferencias de accesibilidad.
- **Taller Scratch 3D**: paleta por grado, bloques conectables, intérprete educativo, receta de Scratch y proyectos locales guardados por perfil.
- Perfiles para los grados **3.º a 11.º**.

### Para docentes

- Panel docente diferenciado con navegación superior, vista previa por grado, edición de lecciones y quizzes, proyectos, gestión visible de acceso al curso, acceso directo del docente a la cámara (sujeto al permiso del navegador) y permisos individuales para estudiantes aprobados.
- Seguimiento de perfiles locales y aprobados en línea, informes por periodo, exportación CSV, impresión y plantilla de notas 1–10 desde el panel docente.
- Ajustes para cambiar el PIN, el modelo 3D predeterminado y la visibilidad de opciones de gamificación.

## Archivos del repositorio

La publicación desde la raíz (`/ (root)`) debe conservar todos los archivos y subcarpetas del proyecto. La estructura incluye:

```text
scratchxr-lab/
├── index.html
├── manifest.webmanifest
├── service-worker.js
├── PWA_OFFLINE.md
├── README.md
├── .nojekyll
├── assets/
│   ├── pwa/                  # iconos de instalación
│   ├── vendor/               # dependencias XR/MediaPipe y licencias
│   ├── audio/
│   └── models/
│       ├── README.md
│       └── scratch-cat.glb
└── supabase/                 # integración opcional
```

`mi-modelo.glb` es un ejemplo de nombre, no viene incluido. Puedes reemplazarlo por cualquier archivo `.glb` tuyo y usar su nombre exacto en Ajustes. El nombre distingue mayúsculas y minúsculas.

El HTML incluye su CSS, JavaScript y favicon SVG. La aplicación distribuye localmente **model-viewer 4.0.0**, **A-Frame 1.7.0** y **MediaPipe Tasks Vision 0.10.14**, con fuentes y modelos en `assets/vendor/`. El gato adjunto está en `assets/models/scratch-cat.glb`. La biblioteca remota de Supabase solo se carga si se configura la sincronización opcional mientras hay conexión.

## Acceso docente

En la pantalla inicial, selecciona **Entrar como docente** e introduce el PIN inicial **1234**. Para cambiarlo, abre **Ajustes** en el panel docente, escribe el PIN nuevo y guárdalo. El PIN es una barrera para evitar entradas accidentales, no un sistema de seguridad: al ser una aplicación sin servidor, no debe usarse para proteger información privada. El rol docente no permanece activo al recargar la página.

## Requisitos de 3D, RA, RV y cámara

- **3D:** navegador moderno con WebGL. Tras preparar la PWA online, el visor y el gato adjunto funcionan offline. Los GLB personalizados remotos requieren conexión hasta que se descarguen.
- **RA:** el sitio debe estar publicado mediante **HTTPS**. Se necesita un dispositivo compatible. En Android suele requerirse ARCore y Scene Viewer; en iPhone o iPad se usa Quick Look con Safari. La aplicación comprueba la capacidad de `model-viewer`; si no está disponible, conserva el modo 3D y no simula RA.
- **RV:** se necesita un navegador y dispositivo compatibles con WebXR; para una experiencia inmersiva, un visor de RV compatible. Si el navegador no admite RV, aún puedes usar 3D.
- **Cámara:** los estudiantes necesitan autorización individual del docente, su propio consentimiento y el permiso del navegador. El docente puede habilitar a una sola persona; la RA real o el control opcional con manos pueden solicitar el permiso nativo del navegador. El Taller 3D funciona también con ratón y pantalla táctil, sin cámara. El procesamiento de manos se realiza en el dispositivo; no se graba ni se sube vídeo. Para explorar un modelo local en 3D no se necesita permiso de cámara.
- El acceso real a RA/RV depende del dispositivo, navegador, permisos y compatibilidad de sus servicios nativos.

## Datos y limitaciones

Por defecto, los perfiles, XP, resultados, ajustes y proyectos del Taller 3D se guardan en el navegador. La integración opcional de Supabase ofrece solicitudes de acceso con aprobación docente, sincronización automática del progreso aprobado, quizzes docentes compartidos con estudiantes aprobados y una migración manual para perfiles anteriores; requiere una cuenta docente, las migraciones 11-D y 12–14, y conexión. El uso estudiantil de cámara requiere además permiso individual del docente, consentimiento del estudiante y permiso del navegador; no se graba ni se sube vídeo. La sincronización no incluye lecciones ni preferencias docentes. Revisa `SUPABASE_SETUP.md` antes de activarla. Borrar datos del navegador o cambiar de dispositivo puede eliminar perfiles locales y secretos de acceso guardados en ese dispositivo. El PIN docente local no sustituye autenticación de servidor.

La voz usa Web Speech API. Las voces disponibles dependen del navegador y del sistema operativo. Las solicitudes y decisiones de acceso, la autenticación docente y la sincronización en vivo requieren internet. Una sesión estudiantil ya aprobada en el dispositivo puede continuar offline y sincronizar después; una revocación no llega al dispositivo hasta reconectarse. Lecciones y preferencias editadas siguen siendo locales. El acceso nativo a RA/RV depende del dispositivo, navegador, permisos y servicios compatibles.

## Publicar en GitHub Pages desde la web de GitHub

1. Inicia sesión en [GitHub](https://github.com/). En la esquina superior derecha, pulsa **+** y elige **New repository**.
2. Escribe un nombre, por ejemplo `scratchxr-lab`. Para empezar con la configuración más sencilla, crea un repositorio **Public**. Si eliges uno privado, la disponibilidad de Pages puede depender del plan o de las políticas de tu organización.
3. Deja seleccionada la rama `main`. Puedes marcar **Add a README file** o no hacerlo; si ya se creó otro README, luego podrás reemplazarlo.
4. Pulsa **Create repository**.
5. En la pestaña **Code**, elige **Add file > Upload files** y sube todo el proyecto, no solo `index.html`: incluye `manifest.webmanifest`, `service-worker.js`, `PWA_OFFLINE.md`, `.nojekyll` y las carpetas completas `assets/` y `supabase/`, manteniendo su estructura. Si aparece un README inicial, puedes reemplazarlo.
6. Comprueba que `assets/models/README.md` se haya subido con el proyecto; si no, créalo desde **Add file > Create new file** usando esa ruta.
7. Si tienes un modelo, abre `assets/models/` y usa **Add file > Upload files** para subir, por ejemplo, `mi-modelo.glb`. Confirma que el nombre coincide exactamente con el que vas a escribir en Ajustes.
8. Confirma que `index.html`, `manifest.webmanifest`, `service-worker.js`, `README.md`, `.nojekyll` y `assets/` aparecen en la raíz del repositorio, no dentro de otra carpeta contenedora.
9. En el repositorio, abre **Settings > Pages**. En **Build and deployment**, selecciona **Deploy from a branch**. En **Branch**, elige `main`; en la carpeta, elige **/(root)**; luego pulsa **Save**.
10. Espera a que termine la implementación. Puedes revisar su estado en **Actions** o volver a **Settings > Pages**. Para un repositorio llamado `scratchxr-lab`, la dirección normalmente tendrá la forma `https://TU-USUARIO.github.io/scratchxr-lab/`. Sustituye `TU-USUARIO` por tu nombre de usuario. La primera publicación puede tardar unos minutos.

GitHub mantiene una [guía oficial de inicio de Pages](https://docs.github.com/en/pages/quickstart) y la [configuración de publicación desde una rama](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site). Los sitios Pages publicados son accesibles por Internet; no subas datos privados de estudiantes al repositorio.

## Actualizar el sitio

1. Abre el repositorio y selecciona el archivo que quieres actualizar.
2. Para editar texto, pulsa el icono del lápiz, cambia el contenido y pulsa **Commit changes**. Para reemplazar `index.html` o un modelo, usa **Add file > Upload files** y sube la versión nueva en la misma ruta.
3. Asegúrate de guardar los cambios en `main`. GitHub Pages volverá a publicar el sitio automáticamente.
4. Espera a que la ejecución de Pages en **Actions** termine y recarga el sitio. Si el navegador muestra la versión anterior, prueba una recarga forzada.

## Usar un GLB alojado en este mismo repositorio

1. Sube el archivo a `assets/models/`, por ejemplo `assets/models/robot-aula.glb`.
2. En el sitio publicado, entra como docente y abre **Ajustes**.
3. En el campo del modelo predeterminado, escribe la ruta relativa exacta: `assets/models/robot-aula.glb`. No pongas una barra inicial y respeta las mayúsculas del nombre.
4. Pulsa **Guardar URL**. También puedes usar la opción para cargar un modelo en el Laboratorio XR con esa misma ruta.
5. Comprueba que el archivo está publicado abriendo una dirección como `https://TU-USUARIO.github.io/scratchxr-lab/assets/models/robot-aula.glb`. Debe descargarse o mostrarse sin una página 404.

La ruta relativa se resuelve desde la ubicación del sitio e incluye automáticamente el subdirectorio del repositorio. Al cargarlo desde el mismo sitio, el modelo usa el mismo origen y normalmente evita los bloqueos CORS de un servidor externo. Si usas una URL alojada fuera de GitHub, ese servidor debe permitir solicitudes desde el sitio mediante sus encabezados CORS.

## Taller de bloques: retos y proyectos (Fase 10-C)

- Incluye dos retos automáticos por grado (3.º a 11.º), con pistas progresivas y XP otorgados una sola vez al superarlos. Algunos bloques avanzados se evalúan por su estructura y por los resultados que el simulador puede observar; para validar sensores, eventos y comportamientos completos, usa Scratch real.
- Cada perfil puede guardar hasta cinco proyectos del Taller con nombre, abrirlos, duplicarlos, eliminarlos e importar o exportar proyectos en JSON. Esta biblioteca queda en el almacenamiento local del dispositivo; conserva copias exportadas para transferir proyectos.
- El panel docente incorpora la pestaña **Proyectos**, filtros por estudiante/grado, apertura en modo de solo lectura y una rúbrica local de creatividad, lógica y uso de bloques del nivel.
- En **Ajustes**, el docente puede desactivar el Taller o la cámara y definir la sensibilidad por defecto de las manos. Sin cámara siguen disponibles ratón, teclado y pantalla táctil.
- Las insignias del Taller incluyen **Arquitecto de bloques**, **Creador** y **Maestro del taller**. La insignia **Manos mágicas** depende de completar el Gimnasio de gestos.

## Progreso compartido entre dispositivos (fase 11-D)

La integración remota es opcional y requiere configuración del docente. Consulta [`SUPABASE_SETUP.md`](SUPABASE_SETUP.md) para crear el proyecto, aplicar RLS y limitar los datos sincronizados. Ejecuta [`supabase/phase-11d.sql`](supabase/phase-11d.sql) en el SQL Editor de Supabase. Nunca incluyas la clave `service_role` en el sitio. La sincronización de perfiles antiguos sigue siendo manual desde Ajustes docentes; la fase 12 añade acceso aprobado y sincronización automática para nuevos perfiles. Requiere cuenta docente autenticada.

El visor 3D carga por defecto el modelo de gato aportado por el usuario en `assets/models/scratch-cat.glb`. Verifica sus derechos de redistribución antes de publicar.

## Acceso aprobado y progreso en línea (fase 12)

El docente configura Supabase, inicia sesión y abre la pestaña **Acceso al curso** del menú superior docente. Allí crea y copia el enlace completo y ve el código de aula de 12 caracteres. Cada solicitud aparece en esa misma pestaña, donde puede permitir, denegar o revocar el acceso por estudiante. El PIN local solo abre el panel y no autentica al docente: para generar el código o responder solicitudes debe configurar la URL y la clave publicable de Supabase en **Ajustes**, pulsar **Configurar conexión** e iniciar sesión con su cuenta docente. Las solicitudes y el progreso de estudiantes aprobados se actualizan automáticamente en línea; si el apodo y grado coinciden con un perfil local único, la app lo vincula sin perder sus avances. El informe docente combina progreso local y perfiles remotos autorizados por RLS. Las alertas en vivo requieren que la página esté abierta y conectada; las notificaciones del navegador requieren permiso explícito y no se envían si la página está cerrada (no hay Web Push configurado). La plantilla de notas se encuentra en el panel docente y no contiene información de estudiantes. Ejecuta `supabase/phase-12-access-realtime.sql` después de la migración 11-D; los pasos, límites offline y privacidad se explican en [`SUPABASE_SETUP.md`](SUPABASE_SETUP.md).

## Audios de misiones (fase 11-E)

El botón **Escuchar** reproduce `assets/audio/<id-de-la-misión>.mp3` cuando el archivo existe; si falta o no puede reproducirse, utiliza la voz del navegador. La carpeta [`assets/audio/`](assets/audio/README.md) incluye el inventario exacto de archivos MP3 para las 39 misiones incluidas y pasos de generación/publicación en GitHub.



## Aplicación PWA y uso sin conexión

La aplicación se puede instalar como PWA en HTTPS. Entra online una vez y espera a que el indicador muestre **modo sin conexión preparado**: se guardan el HTML, los recursos XR, el modelo local del gato, las fuentes 3D y MediaPipe para el seguimiento de manos (aprox. 31 MB). Después, las funciones locales, incluidos el contenido, el panel docente, el gato 3D y el taller A-Frame, pueden usarse sin red. El progreso permanece en el almacenamiento local del navegador.

La sincronización Supabase requiere conexión y no se cachea. Los audios MP3 opcionales se guardan al reproducirlos mientras haya conexión. Se necesita HTTPS (o `localhost`); abrir el HTML con `file://` no habilita PWA. Consulta [PWA_OFFLINE.md](PWA_OFFLINE.md) para instalación, actualizaciones y límites de almacenamiento. Los bundles distribuidos localmente mantienen sus avisos de licencia en `assets/vendor/`.

## Quizzes docentes compartidos (fase 13)

Los quizzes personalizados guardados en el panel docente se publican a la cuenta docente autenticada de Supabase. Cada estudiante aprobado consulta solo los quizzes de su aula y grado desde **Retos**; la lectura se valida mediante su identificador de solicitud y secreto bearer aprobado. La publicación incluye solo contenido didáctico del quiz, no perfiles ni datos personales. Ejecuta `supabase/phase-13-shared-quizzes.sql` después de las fases 11-D y 12. La disponibilidad se actualiza al abrir Retos y en la comprobación periódica en línea.


## Permisos de cámara por estudiante (fase 14)

Desde **Acceso al curso** en el menú docente, se puede autorizar o retirar la cámara para cada estudiante aprobado de forma independiente; aprobar a una persona no habilita al resto. El permiso se consulta desde el dispositivo del estudiante y es denegado por defecto en Supabase. Para iniciar la cámara, el estudiante también debe aceptar el consentimiento en la app y el diálogo de permisos del navegador. El vídeo se procesa en el dispositivo y no se graba ni se envía. Ejecuta `supabase/phase-14-individual-camera-permissions.sql` después de la migración 12 (puede ir tras Phase 13); perfiles exclusivamente locales solo se pueden controlar en su propio navegador.

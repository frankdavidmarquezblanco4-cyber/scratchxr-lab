# SCRATCHXR LAB

Plataforma educativa web para aprender programación por bloques mediante misiones, teoría, retos, proyectos locales y experiencias de realidad virtual. Está dirigida a estudiantes de **3.º a 11.º grado** y funciona como un sitio estático instalable como PWA.

## Experiencia actual

- **Acceso público:** cualquier visitante puede entrar con un apodo y su grado. No requiere cuenta, código de aula ni aprobación docente. Se recomienda no escribir nombres legales, correos u otra información identificable.
- **Perfil y progreso locales:** misiones completadas, puntuaciones, proyectos y preferencias se guardan en el almacenamiento de este navegador. No se sincronizan con Supabase ni se comparten automáticamente entre dispositivos. Usa **Cambiar perfil** en equipos compartidos; los perfiles anteriores permanecen guardados en ese dispositivo.
- **Contenido educativo:** misiones graduadas, teoría detallada, quizzes y retos con retroalimentación, insignias, racha, actividades diarias y taller de bloques 3D.
- **Laboratorio de RV:** escena A-Frame con el gato de Scratch, bloques y diez estaciones interactivas. Selecciona una estación con ratón, teclado, tacto o gatillo del visor; revisa si está disponible según tu grado y abre los bloques relacionados en Teoría. Entra a RV inmersiva con un visor WebXR compatible y HTTPS; sin visor, explora en pantalla.
- **Sin RA:** el acceso de realidad aumentada y la superposición de vídeo del Taller se retiraron de la experiencia pública.
- **Control de manos opcional:** solo se activa si la persona lo decide, acepta el uso de cámara y concede el permiso nativo del navegador. El video se procesa en el dispositivo, no se graba ni se sube. El sitio también funciona sin cámara.
- **Accesibilidad y audio:** lectura del navegador y archivos MP3 de misiones con fallback a la voz del navegador.

## Acceso y privacidad

La versión pública solicita únicamente un apodo y grado para crear un perfil local. El progreso permanece en el almacenamiento del navegador; borrar esos datos o cambiar de dispositivo puede eliminar el perfil local. Para transferir un proyecto, usa sus opciones locales de exportación/importación y guarda una copia segura.

El inicio de sesión docente, las solicitudes de aprobación, el progreso compartido, los quizzes docentes sincronizados y las autorizaciones de cámara por docente ya no forman parte del flujo de esta versión. Su código y archivos SQL se conservan como legado para una posible restauración posterior, pero **no son necesarios para usar la aplicación**. Esta actualización no borra tablas ni datos existentes en Supabase y no ejecuta migraciones.

## Compatibilidad

- Se necesita un navegador moderno con WebGL para la escena 3D.
- La RV inmersiva requiere HTTPS, un navegador con WebXR y un visor compatible. Si no hay visor, se mantiene la escena interactiva en pantalla; ese modo no inicia una sesión inmersiva.
- La cámara para control de manos requiere HTTPS (o `localhost`), hardware compatible, consentimiento de la persona y permiso del navegador. Ratón, teclado y tacto siguen disponibles.
- La voz depende de las voces instaladas en el navegador y sistema operativo.

## PWA y uso sin conexión

Abre el sitio una vez con internet y espera a que termine de preparar los recursos offline. La caché incluye el HTML, el gato de Scratch, las bibliotecas XR/MediaPipe y los recursos de instalación. Después se conservan localmente el contenido y los avances de ese navegador; los recursos MP3 se cachean al reproducirse en línea. Se necesita HTTPS o `localhost`; abrir `index.html` con `file://` no habilita la PWA. Consulta [`PWA_OFFLINE.md`](PWA_OFFLINE.md) para instalación y límites de almacenamiento.

## Estructura del repositorio

```text
scratchxr-lab/
├── index.html
├── manifest.webmanifest
├── service-worker.js
├── PWA_OFFLINE.md
├── assets/
│   ├── audio/
│   ├── models/scratch-cat.glb
│   ├── pwa/
│   └── vendor/       # bibliotecas locales y sus licencias
└── supabase/          # SQL legado, no requerido por el modo público
```

El modelo de gato está en `assets/models/scratch-cat.glb`. Revisa y conserva sus atribuciones/licencias antes de redistribuirlo. Las dependencias distribuidas localmente mantienen sus avisos en `assets/vendor/`.

## Publicar en GitHub Pages

1. Sube el contenido completo del proyecto a la raíz de un repositorio GitHub, conservando la estructura de `assets/` y `supabase/`.
2. En **Settings → Pages**, elige **Deploy from a branch**, selecciona `main` y la carpeta `/(root)` y guarda.
3. Espera a que termine el despliegue. Para un repositorio llamado `scratchxr-lab`, la URL suele ser `https://TU-USUARIO.github.io/scratchxr-lab/`.
4. Tras actualizar el código, espera el build de Pages y recarga. La PWA actualiza su caché a través del Service Worker; si ves una versión anterior, cierra la instalación y vuelve a abrir el sitio conectado a internet.

Los sitios Pages son públicos por internet. No subas datos personales de estudiantes, contraseñas, claves privadas ni secretos al repositorio. Nunca incluyas claves Supabase `service_role` o `sb_secret_…` en código cliente.

## Audios de misiones

El botón **Escuchar** reproduce `assets/audio/<id-de-la-misión>.mp3` si existe; de lo contrario usa la voz del navegador. La carpeta [`assets/audio/README.md`](assets/audio/README.md) contiene el inventario de nombres de archivo y las instrucciones para generar y subir los audios.

## Backend legado

Los archivos `supabase/phase-11d.sql` y `supabase/phase-12-access-realtime.sql` a `phase-14-individual-camera-permissions.sql` describen las funciones en línea de versiones anteriores. `SUPABASE_SETUP.md` se conserva como referencia histórica; sus pasos de autenticación docente y aprobación no se aplican a la versión pública actual. No apliques migraciones para habilitar el acceso libre.

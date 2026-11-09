# SCRATCHXR LAB sin conexión (PWA)

## Uso inicial

La instalación y la primera preparación requieren conexión. Abre la página publicada bajo HTTPS (o `http://localhost`), espera a que aparezca **Modo sin conexión preparado** y luego instala desde el navegador. En Chrome/Edge se puede usar **Instalar aplicación**; en Safari/iPadOS, **Compartir → Añadir a pantalla de inicio**. La preparación guarda el sitio, el gato de Scratch y los recursos XR/MediaPipe. El navegador puede solicitar permiso de almacenamiento.

## Qué funciona offline

- Misiones, teoría, retos, el taller y los proyectos locales.
- Perfiles y progreso guardados en ese dispositivo/navegador.
- El gato de Scratch y la escena de RV A-Frame después de preparar los recursos. Sin visor, la escena permanece disponible en pantalla.
- Voz local del navegador y audios MP3 que ya se reprodujeron y quedaron en caché.
- Control de manos, si MediaPipe y la cámara ya están disponibles; el video se procesa localmente y no se guarda ni se envía.

## Qué requiere conexión

- La instalación y preparación inicial de la PWA.
- Descargar una versión nueva del sitio o un modelo/audio remoto que aún no esté en caché.
- RV inmersiva: además de conexión inicial, requiere HTTPS, un navegador con WebXR y un visor compatible. Sin esos elementos sigue disponible la escena en pantalla, pero no una sesión inmersiva.

La experiencia actual es de acceso público: no crea solicitudes de aula, no consulta decisiones docentes y no sincroniza perfiles, avances ni quizzes con Supabase. Las tablas y funciones Supabase existentes pertenecen a versiones anteriores y no se alteran al usar esta PWA.

El control de manos es opcional. Para activarlo en línea se necesita HTTPS (localhost también es contexto seguro), consentimiento de la persona y permiso del navegador. Sin cámara se puede usar ratón, teclado o pantalla táctil.

## Publicación y actualización

Publica en la raíz `index.html`, `manifest.webmanifest`, `service-worker.js`, `assets/` y los demás archivos, conservando las rutas relativas. GitHub Pages con HTTPS y otros servidores HTTPS son válidos; `file://` no admite service workers. El app shell actual usa `scratchxr-offline-v21`. Al cambiar recursos precargados, incrementa `CACHE_NAME`; al activarse, el service worker elimina sus cachés anteriores sin borrar `localStorage` ni los perfiles/progresos locales.

## Privacidad y almacenamiento

La caché PWA contiene los archivos de aplicación/modelos, no los perfiles ni respuestas de APIs. El estado y los avances se guardan en el almacenamiento local del navegador y no se comparten automáticamente entre dispositivos. En equipos compartidos, usa **Cambiar perfil** y evita introducir información que identifique a una persona menor. Borrar los datos del sitio elimina los perfiles, proyectos y avances locales de ese navegador.

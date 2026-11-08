# SCRATCHXR LAB sin conexión (PWA)

## Uso inicial

La instalación y la primera preparación requieren conexión. Abre la página publicada bajo HTTPS (o `http://localhost`), espera a que aparezca **Modo sin conexión preparado** y luego instala desde el navegador. En Chrome/Edge se puede usar **Instalar aplicación**; en Safari/iPadOS, **Compartir → Añadir a pantalla de inicio**. El primer almacenamiento descarga el sitio, el Scratch Cat 3D y los recursos XR/manos. El navegador puede solicitar permiso de almacenamiento.

## Qué funciona offline

- La interfaz y los recursos del sitio, misiones, teoría ampliada, retos, taller y panel docente local.
- Perfiles/progreso locales existentes en el dispositivo.
- El modelo Scratch Cat, el visor 3D, A-Frame/RV y MediaPipe tras la preparación inicial.
- Voz local del navegador y audios que ya se reprodujeron y quedaron en caché.
- Una sesión de estudiante que ya fue aprobada y está guardada en este mismo dispositivo; el progreso nuevo queda local hasta recuperar conexión.

## Qué requiere conexión

- Enviar una solicitud de acceso nueva, consultar una decisión o revocación y que el docente apruebe o deniegue.
- Sincronización automática del progreso de estudiantes aprobados, consultas de resultados remotos, autenticación docente y acceso Supabase.
- Notificaciones en vivo al docente. La notificación del navegador, si se concede, requiere que el sitio esté abierto y conectado; no es push de fondo.
- Instalación/primera preparación de la PWA y descarga de modelos remotos que aún no estén en caché.

Un estudiante nuevo debe abrir el enlace de aula y recibir aprobación mientras está en línea. Una aprobación previamente verificada permite usar la app sin conexión en ese dispositivo, pero no se puede recibir una revocación hasta volver a conectarse. Al reconectar, el cliente reintenta la sincronización del progreso local. Las ediciones de lecciones/quizzes y las preferencias docentes siguen siendo locales en esta versión.

El seguimiento de manos procesa landmarks en el dispositivo; no sube cámara, imágenes, micrófono ni audio. La cámara requiere HTTPS (localhost también es contexto seguro), aprobación docente para esa sesión y consentimiento/permisos del navegador.

## Publicación/actualización

Publica en la raíz `index.html`, `manifest.webmanifest`, `service-worker.js`, `assets/` y demás archivos, conservando rutas relativas. GitHub Pages con HTTPS y un servidor HTTPS son válidos; `file://` no admite service workers. Para actualizar el app shell, incrementa `CACHE_NAME` en `service-worker.js`; la versión actual del proyecto usa `scratchxr-offline-v13`. El service worker elimina sus cachés anteriores, pero no borra `localStorage` ni credenciales de sesión.

## Privacidad y almacenamiento

La caché PWA contiene archivos de aplicación/modelos, no perfiles o respuestas de APIs. La aprobación local y el progreso se guardan en el almacenamiento del navegador; el secreto de sesión de estudiante reside en `localStorage` y no está cifrado. No uses equipos públicos/compartidos; cierra la sesión Auth del docente al terminar. Borrar los datos del sitio elimina los datos locales y puede impedir recuperar una sesión aprobada que no tenga respaldo remoto autorizado.

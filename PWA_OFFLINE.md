# SCRATCHXR LAB sin conexión (PWA)

## Uso inicial

La instalación/preparación requiere conexión una sola vez. Abre la página publicada bajo HTTPS (o `http://localhost`), espera a que aparezca el indicador **Modo sin conexión preparado** y luego instala desde el navegador. En Chrome/Edge se puede usar **Instalar aplicación**; en Safari/iPadOS, **Compartir → Añadir a pantalla de inicio**. El primer almacenamiento descarga el sitio, el modelo 3D del gato y los recursos XR/manos, aproximadamente 31 MB sin comprimir. El sistema operativo/navegador puede solicitar permiso de almacenamiento.

## Qué funciona offline

- La aplicación y sus estilos, texto, misiones, teoría, retos, paneles docentes y preferencias.
- Datos locales de perfiles/progreso guardados en el navegador (no se envían por instalar la PWA).
- El GLB del gato y el visor 3D.
- A-Frame/RV y el runtime/modelo de MediaPipe para seguimiento de manos, después de la preparación inicial.
- La voz del navegador si el dispositivo tiene una voz local instalada.
- Los MP3 opcionales se guardan cuando se reproducen mientras hay conexión; un archivo nuevo que nunca se descargó no estará disponible offline.

## Qué requiere conexión

- Sincronización Supabase, autenticación docente remota y cualquier otra operación en la nube. Al quedar sin conexión no se hacen peticiones remotas ni se almacenan en caché respuestas de APIs/autenticación.
- La instalación y la primera preparación del caché.
- Modelos GLB personalizados remotos que no se hayan descargado antes. El modelo Scratch Cat incluido sí queda precargado.

El seguimiento interpreta gestos a partir de landmarks y refleja solo la coordenada horizontal del puntero para seguir la vista selfie; la etiqueta anatómica izquierda/derecha no decide la acción. En cada carga de la página, la cámara queda bloqueada hasta que el docente entre al panel con su PIN y la autorice para esa sesión. Luego cada estudiante debe marcar su consentimiento y conceder el permiso del navegador. La autorización docente se revoca al recargar o al desactivarla. La cámara requiere HTTPS (localhost también es un contexto seguro), autorización explícita del usuario y dispositivo compatible; la PWA no omite los permisos del navegador.

## Publicación/actualización

Publica en la raíz de la aplicación `index.html`, `manifest.webmanifest`, `service-worker.js`, `assets/` y el resto de archivos del proyecto, conservando las rutas relativas. GitHub Pages con HTTPS y un servidor HTTPS son válidos; `file://` no admite service workers. Para una actualización que cambie los activos precargados, incrementa `CACHE_NAME` en `service-worker.js` para crear una caché nueva. El service worker retira versiones anteriores de su propia caché; no borra el almacenamiento de progreso (`localStorage`).

## Privacidad y almacenamiento

El caché contiene archivos de aplicación/modelos, no perfiles ni progreso. El progreso existente sigue en `localStorage` de este navegador. La caché local puede ocupar alrededor de 31 MB y puede borrarse desde Ajustes del sitio/navegador; la próxima apertura online volverá a prepararla. Desinstalar la PWA no equivale a sincronizar ni respaldar los perfiles.

# Modo público y RV exclusiva · trabajo actual

- [x] **Quitar RA de la experiencia visible.** Una sola pestaña XR: Laboratorio de RV. Se ocultan los paneles y botones antiguos de RA, se desactiva `model-viewer` AR y se elimina la superposición de vídeo del Taller.
- [x] **Mejorar RV.** Diez estaciones educativas se pueden seleccionar con mouse/tacto, teclado (Enter/Espacio) o gatillo de los controladores izquierdo/derecho. Cada estación muestra su propósito, indica el grado requerido cuando está bloqueada y enlaza a Teoría cuando está disponible. Se explican los controles para visor y para pantalla.
- [x] **Entrada pública sin aprobación.** Cualquier visitante crea un perfil local usando solo apodo y grado; no requiere código de aula, cuenta, solicitud ni aprobación. Hay un botón para cambiar de perfil sin borrar avances locales.
- [x] **Ocultar el rol docente.** El botón, panel, PIN, aprobaciones y ajustes docentes quedan fuera de la interfaz pública. El código heredado se conserva para una posible restauración; no se borran datos ni se ha ejecutado SQL.
- [x] **Privacidad local.** Se omiten las consultas/sincronización de acceso, progreso, cámara docente y quizzes Supabase. La cámara de manos es opcional, exige consentimiento y permiso nativo del navegador; el video no se graba ni se transmite.
- [x] **PWA y documentación.** Service Worker actualizado a `scratchxr-offline-v19`; README, guía offline y documentos de referencia alineados.
- [x] **Prueba en Chromium/WebGL local.** Verificado: perfil público y persistencia al recargar, una sola experiencia XR visible, diez estaciones, selección por mouse, detalle por grado, navegación a Teoría, controladores de ambas manos y ausencia de errores JavaScript en el escenario RV.

## Pendiente de publicación

Los cambios están en el directorio de trabajo y aún no se han publicado en GitHub Pages. Phase 15 (clases por grado y fecha) permanece pausada en un stash local y no se ha ejecutado en Supabase.

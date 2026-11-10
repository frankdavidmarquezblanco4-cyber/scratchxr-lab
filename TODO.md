# Estado de ScratchXR Lab

## Versión pública anterior

- GitHub Pages servía la versión con el gato Scratch y acceso público con perfiles locales. El build público más reciente previo a esta corrección era el commit `0c43ef7` (aplicación web `7374f2f`, caché PWA v23).
- Phase 15 (gestión de clases por grado/fecha) permanece pausada; su migración SQL no se ha ejecutado en producción y no debe retomarse salvo petición expresa.

## Solicitud actual: revisar gato, entrada RV y datos

- [x] **Causa del botón RV.** En equipos sin WebXR, la aplicación solo activaba «ENTRAR EN RV» si detectaba un visor; por eso el control parecía no funcionar aunque la escena 3D sí existía.
- [x] **Entrada RV corregida.** Con visor compatible se intenta RV inmersiva; si no hay visor, «VER RV EN PANTALLA» amplía la escena a pantalla completa. El botón «Salir de pantalla completa» se conserva dentro de la escena; Escape también permite volver. El fallback se probó en escritorio y móvil (390 × 844 px).
- [x] **Gato Scratch.** Se mantiene `assets/models/scratch-cat.glb`; en las pruebas locales el modelo cargó y quedó visible, con orientación frontal fija, incluso en el modo de pantalla completa móvil.
- [x] **Indicadores públicos.** El encabezado muestra RV, no un estado de RA residual; el Taller ofrece únicamente 3D y RV.
- [x] **Auditoría de datos por grado.** En Chromium, los grados 3°–11° mostraron teoría y retos correspondientes al grado, quizzes jugables y 15 insignias; no hubo excepciones JavaScript. Misiones: seis por grado de 3° a 8° y una misión por grado de 9° a 11° en el catálogo actual.
- [x] **Flujo de quiz y progreso.** Un quiz de 8 preguntas llegó al resultado (8/8, 80 XP); al recargar y reanudar el perfil guardado, se conservó el mejor puntaje. El cambio de grado del perfil de 3° a 11° también sobrevivió a recargar y reanudar.
- [x] **Perfil local.** Crear, elegir y continuar un perfil guardado funciona en el mismo navegador/dispositivo. No se envía información personal a un servidor; el progreso no se sincroniza automáticamente entre dispositivos.
- [x] **Caché PWA.** `service-worker.js` y `PWA_OFFLINE.md` están preparados en v24 para reemplazar la caché anterior.
- [x] **Publicación.** GitHub Pages completó el build del commit `471cddd`; producción confirmó el gato GLB visible, la vista RV a pantalla completa con salida, la caché v24 y cero errores JavaScript.

## Funciones de RV ya existentes

- Taller con bloques Scratch 3D filtrados por grado: pinza MediaPipe para mover, dos manos para cambiar tamaño y rotar, y control de volteo; también admite ratón, tacto, teclado y controladores.
- El uso de MediaPipe solicita permiso de cámara expresamente; el procesamiento es local y no graba ni transmite el video. Las transformaciones se guardan en el proyecto local nombrado y se restauran al abrirlo.

## Consideraciones de verificación

- No había un visor WebXR físico disponible en las pruebas; la ruta inmersiva no pudo probarse con hardware. El fallback 3D/pantalla completa sí se verificó en Chromium.
- Los grados 9°–11° tienen menos misiones que 3°–8° en los datos actuales (una por grado); sus secciones de teoría, retos, quizzes y logros sí cargan. Si se desean seis misiones para cada grado alto, se necesitaría crear contenido adicional.
- El progreso y los perfiles son locales al navegador/dispositivo; Phase 15 sigue pausada.

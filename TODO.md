# Estado de ScratchXR Lab

## Versión pública anterior

- [x] **Acceso público y perfiles locales.** Cualquier persona entra con apodo y grado; se pueden reanudar perfiles guardados en el mismo navegador/dispositivo.
- [x] **RV exclusiva.** Diez estaciones interactivas, con mouse/tacto, teclado o controladores y acceso a Teoría.
- [x] **PWA anterior.** GitHub Pages servía el commit `fcdadd6` y `scratchxr-offline-v21` antes del trabajo actual.

## Solicitud actual: gato e interacción con bloques en RV

- [x] **Gato Scratch.** El GLB se conserva; en la escena probada mide 2.65 unidades, está adelantado y elevado respecto a las estaciones y mantiene una orientación frontal fija, para no terminar mostrando la espalda.
- [x] **Bloques Scratch por grado.** El Taller genera bloques 3D desde la paleta y conserva el filtro educativo por grado. La pinza de MediaPipe mueve bloques; pellizcar con dos manos aumenta/reduce el bloque seleccionado; girar ambas manos rota el seleccionado; «Voltear bloque» y pulgar arriba con un bloque seleccionado lo voltean. Ratón, tacto, teclado y controladores siguen disponibles.
- [x] **Guardar/deshacer transformaciones.** Tamaño, giro y volteo se guardan en el proyecto nombrado (la aplicación solicita un nombre) y se restauran al reabrir; el volteo puede revertirse con Deshacer.
- [x] **Consentimiento y cámara.** La cámara no se solicita al abrir el Taller: exige consentimiento y permiso del navegador; el video se procesa localmente y no se graba ni se envía. Chromium confirmó que no hay flujo antes del consentimiento, que el botón alterna a «Apagar» y que la pista termina al apagarla.
- [x] **Sin RA visible.** El selector del Taller solo ofrece 3D y RV; se mantiene oculta la antigua superposición de cámara.
- [x] **Verificación local.** Chromium cargó el gato y bloques 3D, comprobó la herramienta de volteo y ausencia de errores JavaScript; la reapertura de un proyecto restauró el giro de 180°. En móvil (390 px) y escritorio el gato quedó dentro del canvas. El dispositivo de prueba no contenía cámara física: se probó el ciclo con cámara simulada; la interacción física con las manos requiere cámara real y HTTPS.
- [x] **PWA/documentación.** La caché y la guía offline están en v23.
- [x] **Publicación.** GitHub Pages terminó el build del commit `7374f2f`; la URL pública cargó el GLB `assets/models/scratch-cat.glb` con el rostro visible, la posición frontal y PWA v23, sin errores JavaScript.

## Trabajo pausado

Phase 15 (gestión de clases por grado/fecha) permanece pausada; su migración SQL no se ha ejecutado en producción y no debe retomarse salvo petición expresa del usuario.

# Estado de FaunaXR

## Entregado en esta versión local
- [x] La página principal y el inicio PWA abren la Galería de animales; la marca visible y el manifiesto se llaman FaunaXR.
- [x] Iconos de instalación FaunaXR en tamaños 192 y 512 px, incluido icono maskable.
- [x] Catálogo ampliado a 21 animales; agrega 13 salvajes: león, tigre blanco, lobo, elefante, jirafa, rinoceronte, panda, tiburón blanco, oso, cocodrilo, gorila, cebra y guepardo.
- [x] Licencias CC0 1.0 y fuente identificadas en las fichas y `assets/models/WILD-MODELS-LICENSES.txt`.
- [x] La sala RV incluye 21 estaciones con selector y navegación Anterior/Siguiente en pantalla completa; botones equivalentes están frente a la cámara en escena WebXR.
- [x] La sección Mis modelos continúa aceptando GLB de hasta 60 MB, guardándolos localmente.
- [x] Service worker actualizado para FaunaXR y miniaturas de animales salvajes; modelos se cachean al visitarlos.

## Aún pendiente
- [ ] Añadir un modelo de puma/cougar cuando se disponga de un GLB con permiso/licencia redistribuible verificable. No se incluyó un modelo de fuentes que requieren cuenta o cuya licencia no se pudo comprobar.
- [ ] Publicar esta versión en hosting HTTPS; aún no se ha realizado despliegue ni push.
- [ ] Probar la sesión WebXR con un visor físico; los controles virtuales están implementados pero el hardware no está disponible en esta verificación.

## Privacidad
Los perfiles, favoritos y modelos propios persisten en el navegador/dispositivo local. La cámara de manos continúa siendo opcional, requiere consentimiento y el video se procesa en el dispositivo.

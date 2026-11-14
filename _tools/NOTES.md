# Notas técnicas de Galería XR

La página `galeria-xr.html` reutiliza `assets/vendor` (model-viewer 4, A-Frame 1.7 y MediaPipe Vision). El catálogo contiene gato, cachorro, conejo, gallina, vaca y caballo. Las miniaturas de `_tools/shoot.py` se renderizan desde los GLB a 1500×1125 WebP y también se embeben en el HTML como respaldo, por lo que las imágenes permanecen visibles aunque falten archivos de miniaturas.

## Modelos y licencias
- Gato Scratch — Scratch Foundation; uso educativo: https://scratch.mit.edu/terms_of_use
- Cachorro bernés — Grab3D, CC0 1.0; modelo asistido por IA: https://grab3d.com/models/animals/puppy/ (licencia local `assets/models/puppy-LICENSE.txt`).
- Conejo low-poly — Grab3D, CC0 1.0; modelo asistido por IA: https://grab3d.com/models/animals/low-poly-rabbit/ (licencia local `assets/models/low-poly-rabbit-LICENSE.txt`).
- Gallina low-poly — Grab3D, CC0 1.0; modelo asistido por IA: https://grab3d.com/models/animals/low-poly-chicken/ (licencia local `assets/models/low-poly-chicken-LICENSE.txt`).
- Vaca low-poly — Grab3D, CC0 1.0; modelo asistido por IA: https://grab3d.com/models/animals/low-poly-cow/ (licencia local `assets/models/low-poly-cow-LICENSE.txt`).
- Caballo low-poly — Grab3D, CC0 1.0; modelo asistido por IA: https://grab3d.com/models/animals/low-poly-horse/ (licencia local `assets/models/low-poly-horse-LICENSE.txt`).

## Miniaturas y pruebas

Las miniaturas se generan con `_tools/poster.html` y `_tools/shoot.py` (Playwright y Chromium con SwiftShader). `test_functional.py`, `test_gallery.py` y `test_profiles_offline.py` ejercitan galería, filtros, RA, RV, cámara simulada, GLB, perfiles y modo offline. Para ejecutarlos, inicia `python3 -m http.server 8123` en la raíz del proyecto.

## Almacenamiento y offline

Perfil local en `localStorage` (`sxrGallery.v1`) y GLB propios en IndexedDB (`sxrGallery/models`). Los IDs retirados del catálogo se limpian de favoritos y modelos vistos antiguos, sin borrar el resto de los perfiles. El service worker se actualizó a `scratchxr-offline-v29`; precarga las miniaturas y los modelos pequeños. El cachorro (`Puppy.glb`, ~14 MB) se descarga y almacena en caché cuando se abre por primera vez, para no hacer pesada la instalación inicial.

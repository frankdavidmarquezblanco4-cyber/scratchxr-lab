# FaunaXR · Galería de animales 3D

FaunaXR es una aplicación web progresiva instalable para explorar animales domésticos y salvajes. Admite perfiles locales, favoritos, búsqueda, visores 3D, modos de realidad aumentada, sala de RV, controles gestuales opcionales con cámara y carga de modelos GLB personales.

## Instalación como app

Sirve o publica la carpeta completa en HTTPS. En computadora, pulsa **Instalar app** en el encabezado si el navegador ofrece instalación. En Android, Chrome → menú ⋮ → **Instalar app** o **Agregar a pantalla principal**. En iPhone/iPad, abre FaunaXR en Safari → Compartir → **Agregar a pantalla de inicio**. Para probar en local, ejecuta `python3 -m http.server 8000` y abre `http://localhost:8000/`.

## Colección y permisos

La colección incorpora animales de casa y granja además de 13 especies salvajes: león, tigre blanco, lobo, elefante, jirafa, rinoceronte, panda, tiburón blanco, oso, cocodrilo, gorila, cebra y guepardo. Los nuevos modelos se redistribuyen bajo CC0 1.0; la lista de fuentes figura en `assets/models/WILD-MODELS-LICENSES.txt`. No se incluyó puma porque no quedó confirmada una descarga GLB redistribuible con licencia verificable.

## Controles de RV

En **Sala RV**, al entrar en **Pantalla completa**, usa los controles integrados en la parte inferior: **Anterior**, el selector **Animal al frente** y **Siguiente**. Cambiar la selección reorienta la cámara hacia la estación elegida. En visor WebXR, los botones virtuales **ANTERIOR** y **SIGUIENTE** están colocados frente a la cámara; apunta y pulsa con el controlador. Los pedestales también se pueden seleccionar con el puntero/control.

## Modelos propios y privacidad

En **Mis modelos**, sube GLB de hasta 60 MB; la página valida el archivo y guarda sus datos en IndexedDB del mismo navegador. Los modelos, perfil y favoritos permanecen en ese dispositivo, no se suben ni sincronizan automáticamente. El control de manos/cámara es opcional y requiere consentimiento y permiso del navegador; el video se procesa localmente.

## Licencias y estructura

Los modelos salvajes descargados de Grab3D tienen licencia CC0 1.0, indicada en sus páginas y catalogada en `assets/models/WILD-MODELS-LICENSES.txt`. Se conserva la atribución por trazabilidad. El pato y el zorro que ya venían en el ZIP tienen origen/licencia por verificar antes de redistribuirse por separado; sus fichas lo indican. El gato conserva sus términos de uso originales. El proyecto incluye bibliotecas locales A-Frame, model-viewer y MediaPipe con sus avisos de licencia.

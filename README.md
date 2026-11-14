# FaunaXR

FaunaXR es una galería web instalable para explorar animales domésticos y salvajes en 3D, RA y RV. Se distribuye como PWA estática, funciona sin cuenta en el modo local y permite subir modelos propios GLB al navegador.

## Abrir en computadora

Extrae el ZIP y ejecuta desde esta carpeta:

```bash
python3 -m http.server 8000
```

Abre `http://localhost:8000/` o `http://localhost:8000/galeria-xr.html`. La página raíz abre la galería de animales. Para instalarla, publica la carpeta completa en un alojamiento HTTPS y usa **Instalar app**; en iPhone/iPad, Safari → Compartir → **Agregar a pantalla de inicio**.

## Animales y realidad virtual

La galería incluye animales domésticos y 13 modelos salvajes adicionales: león, tigre blanco, lobo, elefante, jirafa, rinoceronte, panda, tiburón blanco, oso, cocodrilo, gorila, cebra y guepardo. Los modelos salvajes descargados desde Grab3D están publicados con licencia CC0; se conservan fichas y URLs en `assets/models/WILD-MODELS-LICENSES.txt`. El origen/licencia de los modelos heredados de pato y zorro requiere verificación antes de redistribuirlos por separado. El puma no se añadió aún porque no se encontró un archivo GLB redistribuible con licencia verificable en la fuente usada.

En la pestaña **Sala RV**, usa **Pantalla completa**. Aparecerán controles **Anterior**, selector del animal al frente y **Siguiente** dentro de la pantalla completa. En un visor WebXR compatible, los botones flotantes **ANTERIOR** y **SIGUIENTE** aparecen frente a la cámara, y también se puede seleccionar una estación apuntando con el control.

## Subir diseños propios

En **Mis modelos**, sube archivos `.glb` de hasta 60 MB. Se guardan en IndexedDB del navegador y quedan disponibles en la galería y modos 3D/RA/RV. No se envían a un servidor ni se sincronizan con otros dispositivos. Los perfiles y favoritos también son locales.

## Modo sin conexión

Abre la app en HTTPS o localhost una vez con conexión para instalar el service worker. Se preparan la página, librerías y miniaturas; los modelos 3D se cachean a medida que se abren. El modo offline depende de que el navegador conserve el espacio de caché.

## Estructura

- `galeria-xr.html`: galería, perfiles, modelos, RA, RV, control de manos y carga GLB.
- `index.html`: entrada que redirige a la galería.
- `scratch-programming-legacy.html`: copia de la antigua página Scratch, archivada y fuera del flujo principal.
- `manifest.webmanifest`, `service-worker.js`: instalación PWA y recursos offline.
- `assets/models/`: modelos, miniaturas y licencias.

El modelo del gato Scratch original conserva su atribución/licencia. FaunaXR no afirma afiliación con Scratch Foundation.

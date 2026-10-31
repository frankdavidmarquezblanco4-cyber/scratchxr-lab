# SCRATCHXR LAB

**Programación por bloques en 3D, realidad aumentada y realidad virtual.** SCRATCHXR LAB es una plataforma educativa en español para estudiantes de 3.º a 9.º grado (aproximadamente de 8 a 15 años). Enseña conceptos de programación visual inspirados en Scratch mediante lecciones, teoría ilustrada, retos interactivos y experiencias 3D/XR.

La aplicación está hecha como una página estática. No necesita servidor propio, base de datos, claves API ni servicios de pago. El archivo principal es `index.html`.

## Funciones para estudiantes

- Crear perfiles locales con nombre o apodo y grado.
- Avanzar por misiones ordenadas, aprender conceptos de Scratch y escuchar el texto cuando la narración esté activada.
- Resolver quizzes, ordenar bloques y depurar programas; ganar XP, subir de nivel, mantener una racha diaria y desbloquear insignias.
- Practicar con el reto diario y consultar los cinco primeros del ranking local, si el docente habilita esas opciones.
- Explorar el modelo en 3D, probar RA en dispositivos compatibles y entrar a una escena de RV si el equipo lo permite.
- Ajustar el tamaño de letra y activar alto contraste.

## Funciones para el docente

- Entrar al panel docente para previsualizar la experiencia, editar lecciones y quizzes, revisar perfiles locales y gestionar ajustes.
- Activar o desactivar narración, ranking y reto diario.
- Importar/exportar contenido y exportar resultados de estudiantes.
- Cambiar el modelo XR predeterminado. Puede usarse una URL pública HTTPS o una ruta relativa a un modelo guardado en este repositorio.

### Acceso docente y PIN

El PIN inicial es **1234**. Para cambiarlo, entra como docente, abre **Ajustes**, escribe un PIN nuevo de 4 a 12 dígitos y guarda los ajustes.

**Importante:** al ser una aplicación estática, el PIN se verifica en el propio navegador y no es una medida de seguridad real. No uses este PIN para proteger información privada y no publiques en el código un PIN que quieras mantener secreto.

## Estructura del repositorio

```text
scratchxr-lab/
├── index.html             # Aplicación completa
├── README.md              # Esta guía
├── .nojekyll              # Archivo vacío; evita el procesamiento de Jekyll
└── assets/
    └── models/            # Opcional: añade aquí tus modelos .glb
        └── mascota.glb    # Ejemplo; sustituir por tu archivo propio
```

No se incluye un modelo propio en este repositorio. La carpeta `assets/models/` solo es necesaria si quieres añadir un `.glb`; GitHub no publica carpetas vacías, así que sube dentro el archivo del modelo (o un `.gitkeep` temporal si quieres crear la carpeta antes).

El favicon está incrustado como SVG en el `index.html`. Los scripts externos se cargan mediante HTTPS con versiones fijas: model-viewer 4.0.0 y A-Frame 1.7.0. Las referencias a archivos propios se escriben como rutas relativas, sin una `/` inicial, para que funcionen tanto en una página de proyecto como en una página de usuario/organización.

## Requisitos para 3D, RA y RV

- **3D:** navegador moderno con WebGL y conexión para cargar las librerías CDN. En esta página el modelo de ejemplo se descarga desde el sitio de model-viewer.
- **RA:** abre el sitio mediante HTTPS (GitHub Pages lo proporciona), usa un teléfono/tableta y un navegador con modo AR compatible. El dispositivo debe admitir la vía disponible (WebXR, Scene Viewer en Android o Quick Look en iOS) y el usuario debe permitir el acceso a la cámara cuando el navegador lo solicite. Si el equipo no lo admite, SCRATCHXR LAB informa que la RA no está disponible y conserva el visor 3D; no simula RA.
- **RV:** se requiere un visor XR compatible y un navegador que ofrezca WebXR inmersivo. La disponibilidad depende del sistema, el navegador, el dispositivo y sus permisos; sin visor compatible se puede recorrer la escena 3D en pantalla.
- **Seguridad:** RA/RV y otras funciones del navegador pueden estar restringidas si se abre el archivo directamente desde el disco. Prueba el sitio publicado en HTTPS.

## Limitaciones de los datos

Los perfiles, XP, progreso, lecciones, quizzes y ajustes se guardan en `localStorage` del navegador y dispositivo que se está usando. No se sincronizan entre equipos ni se envían a un servidor. Borrar los datos del navegador puede eliminarlos. El docente puede exportar/importar contenido y resultados para trasladarlos manualmente; la aplicación no sincroniza automáticamente esos archivos.

## Publicar en GitHub Pages desde la web de GitHub

1. Entra en [github.com](https://github.com) e inicia sesión o crea una cuenta.
2. Pulsa **New repository** (Nuevo repositorio), escribe un nombre, por ejemplo `scratchxr-lab`, y crea el repositorio. Para simplificar, créalo como público.
3. Abre el repositorio. Pulsa **Add file > Upload files** (Añadir archivo > Subir archivos).
4. Arrastra `index.html`, `README.md` y `.nojekyll` desde tu computador al área de carga. Si usarás un modelo propio, crea antes la carpeta `assets/models/` en tu computador, coloca allí el `.glb` y sube también esa carpeta con su archivo.
5. Baja hasta **Commit changes** (Confirmar cambios), escribe un mensaje, por ejemplo `Publicar SCRATCHXR LAB`, y pulsa **Commit changes**.
6. En el repositorio abre **Settings > Pages**.
7. En **Build and deployment**, elige **Deploy from a branch**.
8. En **Branch**, selecciona `main` y la carpeta **/ (root)**; después pulsa **Save**.
9. Espera a que termine la publicación. En **Settings > Pages** aparecerá la dirección del sitio. Ábrela en una pestaña nueva y verifica que se carga por HTTPS.
10. Para actualizar el sitio, abre el repositorio y sube el `index.html` corregido mediante **Add file > Upload files** (acepta reemplazar el archivo existente). Confirma el cambio con **Commit changes**. GitHub Pages volverá a publicar el sitio; recarga la dirección cuando termine.

Los nombres de los menús de GitHub pueden variar ligeramente según el idioma de la interfaz. Mantén `index.html` en la raíz del repositorio y selecciona exactamente `main` y `/ (root)` en Pages.

## Usar modelos `.glb` propios sin CORS

1. Añade tu modelo, por ejemplo `mascota.glb`, en `assets/models/` y sube el archivo al repositorio.
2. En SCRATCHXR LAB entra como docente, abre **Ajustes** y escribe esta ruta relativa: `assets/models/mascota.glb`.
3. Pulsa **Guardar ajustes**. La ruta es relativa a `index.html`, por lo que en GitHub Pages se resolverá dentro del mismo sitio, incluso si este se publica bajo una ruta de proyecto como `/scratchxr-lab/`.
4. También puedes cambiar el modelo inicial del código para que todas las instalaciones nuevas lo usen por defecto: localiza la constante `DEFAULT_MODEL_URL` (o el valor `defaultModelUrl` del objeto inicial de ajustes) en `index.html` y pon `assets/models/mascota.glb`; guarda, vuelve a subir `index.html` y confirma el cambio.
5. El nombre y las mayúsculas deben coincidir exactamente con los del archivo. Usa rutas como `assets/models/mi-modelo.glb`, no `/assets/models/mi-modelo.glb`, no `../...` y no una ruta local de tu computador.

Una ruta relativa del mismo repositorio mantiene el modelo en el mismo origen que la página y normalmente evita los bloqueos CORS de servidores de terceros. El archivo GLB debe estar incluido en el repositorio publicado; no basta con guardarlo en tu computador.

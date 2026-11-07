# Audios de misiones · ScratchXR Lab

Añade aquí un MP3 por misión. Al pulsar **Escuchar**, la página busca el archivo del mismo ID en esta carpeta. Si no existe o no puede reproducirse, utiliza la voz del navegador de la fase 1-C. Los nombres distinguen mayúsculas/minúsculas.

## Archivos exactos de las misiones incluidas

### Grado 3
- `g3-m1.mp3`
- `g3-m2.mp3`
- `g3-m3.mp3`
- `g3-m4.mp3`
- `g3-m5.mp3`
- `g3-m6.mp3`

### Grado 4
- `g4-m1.mp3`
- `g4-m2.mp3`
- `g4-m3.mp3`
- `g4-m4.mp3`
- `g4-m5.mp3`
- `g4-m6.mp3`

### Grado 5
- `g5-m1.mp3`
- `g5-m2.mp3`
- `g5-m3.mp3`
- `g5-m4.mp3`
- `g5-m5.mp3`
- `g5-m6.mp3`

### Grado 6
- `g6-m1.mp3`
- `g6-m2.mp3`
- `g6-m3.mp3`
- `g6-m4.mp3`
- `g6-m5.mp3`
- `g6-m6.mp3`

### Grado 7
- `g7-m1.mp3`
- `g7-m2.mp3`
- `g7-m3.mp3`
- `g7-m4.mp3`
- `g7-m5.mp3`
- `g7-m6.mp3`

### Grado 8
- `g8-m1.mp3`
- `g8-m2.mp3`
- `g8-m3.mp3`
- `g8-m4.mp3`
- `g8-m5.mp3`
- `g8-m6.mp3`

### Grado 9
- `mision-g9-01.mp3`

### Grado 10
- `mision-g10-01.mp3`

### Grado 11
- `mision-g11-01.mp3`

Para una misión creada por un docente, usa su ID interno exacto como nombre: `<id-de-la-misión>.mp3`. El identificador debe contener solo letras, números, guion o guion bajo.

## Formato sugerido

- MP3, voz clara en español, mono, 44,1 kHz y 96–128 kb/s; sin música de fondo ni silencios largos. Mantén la misma voz, acento y velocidad en todos los archivos.
- Para que el MP3 sustituya exactamente la narración de la misión, incluye en orden: título, texto de la misión, pasos de la actividad y cierre. Usa el texto actual que aparece en la página.
- Comprueba cada archivo con auriculares y a volumen normal. Un audio pregrabado no cambia al editar la misión; vuelve a generarlo si modificas su contenido.

## Herramienta de voz de buena calidad

Una opción sencilla es [ElevenLabs Text to Speech](https://elevenlabs.io/docs/eleven-creative/playground/text-to-speech): elige una voz nativa en español (es-ES o es-MX), usa un modelo multilingüe, pega una misión, genera y descarga el resultado en MP3. La documentación indica que la selección de voz es el factor más importante y recomienda usar una voz nativa del idioma objetivo. Revisa el plan y las condiciones de uso antes de publicar; ElevenLabs señala que el uso comercial requiere un plan de pago. Si prefieres una herramienta de nube, [Google Cloud Text-to-Speech](https://docs.cloud.google.com/text-to-speech/docs/list-voices-and-types) permite seleccionar voces por idioma, como es-ES.

## Publicar en GitHub

1. En el repositorio abre `assets/audio/` (la carpeta queda creada al subir este README).
2. Selecciona **Add file → Upload files** y carga los MP3 correspondientes. Asegúrate de que el nombre coincida letra por letra con un ID de la lista.
3. Confirma el cambio con **Commit changes** en la rama que publica GitHub Pages.
4. Espera a que termine el despliegue y prueba **Escuchar** en cada misión. Los MP3 grandes pueden tardar en cargar; optimízalos antes de subir.

También puedes clonar el repositorio y ejecutar:

```bash
git add assets/audio/*.mp3
git commit -m "Add mission narration audio"
git push

```

Para incorporar o actualizar misiones, revisa su `id` en los datos de la página y crea el nombre MP3 con ese mismo valor.

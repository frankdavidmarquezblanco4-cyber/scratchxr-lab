# Informes y calificación de avances · SCRATCHXR LAB

## Filtros e informes del panel docente

En **Panel docente → Estudiantes**, el informe se puede filtrar por **grado**, **estudiante** y periodo: todo el historial fechado, últimos 7 días, últimos 30 días, este mes o un rango de fechas personalizado. La tabla, sus promedios y la descarga CSV respetan la selección. **Imprimir resumen** prepara una hoja apaisada con filtros aplicados, cantidad de estudiantes, estudiantes activos en el periodo, total y promedio de actividades fechadas, nota acumulada promedio y desglose por estudiante. Desde la vista de impresión se puede imprimir o guardar como PDF.

La descarga se llama `informe-avances-scratchxr.csv`. Usa punto y coma como separador y coma decimal para Excel con configuración regional en español. Contiene los datos acumulados que ya se exportaban, los conteos por periodo, la última actividad y el detalle fechado de eventos que caen dentro del rango elegido. Solo incluye perfiles guardados en ese navegador/dispositivo; no consulta datos de Supabase.

## Cómo se calcula la nota acumulada

`Nota = 1 + 9 × (actividades completadas ÷ actividades disponibles)`, redondeada a un decimal y limitada a 10,0.

- **Misiones:** cuenta cada misión completada que corresponde al grado del perfil, de entre las misiones disponibles para ese grado.
- **Quizzes/ejercicios:** suma las respuestas correctas del mejor intento guardado en cada quiz habilitado para el grado. Cada pregunta correcta equivale a una actividad.
- **Retos/juegos:** cuenta cada reto o juego habilitado para el grado que se haya resuelto, una sola vez.
- El denominador suma las misiones, preguntas de quizzes y retos/juegos disponibles para ese grado. La elegibilidad de quizzes y juegos incluye los que la aplicación permite jugar hasta ese grado.
- Sin actividades registradas la nota es 1,0; con todas las actividades disponibles completadas es 10,0. El porcentaje muestra la proporción completada aparte de la escala de calificación.

Esta nota es **acumulada**: el filtro de periodo no la recalcula ni la convierte en una calificación separada para ese intervalo. El informe temporal muestra cuántos eventos se registraron dentro de las fechas. Rachas y retos diarios no modifican la nota acumulada; sí aparecen, cuando tienen fecha registrada, en los conteos del periodo.

## Alcance y fechas

Desde esta versión se registra una fecha local en cada misión completada, intento de quiz, reto/juego resuelto, reto diario completado y ascenso intentado. El informe conserva hasta los **1.000 eventos fechados más recientes por perfil**.

Los perfiles anteriores conservan su progreso acumulado, pero misiones, juegos e intentos antiguos no tenían historial de fechas. Por eso no se les asigna una fecha ficticia y no aparecerán en filtros temporales; sí siguen contando en la tabla y la nota acumuladas. La selección **Todo el historial fechado** incluye todos los eventos con fecha disponibles desde la activación de esta función, no reconstruye el pasado anterior.

El registro de fechas es local a cada navegador y no se sincroniza con Supabase. La exportación y la vista de impresión tampoco suben los informes a un servidor. Se exportan los apodos existentes; evita introducir nombres completos u otros datos identificables de menores.

## Interpretación pedagógica

La nota representa el **avance que ScratchXR tiene registrado**, no una evaluación integral del aprendizaje. Las actividades cuentan como unidades de progreso —no se ponderan por dificultad— y los quizzes se valoran por respuestas correctas del mejor intento, no por cantidad de intentos. Se recomienda usar el desglose y las evidencias junto con el criterio docente; la calificación no sustituye la revisión cualitativa del trabajo del estudiante.

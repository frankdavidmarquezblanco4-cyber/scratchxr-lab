# Informes, plantilla y calificación · SCRATCHXR LAB

> **Documento histórico:** describe el panel docente de versiones anteriores. En la versión pública actual ese panel y sus acciones no aparecen; los perfiles y avances se guardan localmente y no se sincronizan con Supabase.

## Vista docente, filtros y documentos

En **Panel docente → Estudiantes**, se filtra por **grado**, **estudiante** y periodo: todo el historial fechado, últimos 7 días, últimos 30 días, este mes o un rango personalizado. La tabla, los promedios, la impresión y el CSV respetan esos filtros. Con una sesión Auth docente activa, el informe incorpora los perfiles aprobados y el progreso recibido desde Supabase; también conserva los perfiles locales del dispositivo. El informe remoto usa filas protegidas por RLS de la cuenta docente.

**Imprimir resumen** prepara una hoja apaisada con los filtros aplicados, cantidad de estudiantes, actividad fechada, nota acumulada promedio y desglose. Se puede imprimir o guardar como PDF. **Exportar resultados CSV** descarga `informe-avances-scratchxr.csv`, con punto y coma y coma decimal para Excel en español. La hoja incluye datos de progreso acumulado, conteos por periodo, última actividad y eventos fechados disponibles.

**Descargar plantilla de notas** genera `plantilla-notas-scratchxr.csv`, compatible con Excel. Incluye 30 filas en blanco para apodo, grado, misiones, quizzes, retos, actividades, avance, calificación y observaciones; no incluye perfiles ni datos de estudiantes. Si se filtra un grado concreto, lo preselecciona en las filas. El informe y la plantilla se generan en el navegador desde el panel docente; el rol de la interfaz oculta esas acciones al alumnado. El CSV no es un archivo binario `.xlsx`.

Los perfiles locales anteriores solo aparecen en este navegador. Los perfiles en línea aparecen después de que el docente se autentique, abra/cargue el panel de acceso y la migración Fase 12 esté instalada.

## Cálculo de la nota acumulada

`Nota = 1 + 9 × (actividades completadas ÷ actividades disponibles)`, redondeada a un decimal y limitada a 10,0.

- **Misiones:** misiones completadas disponibles para el grado del perfil.
- **Quizzes/ejercicios:** suma las respuestas correctas del mejor intento guardado en cada quiz disponible; cada pregunta correcta cuenta como una actividad.
- **Retos/juegos:** retos o juegos del grado resueltos, una sola vez.
- **Denominador:** misiones, preguntas de quizzes y retos/juegos disponibles hasta el grado correspondiente.
- Sin actividad la nota es 1,0; completarlo todo equivale a 10,0. El porcentaje de avance se muestra por separado.

La nota es acumulada: los filtros por periodo no la recalculan ni producen una calificación separada para ese intervalo. Retos diarios y rachas aparecen en el conteo temporal cuando tienen fecha, pero no cambian la nota acumulada. La nota mide el avance que ScratchXR tiene registrado, no reemplaza el juicio pedagógico ni la revisión cualitativa.

## Historial y límites

El informe admite hasta 1.000 eventos fechados por perfil. Misiones, quizzes, juegos, retos diarios y ascensos registran eventos locales; en perfiles aprobados, esos eventos recientes se sincronizan también con el progreso en línea. Los registros antiguos sin fecha no reciben fechas retrospectivas: siguen contando en el progreso acumulado, pero no en los periodos.

La plantilla está en blanco y el informe incluye apodos; evita ingresar nombres completos u otros datos identificables de menores. Para permisos, retención y seguridad de Supabase, consulta `SUPABASE_SETUP.md`.

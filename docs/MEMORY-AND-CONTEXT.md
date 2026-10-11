# Memoria y contexto de trabajo

Una conversación, un relevo de tarea y la bóveda no cumplen la misma función.
Separarlos evita saturar el contexto del agente y evita convertir información
provisional en una supuesta verdad duradera.

| Ubicación | Úsala para | No la uses para |
| --- | --- | --- |
| Sesión del asistente | Preguntas inmediatas, exploración, razonamiento provisional y resultados que aún se están comprobando. | Conservar decisiones entre días o asumir que otra sesión la recordará. |
| Relevo temporal del repositorio | Tareas largas: objetivo, archivos tocados, comandos, pruebas y bloqueo actual. | Credenciales, transcripciones completas o decisiones sin verificar. |
| Bóveda de Obsidian | Decisiones aceptadas, preferencias estables, soluciones verificadas y estado útil de un proyecto. | Registro de cada turno, borradores, salidas extensas y datos temporales. |

## Durante una tarea larga

1. Mantén el trabajo inmediato en la conversación.
2. Si la tarea requiere varias sesiones, copia `templates/project-worklog/AI-TASK-HANDOFF.md.template` a una ruta del repositorio que el equipo acuerde, como `docs/ai/AI-TASK-HANDOFF.md`.
3. Actualiza solo su objetivo, evidencia y siguiente acción. Borra o archiva el relevo cuando ya no sea útil según las normas del proyecto.
4. Cuando una conclusión esté probada y aceptada, actualiza la nota más específica de la bóveda y enlázala desde el índice correspondiente.

El relevo no forma parte de la instalación ni de la actualización de la bóveda: es opcional y pertenece al proyecto de código. Así no se propaga a todos los asistentes ni se confunde con memoria duradera.

## Recuperar el contexto de forma eficiente

Al iniciar una sesión nueva, el asistente debe leer primero el índice de la bóveda y después solo las notas relacionadas. Si hay un relevo vigente en el repositorio, puede leerlo además. No hace falta cargar todos los documentos ni reproducir una conversación anterior.

Antes de terminar una tarea, distingue explícitamente entre una **hipótesis** pendiente, una **observación** que todavía requiere validación y una **decisión confirmada** que merece memoria persistente. Nunca almacenes secretos en ninguno de los tres espacios.

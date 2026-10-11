# Protocolo de memoria compartida

## Inicio de una tarea

1. Lee `00 - Inicio.md`.
2. Decide si el historial, las preferencias o un proyecto previo son relevantes.
3. Si hay un proyecto activo, abre su nota índice y sigue solo los enlaces relevantes.
4. Busca por nombre, enlaces y etiquetas antes de concluir que no existe contexto.
5. No cargues toda la bóveda ni respondas que falta contexto sin consultar primero el índice.
6. Distingue las instrucciones vigentes de los registros históricos.

## Qué debe conservarse

- Decisiones confirmadas y su motivo.
- Preferencias estables expresadas por el usuario.
- Soluciones verificadas y reutilizables.
- Estado y próximos pasos de proyectos activos.
- Restricciones de seguridad o compatibilidad que deban respetarse en el futuro.

## Qué no debe conservarse

- Conversaciones triviales o saludos.
- Suposiciones, propuestas todavía no aceptadas o resultados sin verificar.
- Contraseñas, claves API, tokens, cookies, secretos o información de autenticación.
- Grandes volcados de registros, respuestas completas o duplicados innecesarios.

## Escritura segura

- Antes de crear una nota, busca otra equivalente por título, enlaces y etiquetas.
- Actualiza la nota existente más específica antes de crear otra.
- Usa una nota atómica cuando haya una sola decisión, aprendizaje o concepto reutilizable; conserva el estado vivo del proyecto en su índice.
- Conserva YAML, enlaces internos y codificación UTF-8.
- Enlaza toda nota nueva desde un índice pertinente y añade enlaces de retorno cuando aporten navegación real.
- No borres, renombres ni reorganices en masa sin autorización y copia de seguridad.
- Indica claramente si una afirmación es una decisión, una observación o una hipótesis pendiente.

## Final de una tarea

1. Actualiza la nota índice del proyecto si cambió su estado o próxima acción.
2. Crea o actualiza notas atómicas solo cuando exista información útil a largo plazo.
3. Comprueba que las notas nuevas estén enlazadas desde un índice y no sean duplicados.
4. Resume al usuario qué memoria se actualizó. Si no hubo nada duradero, no escribas nada.

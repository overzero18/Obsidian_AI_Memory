# Capacidades opcionales del asistente

Una bóveda es la memoria externa del asistente; una capacidad o *skill* es un procedimiento especializado para ejecutar una tarea. Son complementarias, pero el sistema funciona aunque el asistente no tenga ninguna capacidad adicional instalada.

## Cómo se combinan

1. El asistente lee el índice y recupera solo el contexto de la tarea.
2. Si dispone de una capacidad apropiada, la usa para realizar el trabajo con un método más específico.
3. Al terminar, guarda únicamente una decisión confirmada, una preferencia estable, una solución verificada o un avance útil a largo plazo.

Por ejemplo, una capacidad de análisis puede revisar un CSV local; la bóveda debe conservar la conclusión confirmada, no las filas personales ni el registro completo de ejecución.

## Principios de compatibilidad

- Las capacidades son opcionales y propias de cada herramienta o instalación. No deben ser requisito para abrir ni mantener la bóveda.
- El protocolo de la bóveda continúa siendo neutral: cualquier asistente que lea Markdown local puede seguirlo sin conocer una lista concreta de capacidades.
- Una capacidad no amplía permisos. Sigue pidiendo autorización antes de escribir fuera del ámbito autorizado, enviar información o acceder a servicios externos.
- No guardes credenciales, datos personales innecesarios ni resultados no verificados solo porque una capacidad los haya procesado.

## Selección práctica

Elige una capacidad por la necesidad, no por estar disponible:

| Necesidad | Tipo de capacidad útil | Qué conservar en la bóveda |
| --- | --- | --- |
| Interpretar datos locales | Análisis de datos | Conclusiones reproducibles y limitaciones |
| Preparar una guía | Explicación o documentación | Decisiones y pasos verificados |
| Redactar comunicación pública | Redacción o localización | Mensaje aprobado y público objetivo confirmado |
| Automatizar una acción | Automatización segura | Permisos, reversión y prueba confirmados |

Si faltan datos esenciales —por ejemplo, el público, el precio o una muestra de datos— no se deben inventar. Pide la información necesaria o limita el trabajo a una plantilla claramente marcada como pendiente.

## Para autores de adaptadores

Los adaptadores pueden indicar que una herramienta use sus capacidades disponibles cuando aporten valor, pero no deben listar capacidades privadas ni asumir que existen. Conserva el bloque administrado pequeño, explícito y compatible con instalaciones que no tengan extensiones.

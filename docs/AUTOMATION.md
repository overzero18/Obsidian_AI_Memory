# Automatizaciones seguras y revisables

Una automatización sirve para reducir trabajo repetitivo, no para ocultar efectos ni para sustituir la revisión humana. Puede implementarse con n8n, scripts del repositorio o cualquier herramienta equivalente, pero debe diseñarse antes de conectar servicios externos.

## Lista de diseño

Define por escrito, en el índice del proyecto o en una nota enlazada:

1. **Objetivo:** qué proceso repetitivo se elimina y cuál es el resultado útil.
2. **Disparador:** empieza por ejecución manual; programa un horario o evento solo cuando el flujo ya esté probado.
3. **Entradas y salidas:** origen, destino, datos mínimos necesarios y formato.
4. **Idempotencia:** una clave única, como un identificador externo, para que reintentos no creen duplicados.
5. **Permisos y secretos:** credenciales fuera de Markdown y del repositorio; concede únicamente los permisos imprescindibles.
6. **Prueba y observabilidad:** datos de prueba, registros sin información sensible y una forma clara de detectar fallos.
7. **Parada y reversión:** cómo detener el flujo y qué ocurre con datos parcialmente procesados.

## Patrón de activación

1. Diseña el flujo y revisa sus efectos.
2. Ejecútalo manualmente con datos de prueba o salidas simuladas.
3. Confirma que maneja errores y evita duplicados.
4. Revisa permisos y datos antes de conectar una cuenta real.
5. Activa un disparador automático solo con aprobación explícita y documenta dónde se configura.

El instalador de Obsidian AI Memory no crea tareas programadas, conectores de nube ni automatizaciones. Esa separación protege la bóveda y permite evaluar cada flujo según el proyecto donde se usa.

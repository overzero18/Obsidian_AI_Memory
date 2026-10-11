# Seguridad y privacidad

Este proyecto está diseñado para generar bóvedas locales vacías. No publiques tu bóveda personal como parte de una incidencia o contribución.

Antes de compartir archivos:

- elimina credenciales, rutas personales y datos identificativos;
- revisa el historial de Git, no solamente el último estado;
- sustituye ejemplos reales por datos ficticios;
- informa de vulnerabilidades de forma privada al propietario del repositorio.

## Modelo de seguridad

- La memoria es local y no incluye servidor, telemetría ni sincronización automática.
- El instalador solo administra bloques claramente delimitados en los archivos globales de cada herramienta.
- Los archivos existentes se respaldan antes de modificarse.
- `-MergeExisting` en Windows y `--merge-existing` en Linux/macOS crean una copia de la bóveda y añaden únicamente plantillas ausentes; no reemplazan notas.
- Los adaptadores no conceden permisos a la IA ni amplían por sí mismos su acceso al sistema.

Una herramienta con acceso a la bóveda podrá leer su contenido. Guarda solamente información que sea apropiada para todos los asistentes conectados y aplica permisos del sistema de archivos si necesitas separar contextos.

## Integraciones de terceros

No expongas la bóveda mediante HTTP público. Si una herramienta no puede leer archivos locales, comparte manualmente el contexto necesario o utiliza un conector local autenticado y limitado a la bóveda.

## Operaciones de mantenimiento

- `update`, `uninstall` y `migrate` muestran una simulación salvo que se proporcione explícitamente `--apply` o `-Apply`.
- La desinstalación solo elimina bloques delimitados y nunca elimina la bóveda.
- El migrador solo considera Markdown, omite `.obsidian`, conserva conflictos y no modifica las bóvedas originales.
- La detección de secretos utiliza patrones preventivos: puede tener falsos positivos y no garantiza reconocer todos los formatos.
- Revisa la salida, las copias y `git status` antes de publicar o eliminar manualmente datos antiguos.
- El modo portátil se guarda bajo `portable-data/`, que está excluido de Git; comprueba igualmente el contenido del archivo ZIP antes de compartirlo.

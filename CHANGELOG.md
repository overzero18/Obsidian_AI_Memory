# Historial de cambios

## 2.1.2 - 2026-10-11

### Añadido

- `bootstrap.sh` para Linux y macOS: descarga el último paquete publicado, verifica SHA-256 y ejecuta el instalador normal sin requerir Git.
- El modo portátil iniciado desde `bootstrap.sh` conserva su carpeta en el directorio actual, en vez de usar una ubicación temporal.
- La publicación incluye de forma comprobable los nombres estables que usa el iniciador, además de los archivos versionados.
- Bóveda única y neutral para Codex, Claude y asistentes compatibles con Markdown local.
- Instalación segura en Windows, Linux y macOS.
- Protocolo de memoria, incorporación genérica y plantillas de notas atómicas.
- `memoryctl doctor` para revisar instalación, enlaces, notas huérfanas, copias y posibles secretos.
- `memoryctl update` con simulación, respaldos y protección de notas personales.
- `memoryctl uninstall` para retirar exclusivamente bloques administrados.
- `memoryctl migrate` para combinar de forma conservadora las antiguas bóvedas `ChatGptIA` y `ClaudeIA`.
- Pruebas de instalación, reinstalación, actualización, migración y desconexión en Windows, Ubuntu y macOS.
- Modo portátil que no toca configuraciones globales y se excluye de Git.
- Adaptadores opcionales por proyecto para Gemini CLI, Windsurf y GitHub Copilot.
- Guía de recuperación y flujo de publicación que genera archivo ZIP con SHA-256.
- Guía de publicación con comprobaciones de privacidad, versión, etiqueta y verificación de descarga.
- Diagnóstico configurable para bóvedas con índice o ubicación de copias personalizados.

### Cambiado

- La compatibilidad distingue claramente los adaptadores automáticos, los manuales y las herramientas que usan la incorporación genérica.
- El paquete de cada versión también publica nombres de descarga estables para la instalación sencilla en Linux y macOS.
- Las configuraciones globales ya no se reemplazan: se administran mediante bloques delimitados.
- Las actualizaciones de una bóveda existente conservan sus notas, índices y preferencias.
- La documentación y el nombre visible del producto pasan de Windows a multiplataforma.

### Seguridad

- Copias fechadas antes de operaciones que escriben sobre archivos existentes.
- Migración bloqueada cuando aparecen patrones comunes de secretos.
- Operaciones de actualización, desconexión y migración en modo simulación por defecto.

### Migración

- Las bóvedas de la primera versión no se borran ni fusionan automáticamente.
- Consulta `docs/MIGRATION.md` antes de aplicar la migración.

# Historial de cambios

## 2.6.1 - 2026-10-11

### Seguridad

- Los instaladores de Windows, Linux y macOS validan los marcadores de los bloques administrados antes de realizar cualquier cambio. Si falta uno, abortan sin crear la bóveda ni modificar configuraciones.
- Añadido modelo de límites de confianza y permisos, incluida la advertencia ante instrucciones no confiables dentro de notas Markdown.

### Pruebas

- Añadidas pruebas de regresión para configuraciones con bloques administrados incompletos.

## 2.6.0 - 2026-10-11

### Añadido

- Adaptador opcional y manual por proyecto para OpenCode, basado en `AGENTS.md` y sin modificar reglas globales ni sobrescribir instrucciones existentes.
- Guía para separar el contexto temporal de una sesión, los relevos de tareas largas en el repositorio y la memoria duradera de la bóveda.
- Plantillas para relevo de tarea y creación de proyectos de software, con definición de MVP, criterios de aceptación, plan de pruebas y automatización opcional.
- Verificación funcional guiada para comprobar que un asistente recupera una decisión confirmada desde una sesión nueva.
- Guía para diseñar automatizaciones seguras, revisables e idempotentes antes de conectarlas a servicios externos.

### Seguridad

- La integración de OpenCode exige conservar cualquier `AGENTS.md` ya existente y revisar las rutas locales antes de compartirlas.
- Las automatizaciones propuestas son manuales por defecto, no incluyen credenciales y requieren definir una prueba y una reversión antes de activarse.

## 2.5.0 - 2026-10-11

### Añadido

- Demostración visual del flujo seguro y guía [Primeros 5 minutos](docs/FIRST-5-MINUTES.md) para nuevas instalaciones.
- Snoop, un beagle de pelo corto como mascota y emblema original del proyecto, incluido en el README y distribuido bajo MIT.
- Menú interactivo seguro y comando `status` de solo lectura en los lanzadores de Windows, Linux y macOS.
- Lanzador permanente `obsidian-memory` / `obsidian-memory.cmd` junto a cada instalación, con sus herramientas de mantenimiento incluidas.
- Explicación visible al terminar la instalación y en el README: operaciones automáticas, manuales, de solo lectura y con confirmación explícita.
- El lanzador Windows acepta la lista de adaptadores configurada por el instalador.
- La ayuda integrada explica en español qué hace cada comando, qué nunca se automatiza y cuándo se necesita confirmación explícita.
- `bootstrap.sh` para Linux y macOS: descarga el último paquete publicado, verifica SHA-256 y ejecuta el instalador normal sin requerir Git.
- El modo portátil iniciado desde `bootstrap.sh` conserva su carpeta en el directorio actual, en vez de usar una ubicación temporal.
- La publicación incluye de forma comprobable los nombres estables que usa el iniciador, además de los archivos versionados.
- El iniciador consulta la etiqueta actual mediante la API de GitHub y evita la caché temporal de la ruta `releases/latest/download`.
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

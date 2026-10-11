# Primeros 5 minutos

Esta guía deja una bóveda local lista para Codex, Claude Code u otra IA compatible con archivos Markdown. No crea cuentas, no sincroniza tus notas y no programa tareas automáticas.

## 1. Instala

En Windows, descarga el ZIP de la [última versión](https://github.com/overzero18/obsidian-ai-memory-windows/releases/latest), extráelo y abre `INSTALL.cmd`.

En Linux o macOS, copia y ejecuta:

```bash
curl -fsSLO https://raw.githubusercontent.com/overzero18/obsidian-ai-memory-windows/main/bootstrap.sh
sh bootstrap.sh
```

El instalador crea `MemoriaIA`, conserva configuraciones existentes y hace una copia fechada antes de modificar un archivo que ya exista.

## 2. Abre la bóveda en Obsidian

Abre la carpeta `MemoriaIA` como bóveda. Por defecto está en:

- Windows: `%USERPROFILE%\Documents\ObsidianAI\MemoriaIA`
- Linux/macOS: `~/Documents/ObsidianAI/MemoriaIA`

No hace falta instalar complementos de Obsidian.

## 3. Comprueba la instalación

Linux/macOS:

```bash
~/Documents/ObsidianAI/obsidian-memory doctor
```

Windows PowerShell:

```powershell
& "$HOME\Documents\ObsidianAI\obsidian-memory.cmd" doctor
```

`doctor` solo lee y revisa: no edita ni borra archivos. Si todo está correcto, reinicia Codex o Claude Code para que recarguen sus instrucciones.

## 4. Crea tu primer proyecto

Dentro de la bóveda, abre `Plantillas/Plantilla - Proyecto con grafo.md`, crea una copia en `Proyectos/` y ponle un nombre claro. Enlázalo desde `Proyectos/00 - Proyectos.md`.

Después dile a tu IA el proyecto con el que vas a trabajar. La IA debe consultar primero el índice y solo las notas relacionadas.

## 5. Verifica que la memoria funciona entre sesiones

Dentro de tu proyecto, registra una decisión real y confirmada en su índice; por
ejemplo, una tecnología elegida y el motivo. Cierra o inicia una sesión nueva del
asistente y pídele que resuma las decisiones conocidas de ese proyecto. Debe
consultar el índice y recuperar la nota pertinente, sin cargar toda la bóveda.

No uses contraseñas, datos personales ni información sensible para esta prueba.
Si el asistente no puede acceder a los archivos locales, usa la instrucción de
`AI-ONBOARDING.md` o comprueba el adaptador elegido. La guía completa está en
[Verificación funcional](VERIFY-INTEGRATION.md).

## 6. Qué guardar y qué no

Guarda decisiones confirmadas, preferencias estables, soluciones verificadas y estado útil de los proyectos. No guardes contraseñas, tokens, cookies, claves API ni conversaciones completas.

Para ver un resumen sin cambios, ejecuta `obsidian-memory status`. Para ver el menú de mantenimiento, ejecuta `obsidian-memory` sin argumentos.

## Cuando necesites más

- [Mantenimiento](MAINTENANCE.md): diagnóstico, actualización, migración y desconexión segura.
- [Adaptadores](ADAPTERS.md): OpenCode, Gemini CLI, Windsurf y GitHub Copilot.
- [Memoria y contexto de trabajo](MEMORY-AND-CONTEXT.md): límites entre sesión, relevo y bóveda duradera.
- [Verificación funcional](VERIFY-INTEGRATION.md): comprobar la recuperación de contexto entre sesiones.
- [Proyectos de software](SOFTWARE-PROJECTS.md): definir un MVP, criterios de aceptación, pruebas y automatización opcional.
- [Automatizaciones](AUTOMATION.md): diseñar flujos seguros y revisables antes de conectarlos.
- [Recuperación](RECOVERY.md): consultar y restaurar copias fechadas.

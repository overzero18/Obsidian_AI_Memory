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

## 5. Qué guardar y qué no

Guarda decisiones confirmadas, preferencias estables, soluciones verificadas y estado útil de los proyectos. No guardes contraseñas, tokens, cookies, claves API ni conversaciones completas.

Para ver un resumen sin cambios, ejecuta `obsidian-memory status`. Para ver el menú de mantenimiento, ejecuta `obsidian-memory` sin argumentos.

## Cuando necesites más

- [Mantenimiento](MAINTENANCE.md): diagnóstico, actualización, migración y desconexión segura.
- [Adaptadores](ADAPTERS.md): Gemini CLI, Windsurf y GitHub Copilot.
- [Recuperación](RECOVERY.md): consultar y restaurar copias fechadas.

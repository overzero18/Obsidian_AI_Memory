# Adaptadores opcionales por proyecto

Los adaptadores opcionales se copian manualmente dentro del proyecto que debe usar la memoria. No se instalan de forma global ni se modifican configuraciones existentes.

1. Copia una plantilla.
2. Sustituye `{{VAULT_PATH}}` por la ruta absoluta de la bóveda.
3. Comprueba el archivo en el control de versiones antes de compartirlo: la ruta puede revelar un nombre de usuario o una unidad local.

## OpenCode

OpenCode reconoce `AGENTS.md` en la raíz del proyecto. Copia
`templates/project-adapters/opencode-AGENTS.md.template` como `AGENTS.md` **solo
si el proyecto todavía no tiene ese archivo**.

Si ya existe, no lo reemplaces: incorpora manualmente el bloque de la plantilla
en sus instrucciones actuales y conserva las reglas del proyecto. Sustituye
`{{VAULT_PATH}}` por la ruta absoluta de la bóveda. Este adaptador es por
proyecto; no modifica `~/.config/opencode/AGENTS.md` ni ninguna configuración
global. Consulta la [documentación oficial de reglas de OpenCode](https://docs.opencode.ai/docs/rules/).

## Gemini CLI

Copia `templates/project-adapters/GEMINI.md.template` como `GEMINI.md` en la raíz del proyecto. Gemini CLI reconoce por defecto los archivos de contexto `GEMINI.md`. Consulta la [guía oficial](https://geminicli.com/docs/cli/gemini-md/).

## Windsurf

Usa `templates/project-adapters/windsurf-obsidian-memory.md.template` como `.devin/rules/obsidian-memory.md`. La documentación de Windsurf indica `.devin/rules/*.md` como ubicación preferida y `.windsurf/rules/*.md` como compatibilidad heredada. Consulta la [guía oficial](https://docs.windsurf.com/windsurf/cascade/memories).

## GitHub Copilot

Copia `templates/project-adapters/copilot-instructions.md.template` como `.github/copilot-instructions.md`. Consulta la [guía oficial](https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions).

## Cursor, Cline y otras herramientas

Usa `AI-ONBOARDING.md` como instrucción manual hasta verificar la ruta exacta de la versión instalada. No se crean archivos de configuración no comprobados.

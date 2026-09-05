# Obsidian AI Memory for Windows

Instalador para usar dos bóvedas locales de Obsidian como memoria persistente de [Codex](https://learn.chatgpt.com/docs/agent-configuration/agents-md) y [Claude Code](https://code.claude.com/docs/en/memory) en Windows 11.

El repositorio contiene únicamente plantillas vacías. No incluye notas, proyectos, credenciales ni rutas personales.

## Qué instala

- Una bóveda para Codex con instrucciones `AGENTS.md`.
- Una bóveda para Claude Code con instrucciones `CLAUDE.md`.
- Instrucciones globales en `%USERPROFILE%\.codex\AGENTS.md`.
- Instrucciones globales en `%USERPROFILE%\.claude\CLAUDE.md`.

## Instalación

1. Descarga o clona este repositorio.
2. Haz doble clic en `INSTALL.cmd` para usar la ubicación predeterminada.

También puedes abrir PowerShell dentro de la carpeta y ejecutar:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Install-ObsidianAIMemory.ps1
```

Por defecto crea las bóvedas en `%USERPROFILE%\Documents\ObsidianAI`. Para elegir otra ruta:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Install-ObsidianAIMemory.ps1 -BasePath "G:\Obsidian\AI"
```

Si las carpetas ya contienen archivos, el instalador se detiene. Para combinarlas de forma consciente, creando antes una copia completa:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Install-ObsidianAIMemory.ps1 -BasePath "G:\Obsidian\AI" -MergeExisting
```

Después, abre las dos carpetas creadas como bóvedas en Obsidian y reinicia Codex y Claude Code.

## Privacidad

- Revisa siempre `git status` antes de publicar cambios.
- No copies una bóveda real dentro de este repositorio.
- Nunca guardes contraseñas, tokens, claves API o historiales privados.
- `.gitignore` bloquea nombres habituales de bóvedas, configuración local y secretos, pero no sustituye una revisión manual.

## Desinstalación

El instalador informa de todas las rutas creadas. Antes de eliminar nada, conserva las notas que quieras guardar. Las configuraciones globales anteriores se respaldan con fecha y hora.

## Licencia

[MIT](LICENSE)

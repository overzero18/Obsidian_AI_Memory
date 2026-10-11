# Mantenimiento

`memoryctl` reúne las operaciones de diagnóstico, actualización, desconexión y migración. Los comandos que pueden escribir funcionan en modo simulación salvo que se indique explícitamente `--apply` en Linux/macOS o `-Apply` en Windows.

## Diagnóstico

Linux y macOS:

```bash
./scripts/memoryctl.sh doctor
```

Windows PowerShell:

```powershell
.\scripts\MemoryCtl.ps1 doctor
```

El diagnóstico comprueba:

- existencia de la bóveda y de sus archivos fundamentales;
- referencia a la bóveda desde los adaptadores seleccionados;
- enlaces internos rotos y posibles notas huérfanas;
- patrones comunes de tokens, claves privadas y contraseñas;
- presencia de copias de seguridad.

Los avisos no modifican archivos. Un error en un archivo obligatorio produce un código de salida distinto de cero, por lo que el comando puede utilizarse en automatizaciones.

La detección de secretos es preventiva y puede producir falsos positivos o no reconocer formatos desconocidos. No sustituye una revisión manual.

## Actualización segura

Primero muestra los cambios:

```bash
./scripts/memoryctl.sh update
```

```powershell
.\scripts\MemoryCtl.ps1 update
```

Para aplicarlos:

```bash
./scripts/memoryctl.sh update --apply
```

```powershell
.\scripts\MemoryCtl.ps1 update -Apply
```

La actualización:

- renueva el protocolo, la incorporación genérica y las plantillas administradas;
- actualiza los bloques administrados de Codex y Claude;
- crea copias antes de reemplazar archivos;
- no reemplaza índices, preferencias ni notas del usuario;
- no borra archivos.

Los archivos administrados pueden personalizarse, pero una actualización aplicada sustituirá su contenido después de respaldarlo. Las reglas personales deben conservarse en `AGENTS.md`, `CLAUDE.md`, los índices o notas propias.

## Desconexión segura

Simulación:

```bash
./scripts/memoryctl.sh uninstall
```

```powershell
.\scripts\MemoryCtl.ps1 uninstall
```

Aplicación:

```bash
./scripts/memoryctl.sh uninstall --apply
```

```powershell
.\scripts\MemoryCtl.ps1 uninstall -Apply
```

Solo se eliminan los bloques comprendidos entre `OBSIDIAN-AI-MEMORY:START` y `OBSIDIAN-AI-MEMORY:END`. Antes se respaldan los archivos globales. La bóveda y las demás instrucciones nunca se eliminan.

## Opciones comunes

```text
--base-path PATH / -BasePath PATH
--vault-name NAME / -VaultName NAME
--index-file FILE / -IndexFile FILE
--backup-path PATH / -BackupPath PATH
--tools LIST / -Tools Codex,Claude,Generic
--portable / -Portable
```

Ejemplo con una ubicación personalizada:

```bash
./scripts/memoryctl.sh doctor --base-path "$HOME/Obsidian" --vault-name MiMemoria
```

```powershell
.\scripts\MemoryCtl.ps1 doctor -BasePath "G:\Obsidian" -VaultName "MiMemoria"
```

Si una bóveda usa otro índice raíz, indícalo sin renombrar archivos:

```bash
./scripts/memoryctl.sh doctor --index-file "00 - Inicio Linux.md"
```

```powershell
.\scripts\MemoryCtl.ps1 doctor -IndexFile "00 - Inicio Linux.md"
```

Para diagnosticar una instalación portátil:

```bash
./scripts/memoryctl.sh doctor --portable
```

```powershell
.\scripts\MemoryCtl.ps1 doctor -Portable
```

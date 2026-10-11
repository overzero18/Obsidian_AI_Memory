# Preparar una publicación

## Antes de crear la versión

1. Ejecuta las pruebas locales disponibles:

   ```bash
   ./tests/install-obsidian-ai-memory.test.sh
   ```

   ```powershell
   .\tests\Validate-Templates.ps1
   .\tests\Install-ObsidianAIMemory.Tests.ps1
   ```

2. Revisa `git status`, `git diff --check` y el historial antes de publicar.
3. Confirma que no hay rutas personales, bóvedas, secretos ni `portable-data/` en los cambios.
4. Comprueba que la publicación incluye los paquetes versionados y los nombres estables `obsidian-ai-memory.zip` y `obsidian-ai-memory.zip.sha256`, usados por `bootstrap.sh`.
4. Actualiza `VERSION` y `CHANGELOG.md`.
5. Haz commit de todos los archivos de la versión.

## Etiqueta y paquete

La etiqueta debe corresponder con `VERSION`, por ejemplo `v2.0.0`.

```bash
git tag -a v2.0.0 -m "Obsidian AI Memory 2.0.0"
git push origin v2.0.0
```

El flujo de publicación crea un ZIP desde el commit etiquetado y un archivo `.sha256`. El archivo es universal: contiene los scripts de Windows, Linux y macOS. GitHub genera las notas de la versión.

## Verificar una descarga

Linux y macOS:

```bash
sha256sum -c obsidian-ai-memory-v2.0.0.zip.sha256
```

Windows PowerShell:

```powershell
(Get-FileHash .\obsidian-ai-memory-v2.0.0.zip -Algorithm SHA256).Hash
Get-Content .\obsidian-ai-memory-v2.0.0.zip.sha256
```

Compara ambos hashes. El checksum comprueba integridad; no sustituye la revisión del código ni una firma criptográfica de una identidad.

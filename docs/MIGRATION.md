# Migración desde ChatGptIA y ClaudeIA

El migrador detecta las bóvedas antiguas `ChatGptIA` y `ClaudeIA` dentro de la carpeta base y combina únicamente sus archivos Markdown con `MemoriaIA`.

## Garantías

- La primera ejecución es siempre una simulación.
- La bóveda de destino se respalda antes de copiar.
- Las bóvedas antiguas no se modifican ni eliminan.
- Los archivos idénticos se clasifican como duplicados y no vuelven a copiarse.
- Los archivos con la misma ruta y contenido diferente se clasifican como conflictos y no se reemplazan.
- `.obsidian` y los archivos que no sean Markdown quedan fuera de la migración.
- Si se detectan patrones de posibles secretos, la migración se detiene antes de copiar.

## Simulación

Linux y macOS:

```bash
./scripts/memoryctl.sh migrate
```

Windows:

```powershell
.\scripts\MemoryCtl.ps1 migrate
```

La salida utiliza `ADD`, `DUPLICATE` y `CONFLICT` para mostrar lo que ocurriría.

## Aplicación

Revisa primero toda la simulación. Después:

```bash
./scripts/memoryctl.sh migrate --apply
```

```powershell
.\scripts\MemoryCtl.ps1 migrate -Apply
```

Para buscar las bóvedas antiguas en otra ubicación:

```bash
./scripts/memoryctl.sh migrate --source-root "/ruta/antigua" --apply
```

```powershell
.\scripts\MemoryCtl.ps1 migrate -SourceRoot "D:\ObsidianAntiguo" -Apply
```

## Después de migrar

1. Ejecuta `doctor` sobre la bóveda compartida.
2. Revisa los conflictos manualmente.
3. Enlaza desde los índices las notas importadas que quieras conservar.
4. Conserva las bóvedas originales hasta verificar el resultado y la copia de seguridad.

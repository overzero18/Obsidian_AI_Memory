# Recuperación y copias de seguridad

Todas las operaciones que modifican archivos existentes crean una copia fechada bajo `backups/` en la carpeta base. Antes de restaurar, ejecuta `doctor` y revisa la copia elegida.

## Restauración manual

1. Cierra las herramientas de IA que puedan editar la configuración.
2. Copia el archivo concreto desde `backups/<fecha>/` a su ubicación original.
3. Para restaurar una bóveda completa, copia su carpeta respaldada a una ubicación nueva primero y revisa las notas antes de reemplazar nada.
4. Ejecuta `doctor` de nuevo.

No existe restauración automática porque sustituir una bóveda completa puede descartar cambios posteriores. Las pruebas automatizadas comprueban que los respaldos creados por actualización, migración y desconexión contienen los archivos modificados.

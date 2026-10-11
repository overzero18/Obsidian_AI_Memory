# Verificación funcional de la memoria

`obsidian-memory doctor` comprueba archivos, adaptadores, enlaces, copias y patrones comunes de secretos. Esta guía verifica además el comportamiento que importa a una persona usuaria: que una sesión nueva pueda recuperar contexto duradero sin depender del historial del chat.

## Antes de empezar

- Ejecuta `obsidian-memory doctor` y resuelve los errores que informe.
- Reinicia la herramienta de IA después de instalar o cambiar un adaptador.
- Usa una decisión real ya confirmada. No introduzcas secretos ni datos privados solo para probar el sistema.

## Prueba en cinco pasos

1. Abre un proyecto existente en `Proyectos/` o crea uno con la plantilla.
2. Registra una decisión breve y verificable en el índice o en una nota enlazada: qué se eligió, por qué y cuándo.
3. Termina la sesión actual del asistente e inicia otra desde el mismo proyecto.
4. Pide: “Resume las decisiones conocidas de este proyecto y di qué nota has consultado”.
5. Comprueba que abre el índice primero, sigue solo enlaces pertinentes y recupera la decisión sin inventar detalles.

## Si falla

- Comprueba que la ruta de la bóveda del adaptador es absoluta y correcta.
- Revisa que el índice del proyecto enlaza la nota que contiene la decisión.
- Ejecuta `doctor` de nuevo; su salida es de solo lectura.
- Para OpenCode, confirma que integraste el bloque de la plantilla en el `AGENTS.md` del proyecto sin reemplazar reglas previas.
- Para una herramienta sin adaptador comprobado, entrega `AI-ONBOARDING.md` junto con la ruta de la bóveda.

Una recuperación correcta no significa que el asistente recuerde una conversación completa: demuestra que sabe consultar la fuente local de verdad cuando esa información resulta relevante.

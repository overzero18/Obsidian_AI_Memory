# Crear un proyecto de software con memoria compartida

La bóveda ayuda a conservar el contexto del producto; no sustituye el análisis, la revisión de código ni las pruebas. Para una aplicación nueva, empieza con `Plantillas/Plantilla - Proyecto de software.md` en vez de pedir “crea una app” sin límites ni criterios de éxito.

## Flujo recomendado

1. **Define el MVP.** Escribe quién tiene el problema, el resultado mínimo útil y lo que queda fuera de esta entrega.
2. **Convierte el objetivo en criterios de aceptación.** Incluye el flujo feliz, errores esperados y resultados observables. El formato Dado-Cuando-Entonces ayuda a que personas y agentes interpreten lo mismo.
3. **Decide el stack con un motivo.** Registra versiones, restricciones de despliegue, datos y alternativas descartadas. No dejes que el agente elija una tecnología sin requisitos.
4. **Pide un plan antes de editar.** Para arquitectura, cambios de varias capas o dependencias nuevas, revisa el plan y aprueba entregas pequeñas.
5. **Implementa y verifica.** Actualiza las pruebas de comportamiento, ejecuta pruebas, lint y compilación cuando existan, y revisa el diff antes de dar por finalizado el trabajo.
6. **Conserva solo lo duradero.** Promociona a la bóveda decisiones confirmadas, soluciones comprobadas, estado y bloqueos; usa el relevo del repositorio para detalles temporales de una tarea larga.

## Instrucción útil para un agente

> Antes de modificar archivos, resume el objetivo, los criterios de aceptación, los riesgos y un plan de hasta cinco pasos. Espera mi confirmación. Después implementa solo el primer bloque verificable, añade o actualiza pruebas y enumera exactamente qué has ejecutado y qué falta por probar.

No uses esta instrucción para delegar decisiones de seguridad, arquitectura crítica o publicación: la persona responsable debe revisarlas.

## Al finalizar una entrega

- Confirma que cada criterio de aceptación tiene una evidencia.
- Revisa cambios, secretos accidentales y dependencias añadidas.
- Deja una siguiente acción concreta o actualiza el estado a terminado.
- Si el trabajo continúa en otra sesión, usa la plantilla de relevo temporal.

Para procesos repetitivos posteriores, consulta [Automatizaciones](AUTOMATION.md).

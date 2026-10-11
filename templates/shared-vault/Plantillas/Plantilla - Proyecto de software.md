---
tipo: proyecto-software
estado: idea
creado: "{{date}}"
actualizado: "{{date}}"
etiquetas:
  - proyecto
  - software
---

# {{title}}

## Problema y MVP

- Personas usuarias y problema:
- Resultado mínimo útil:
- Fuera de alcance en esta versión:

## Requisitos y aceptación

- Requisitos funcionales:
- Requisitos no funcionales: seguridad, rendimiento, accesibilidad, privacidad u otros relevantes.

### Criterios de aceptación

```gherkin
Scenario: Describe el flujo principal
  Given un estado inicial concreto
  When la persona realiza una acción
  Then recibe un resultado observable y verificable
```

Añade escenarios de error y límites cuando apliquen. Un criterio debe ser claro, medible y comprobable antes de marcar el trabajo como terminado.

## Decisiones técnicas

- Lenguaje, framework y versión:
- Datos y almacenamiento:
- Dependencias relevantes:
- Motivo de cada decisión y alternativa descartada:

No elijas un stack por inercia: valida que responde al problema, al despliegue y al nivel de mantenimiento previsto.

## Arquitectura y plan

- Componentes o módulos:
- Flujo de datos y límites de seguridad:
- Plan por entregas pequeñas y revisables:

Antes de una implementación no trivial, pide al asistente un plan, revísalo y confírmalo. Implementa una entrega a la vez.

## Calidad y verificación

- Comando de desarrollo:
- Comando de pruebas:
- Comando de lint o formato:
- Comando de compilación o empaquetado:
- Pruebas de aceptación manuales:

Escribe o actualiza pruebas junto a cada cambio de comportamiento. No aceptes una implementación hasta ejecutar las comprobaciones pertinentes y revisar el diff.

## Automatización opcional

- Proceso repetitivo que se quiere automatizar:
- Disparador manual o evento:
- Entrada, salida y clave para evitar duplicados:
- Prueba previa, registro y forma de detener o revertir:

No programes tareas ni conectes servicios externos hasta revisar permisos, credenciales y efectos. Documenta el diseño, una prueba y una forma de detener o revertir el flujo antes de activarlo.

## Estado

- Fase actual:
- Próxima acción verificable:
- Bloqueos:

## Registro

- {{date}} — Proyecto creado.

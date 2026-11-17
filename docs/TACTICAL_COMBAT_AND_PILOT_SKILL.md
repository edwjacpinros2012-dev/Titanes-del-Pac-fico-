# Sistema táctico de combate y dominio del piloto

## Objetivo de diseño

La potencia del Centinela no debe decidir por sí sola el resultado. La progresión mejora las opciones disponibles, pero la lectura del enemigo, la táctica elegida y la experiencia del piloto modifican la resolución. Un jugador preparado puede rendir por encima de su nivel; una mala elección puede convertir una ventaja de nivel en una derrota.

## Implementado en esta iteración

- El catálogo de Abisales aporta un rol táctico a cada amenaza: blindado, asedio, territorial, acechador, emboscador, excavador, veloz, disruptor o alfa.
- Se incorporaron tres respuestas activas:
  - **Flanqueo:** contrarresta blindados, amenazas de asedio y territoriales.
  - **Defensa:** contrarresta acechadores, emboscadores y excavadores; reduce el coste de reparación en algunos resultados.
  - **Precisión:** contrarresta amenazas veloces, disruptoras y alfa.
- **Escaneo** es la opción inicial prudente y entrega una bonificación pequeña, sin sustituir una respuesta especializada.
- Una respuesta correcta concede experiencia de piloto (hasta 10 puntos). Esa experiencia mejora gradualmente las futuras respuestas correctas.
- Se guardan experiencia, tácticas utilizadas, contramedidas exitosas e informe de la última batalla.
- Los controles están conectados a teclado y botones táctiles.

## Controles

| Acción | PC | Móvil |
|---|---|---|
| Iniciar/resolver encuentro | J | J |
| Flanqueo | Q | Q |
| Defensa | X | X |
| Precisión | U | U |
| Retirada | G | G |

Inicia con J, observa el rol del Abisal en el panel y selecciona una táctica antes de volver a pulsar J. G permite retirarse.

## Reglas de balance

1. La progresión del mecha y la campaña aportan potencia base.
2. La investigación añade una bonificación limitada.
3. La táctica modifica la potencia efectiva según el rol enemigo.
4. La experiencia del piloto recompensa aprender a contrarrestar amenazas, sin subir automáticamente por repetir cualquier acción.
5. Victoria, éxito parcial, retirada y derrota mantienen consecuencias distintas.
6. Las derrotas no borran el progreso permanente del jugador.

## Límites actuales y siguientes mejoras

- La resolución táctica todavía es un modelo abstracto de combate, no una simulación física de golpes, colisiones, armaduras o IA de combate en tiempo real.
- La experiencia del piloto mide el aprendizaje del sistema de contramedidas, no una medición real de reflejos o habilidad humana.
- Siguiente etapa: añadir patrones de ataque telegráficos, ventanas de oportunidad, energía y calor, daño por subsistema, estados de aturdimiento y objetivos de misión. Cada patrón deberá poder leerse y responderse en tiempo real.
- Después: pruebas automatizadas de cada combinación rol/táctica y pruebas manuales en PC, Android y navegador.

## Validación requerida

La integración debe pasar la importación y ejecución headless de Godot 4.3. También hay que probar controles táctiles en dispositivo real y confirmar que la experiencia del piloto se conserva al cerrar y volver a abrir el juego.

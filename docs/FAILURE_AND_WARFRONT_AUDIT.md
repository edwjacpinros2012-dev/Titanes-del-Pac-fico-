# Diagnóstico de derrota, dificultad y guerra territorial

Fecha: 2026-11-17

## Regla de diseño
La victoria no está garantizada. La preparación, el nivel del Centinela, la investigación y las decisiones deben influir en el resultado. Una derrota debe comunicar por qué ocurrió y ofrecer una ruta de recuperación sin borrar horas de progreso.

## Lo que existe en el código revisado
- `scripts/war/kaiju_war_manager.gd`: clasifica encuentros como victoria, éxito parcial, retirada o derrota según una comparación de poder.
- `scripts/main.gd`: aplica recompensas y costes de reparación/suministros; guarda el perfil local.
- `scripts/campaign/campaign_manager.gd`: desbloquea capítulos y generaciones Mark según nivel.
- `scripts/world/region_manager.gd`: permite desbloquear y viajar a regiones, pero todavía no gestiona presión enemiga, pérdida o reconquista.
- `scripts/core/save_manager.gd`: admite perfiles JSON versionados; la restauración completa de todos los sistemas todavía necesita pruebas.

## Integración añadida
- `scripts/war/warfront_state_manager.gd`: registra operaciones, victorias, éxitos parciales, retiradas y derrotas.
- La presión enemiga aumenta con retiradas y derrotas.
- A 3/10 la región queda en disputa; a 6/10 se considera perdida.
- Las victorias reducen la presión en 2; los éxitos parciales la reducen en 1.
- El estado de la primera línea costera se guarda en el perfil local y se restaura al cargar.
- Una región perdida no se borra del perfil ni bloquea toda la campaña: varias operaciones exitosas permiten recuperarla.

## Límites importantes
Este sistema es una capa de estado de campaña, no combate 3D terminado. El encuentro actual se resuelve con una comparación numérica al pulsar combatir; todavía no simula golpes, movimiento táctico, partes dañadas, IA avanzada ni duración real de batalla. La presión territorial solo se aplica a la primera línea costera; el mapa de varias regiones y las ofensivas de IA quedan pendientes.

## Diagnóstico de brechas

| Área | Estado observado | Prioridad |
|---|---|---|
| Victoria/retirada/derrota | Existe resolución lógica | Alta: probar balance |
| Consecuencias persistentes | Costes y presión de frente añadidos | Alta: pruebas de guardado |
| Pérdida y reconquista territorial | Primera línea costera lógica | Alta: ampliar a mapa regional |
| Combate jugable en tiempo real | No implementado | Crítica |
| Daño por componentes del Centinela | No implementado | Alta |
| IA de enemigos y patrones | Muy básica/provisional | Alta |
| Informe de batalla y causa de derrota | Parcial; falta desglose por factores | Alta |
| Reparación y recuperación | Costes básicos; falta cola/tiempo de reparación | Media |
| Campaña ramificada por resultados | Capítulos lineales por nivel | Media |
| Guardado y restauración completa | Perfil local parcial | Crítica antes de publicar |
| Arte, animación y audio finales | Provisionales | Alta |
| Exportación y pruebas en equipos reales | Pendientes | Crítica antes de publicar |

## Criterios de equilibrio
1. Mostrar antes de salir el nivel recomendado, la amenaza detectada y la preparación estimada.
2. Mostrar después del combate qué factores influyeron en el resultado.
3. La derrota debe tener consecuencias visibles y recuperables.
4. Evitar una espiral de castigos: una derrota no debe debilitar tanto al jugador que las siguientes misiones sean imposibles.
5. Mantener la investigación permanente como progreso de largo plazo, aunque se pierdan recursos temporales.
6. Probar encuentros con Mark I sin mejoras, Mark I mejorado y Mark II para verificar que la dificultad crece de forma comprensible.

## Referencias de diseño
- Josh Bycer, *The Balance of Fail States in Game Design* (GameDeveloper, 2017): severidad, progreso a corto plazo y riesgo de ciclos de fracaso.
- *A Diagnostic Taxonomy of Failure in Videogames* (FDG 2020): distinguir fallos propios del desafío de fallos causados por controles o comunicación deficientes.
- Documentación oficial Godot 4.3, *Saving games*: identificar y serializar explícitamente los objetos y estados persistentes.

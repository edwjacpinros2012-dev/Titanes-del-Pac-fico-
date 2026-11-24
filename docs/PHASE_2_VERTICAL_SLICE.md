# Fase 2 — Vertical slice jugable

Fecha: 24 de noviembre de 2026  
Rama de trabajo: `phase-2-vertical-slice`  
Motor principal: Godot 4.3 (proyecto 3D horizontal)

## Objetivo

Cerrar una operación corta que conecte mundo, jugador, amenaza, resultado y persistencia. Esta fase no declara terminado el juego completo ni sustituye los sistemas de campaña, base o comunidad existentes.

## Cambios incluidos en esta rama

1. **Identificadores de recursos unificados:** la energía del juego usa `energia` junto con `metal` y `cristal`. Se corrige el desfase entre la recompensa del Kaiju y el HUD de la base.
2. **Puente de estado:** el perfil local sincroniza recursos y niveles con el autoload `GlobalState`; los cambios de la operación de campo actualizan el HUD principal.
3. **Persistencia de la primera operación:** se guarda el identificador `aurora_coast_first_deployment` en el perfil local y en el archivo de guardado de GameState. La operación no vuelve a entregar su recompensa de finalización una vez reclamada.
4. **Reintento:** si el Titán queda incapacitado, aparece un botón para reiniciar la operación; restaura integridad y vuelve a crear la oleada sin conceder recompensas por reiniciar.
5. **Escenario costero:** se añade una franja de océano, playa y una línea de edificios originales de baja complejidad para dar profundidad al horizonte.
6. **Silueta provisional de Kaiju:** se construyen partes adicionales con primitivas de Godot. Es una representación de prototipo, no un modelo final riggeado.
7. **Corrección visual:** el destello de acción del Titán se coloca delante del personaje, en la dirección de avance.

## Recorrido de aceptación

- Iniciar el proyecto y comprobar que el Titán aparece en la Costa de la Aurora.
- Verificar que el HUD principal muestra metal, energía y cristal.
- Comprobar que la operación de campo muestra objetivo, integridad y energía.
- Recoger una recompensa de enemigo y verificar que el valor de energía cambia en el HUD principal.
- Completar la operación y verificar que se guarda la bandera de misión.
- Cerrar y abrir el juego: la operación ya completada no debe volver a pagar su recompensa final.
- Iniciar una partida de prueba sin completar y dejar que el Titán quede incapacitado: debe aparecer el botón de reintento.
- Pulsar reintentar: integridad restaurada, oleada reiniciada y sin recompensas duplicadas.
- Guardar, cerrar y abrir el proyecto sin errores de importación.

## Archivos modificados

- `scripts/core/game_state.gd`
- `scripts/core/save_manager.gd`
- `scripts/main.gd`
- `scripts/combat/field_combat_director.gd`
- `scripts/combat/field_kaiju.gd`
- `scripts/titans/titan_controller.gd`

## Estado de validación

Los cambios están guardados en esta rama. No se ha ejecutado Godot localmente desde esta sesión, por lo que la compilación GDScript, la importación de escenas y la prueba manual siguen pendientes. No declarar la fase aprobada hasta ejecutar el recorrido de aceptación.

## Pendientes dentro de la vertical slice

- Unificar el combate táctico abstracto y la operación de campo en un solo flujo de campaña, sin duplicar recompensas.
- Hacer que el estado de misión y los resultados sean la única autoridad de progresión.
- Añadir pausa, pantalla de resultados y transición de regreso al hangar.
- Conectar daño de subsistemas con feedback visual del modelo.
- Sustituir primitivas por modelos originales GLB/GLTF con rig y animaciones.
- Validar rendimiento y controles en teclado, mando y pantalla táctil.

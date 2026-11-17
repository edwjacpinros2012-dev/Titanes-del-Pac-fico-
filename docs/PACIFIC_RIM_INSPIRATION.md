# Inspiración de ciencia ficción: titanes y brechas del Pacífico

## Referencia estudiada
La sinopsis oficial de Pacific Rim presenta criaturas gigantes que emergen del océano, máquinas pilotadas por equipos coordinados mediante un enlace neural y una defensa internacional del litoral.

## Traducción a una identidad original
No se reutilizan nombres de robots, criaturas, pilotos, organizaciones, diseños, diálogos, escenas ni recursos visuales de la película.

| Idea general | Sistema propio |
|---|---|
| Dos pilotos coordinados | Enlace de pilotos: cargar sincronización y obtener una mejora temporal |
| Aparición de amenazas desde el océano | Brechas oceánicas que se investigan y estabilizan |
| Defensa de zonas costeras | Base modular, energía y puestos de exploración |
| Máquinas gigantes | Titanes originales con estadísticas, etapas y habilidades |
| Amenazas que evolucionan | Criaturas originales con patrones y regiones diferentes |

## Bucle de juego propuesto
1. Explorar la costa y localizar recursos.
2. Reunir metal, energía y cristal.
3. Investigar una brecha y estabilizarla.
4. Recibir materiales y datos de investigación.
5. Mejorar la base y desbloquear tecnología.
6. Entrenar el enlace de pilotos y evolucionar el titán.
7. Acceder a regiones más exigentes.

## Sistemas añadidos en esta iteración
- scripts/titans/pilot_sync_manager.gd: carga y duración del enlace de pilotos.
- scripts/world/pacific_rift_manager.gd: tres brechas de exploración con progreso de estabilización y recompensas.
- data/world/pilot_pairs.json: perfiles narrativos originales para parejas de pilotos.

## Controles del prototipo
- Mantener F: cargar el enlace de pilotos.
- Mantener R cerca de una brecha: estabilizarla.
- E: recoger recursos.
- B: mejorar la base.
- T: evolucionar el titán.

## Estado y límites
Estos sistemas están escritos para Godot 4 y conectados al prototipo principal en esta iteración. Falta ejecutar el proyecto en el editor para verificar sintaxis, físicas y balance. Los marcadores de brecha son geometría provisional; las criaturas, animaciones, modelos finales, voces y cinemáticas siguen pendientes.

## Fuentes consultadas
- Legendary Pictures, sinopsis oficial de Pacific Rim: https://www.legendary.com/film/pacificrim/
- Godot 4, documentación oficial sobre entrada del jugador: https://docs.godotengine.org/es/4.x/getting_started/first_3d_game/02.player_input.html
- Godot 4, documentación oficial sobre recursos y escenas reutilizables: https://docs.godotengine.org/es/4.x/tutorials/scripting/resources.html

# Transferencia futura a Godot — solo documento de referencia

**No se modifican ni crean archivos dentro del proyecto Godot en esta etapa.**

| Base web provisional | Equivalente conceptual en Godot |
|---|---|
| Phaser Scene | Node / escena |
| CombatScene | escena de combate |
| World3D | Node3D contenedor del mundo |
| MechFactory | PackedScene / modelos reutilizables |
| GAME config | Resources / configuración de juego |
| HUD Phaser | CanvasLayer + Control |
| Input WASD/táctil | InputMap + controles táctiles |
| estado de combate | nodos/controladores de gameplay |

## Contratos que conviene conservar
- Integridad, energía y vida del enemigo: valores normalizados 0–100.
- Movimiento desacoplado de la tasa de fotogramas usando delta.
- Combate configurable: coste, daño, alcance y enfriamiento.
- Separar presentación, entrada y reglas de juego.
- Mantener identificadores estables para Titanes, Kaijus, misiones y equipo.

La versión web sirve como maqueta funcional y banco de pruebas de interfaz. No se debe copiar automáticamente su código a Godot.

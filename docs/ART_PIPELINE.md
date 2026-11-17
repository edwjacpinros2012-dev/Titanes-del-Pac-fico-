# Pipeline de arte 3D

## Personajes
Entregar modelos originales en GLB/GLTF, escala consistente, origen en el suelo, materiales PBR, UVs, esqueleto y animaciones con nombres estables.

## Animaciones mínimas
Idle, walk, run, turn, interact, hit_react, ability_primary y evolution.

## Ambientes
Usar módulos reutilizables, colisiones simples, LOD cuando sea necesario y texturas optimizadas. Mantener versiones fuente de Blender fuera del build si el tamaño lo exige.

## Convención
- Modelos: assets/characters/<grupo>/<id>/model/
- Texturas: assets/characters/<grupo>/<id>/textures/
- Animaciones: assets/characters/<grupo>/<id>/animations/
- Escenas Godot: scenes/characters/<grupo>/
- Datos: data/characters/

Los diseños de referencia deben convertirse en modelos propios antes de considerarse contenido del juego.

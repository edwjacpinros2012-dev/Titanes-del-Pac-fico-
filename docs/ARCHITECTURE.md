# Arquitectura

- core: estado global y guardado.
- resources: nodos recolectables e inventario.
- titans: estadísticas, control y evolución.
- construction: definición de edificios y colocación en cuadrícula.
- research: desbloqueo de tecnologías.
- missions: objetivos y seguimiento.
- creatures: datos de especies.
- ui: HUD desacoplado de la lógica.

Los scripts con class_name se pueden reutilizar desde escenas. Para usarlos como singletons, agregarlos explícitamente en Project Settings > Autoload después de verificar el proyecto en Godot.

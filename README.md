# Titanes del Pacífico

Juego 3D original de exploración, supervivencia, recolección, construcción y evolución, desarrollado con Godot 4.

## Abrir el proyecto
1. Instala Godot 4.
2. Descarga o clona este repositorio.
3. En Godot, pulsa **Importar** y selecciona `project.godot`.
4. Ejecuta con F6/F5.

## Prototipo actual
- Escena 3D inicial con movimiento, cámara y recolección básica.
- Recursos de metal, energía y cristales.
- Mejora de base y evolución demostrativa.
- Escena provisional de Titán Alfa con controlador propio.
- Escenas provisionales de centro de mando, generador y nodo de recurso.
- Arquitectura modular para inventario, guardado, misiones, investigación y construcción.
- Datos JSON para titanes, regiones, edificios, tecnologías y misiones.

## Controles de la escena principal
- **WASD / flechas:** moverse.
- **E:** intentar recoger un recurso cercano.
- **B:** mejorar la base.
- **T:** evolucionar el titán.

## Estructura
- `assets/`: arte, personajes, ambientes, edificios, audio e interfaz.
- `scenes/`: escenas Godot para mundo, personajes, base y recursos.
- `scripts/`: lógica modular del juego.
- `data/`: contenido configurable en JSON y recursos Godot.
- `docs/` y `documentation/`: diseño, arquitectura y seguimiento.
- `web/`: página informativa de lanzamiento.

## Estado real del contenido
Los modelos GLB finales, texturas, esqueletos, animaciones, biomas completos, IA avanzada, combate, misiones integradas y multijugador siguen pendientes. Las cápsulas y primitivas son placeholders de desarrollo, no arte final.

## Publicación web
Vercel aloja la página informativa de `web/`. La versión jugable del navegador requiere exportar el juego desde Godot con la plantilla Web y publicar esos archivos exportados. No se presenta la página informativa como juego web terminado.

Consulta `docs/ROADMAP.md`, `docs/GAME_DESIGN.md` y `docs/ART_PIPELINE.md`.

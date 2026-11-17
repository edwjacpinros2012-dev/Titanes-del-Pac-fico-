# Titanes del Pacífico

Juego 3D original de exploración, supervivencia ligera, recolección, fabricación, construcción y evolución, desarrollado con Godot 4.

## Abrir el proyecto
1. Instala Godot 4.
2. Descarga o clona este repositorio.
3. En Godot, pulsa **Importar** y selecciona `project.godot`.
4. Ejecuta con F6/F5.

## Prototipo y módulos preparados
- Escena 3D inicial con movimiento, cámara y recolección básica.
- Recursos de metal, energía y cristales.
- Mejora de base y evolución demostrativa.
- Titán Alfa integrado en la escena principal, con escena visual provisional, controlador y estadísticas.
- Escenas provisionales de centro de mando, generador y nodos de recursos.
- Inventario, fabricación por recetas y sistema de guardado.
- Construcción, energía de base e investigación.
- Clima, ciclo día/noche y eventos del mundo.
- Expediciones, puntos de interés y registro de descubrimientos.
- Datos JSON para titanes, habilidades, regiones, recursos, edificios, tecnologías, misiones, recetas, comercio y doce especies originales.
- Mercado costero con créditos, compra/venta de materiales y existencias limitadas.
- Contratos de exploración, reconocimiento aéreo y comercio con recompensas.
- Dos helicópteros de reconocimiento que sobrevuelan el sector y regresan a la base.
- Ocho entidades Kaiju provisionales móviles para encuentros y observación; son amenazas del mundo, nunca mascotas ni compañeros del jugador.
- Catálogo de doce Kaijus enemigos originales con niveles de amenaza y progresión por campaña.
- Diseño de campaña: el jugador comienza como recluta con un Jaeger Mark I y una base pequeña; la dificultad aumenta por capítulos y amenaza regional, con victorias, retiradas y derrotas que tienen consecuencias.
- Diseño de alianzas de jugadores, roles, solicitudes de ingreso, invitaciones, objetivos cooperativos y clasificación.
- Esquema inicial de backend Supabase para perfiles, alianzas, chat moderado, bloqueos y denuncias.

## Controles de la escena principal
- **WASD / flechas:** moverse.
- **E:** intentar recoger un recurso cercano.
- **B:** mejorar la base.
- **T:** evolucionar el titán.
- **F:** sincronizar pilotos.
- **R:** estabilizar una brecha cercana.
- **H:** enviar helicópteros de reconocimiento.
- **C:** abrir/cerrar el mercado; con el mercado abierto, 1-3 compra y 4-6 vende.

## Estructura
- `assets/`: futuros modelos, texturas, audio e interfaz.
- `scenes/`: escenas Godot para mundo, personajes, base y recursos.
- `scripts/`: lógica modular del juego.
- `data/`: contenido configurable en JSON y recursos Godot.
- `docs/` y `documentation/`: diseño, investigación, arquitectura y seguimiento.
- `web/`: página informativa de lanzamiento.

## Diseño de guerra, Kaijus y comunidad
Consulta `docs/GAME_DESIGN_KAIJU_ALLIANCES_ONLINE.md` para la identidad Kaiju/Jaeger, campaña, progresión Mark, alianzas, registro, inicio de sesión y reglas de comunidad. El roster enemigo está en `data/kaiju/kaiju_roster.json`. El esquema SQL inicial está en `backend/supabase/migrations/0001_community_schema.sql`.

**Importante:** cuentas, chat global, alianzas online y multijugador todavía no están conectados a un servicio real. El SQL es una base inicial que requiere configurar un proyecto Supabase, revisar las políticas, añadir funciones de servidor y probar la seguridad. El chat empieza desactivado y debe permanecer así hasta contar con moderación y controles adecuados.

## Estado real
Los módulos de fabricación, clima, energía, expediciones y habilidades están creados como sistemas independientes y todavía necesitan conectarse al HUD y al flujo principal. La escena visual del Titán Alfa usa geometría provisional, no un modelo GLB final. Siguen pendientes modelos 3D finales, texturas, rig, animaciones, biomas completos, IA avanzada, integración completa y multijugador.

No se ha verificado la compilación de todos los scripts en una ejecución local de Godot. Abre el proyecto y revisa errores antes de considerar una función lista.

## Publicación web
Vercel aloja la página informativa de `web/`. La versión jugable del navegador requiere exportar el juego desde Godot con la plantilla Web y publicar esos archivos exportados. No se presenta la página informativa como juego web terminado.

Consulta `docs/GAME_DESIGN_KAIJU_ALLIANCES_ONLINE.md`, `docs/CONTENT_STATUS.md` y `docs/ROADMAP.md` para el diseño y el estado actualizado.

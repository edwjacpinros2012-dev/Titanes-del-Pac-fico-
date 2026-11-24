# Arquitectura del proyecto

## Stack activo

- **Vite + TypeScript**: compilación y aplicación web.
- **Phaser 3**: ciclo de juego, entrada, HUD y escenas.
- **Three.js**: renderizado 3D del mundo, Jaegers, Kaijus y entorno.
- **Supabase (objetivo de backend)**: autenticación, persistencia compartida, operaciones seguras y realtime. No se considera conectado hasta verificar proyecto, variables y migraciones desplegadas.

Godot aparece en archivos heredados del repositorio, pero no es el runtime de la experiencia web activa. No duplicar el juego ni crear una segunda aplicación.

## Organización actual

- `src/main.ts`: composición de Phaser y Three.js; escena activa y ciclo de combate.
- `src/game-systems.ts`: estado local, migración del guardado, recursos, progresión, base y transacciones.
- `src/mission-director.ts`: generación táctica procedural determinista.
- `src/game-panels.ts`: interfaz de hangar, base, alianza, mercado/NPC, chat y director.
- `src/*.css`: presentación y estilos.

## Organización objetivo

La separación se hará progresivamente, conservando contratos y evitando reescrituras grandes:

- `src/core/`: tipos compartidos, eventos, reloj y validación.
- `src/economy/`: producción, inventario, comercio y libro de movimientos.
- `src/base/`: instalaciones, construcción, capacidad y defensa.
- `src/npcs/`: perfiles, rutinas, diálogo y contratos.
- `src/factions/`: alianzas, miembros, rangos y reputación.
- `src/world/`: ciudad, población, alerta y eventos.
- `src/missions/`: objetivos, director táctico y evaluación.
- `src/ui/`: paneles y HUD que consumen servicios, sin decidir recompensas.
- `data/`: catálogos de contenido versionados.
- `assets/`: modelos, texturas, animaciones, escenarios, audio y UI.
- `backend/supabase/`: migraciones SQL y funciones del servidor.

No crear módulos vacíos por anticipado. Extraer un sistema cuando tenga límites claros, consumidores identificados y una prueba.

## Principios

1. Una sola fuente de verdad por dato.
2. La UI envía intenciones; los sistemas validan y realizan transacciones.
3. Los cambios de recursos y recompensas se aplican de forma atómica.
4. Los guardados tienen versión, migración y recuperación.
5. El contenido se define en catálogos, no se repite en botones o paneles.
6. La lógica de juego funciona localmente; el modo online requiere servidor autoritativo.
7. Las claves privadas nunca se exponen en el cliente ni en variables `VITE_*`.
8. No simular jugadores, chat, mercado o alianzas online.

## Persistencia y autoridad

El guardado local sirve para prototipar y probar progreso en un dispositivo. No protege contra manipulación. En online, el servidor valida propietario, recursos, capacidad, requisitos, límites, idempotencia y resultados de misión antes de escribir.

## Validación

- `npm run typecheck`
- `npm run build`
- Pruebas de límites: recursos insuficientes, almacén lleno, IDs inválidos y contratos reclamados.
- Pruebas de guardar, recargar, migrar y recuperar backup.
- Prueba manual en navegador y dispositivo de menor capacidad.
- Separar estados: código escrito, integrado, CI aprobado, prueba manual y despliegue verificado.

## Documentación relacionada

- [Control del mundo, economía, NPC y alianzas](WORLD_CONTROL_ARCHITECTURE.md)
- [Dirección visual y pipeline Higgsfield](HIGGSFIELD_VISUAL_WORKFLOW.md)
- [Director de misiones](AI_MISSION_DIRECTOR.md)

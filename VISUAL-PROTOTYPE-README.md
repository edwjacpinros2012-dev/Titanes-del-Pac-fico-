# Pacific Rim: Titanes — base visual provisional

Esta rama contiene exclusivamente la base visual web Phaser 3 + Three.js. No modifica ni migra archivos de Godot.

## Ejecutar
- Node.js 22+
- `npm install`
- `npm run dev`
- `npm run typecheck`
- `npm run build`

## Controles
- PC: WASD/flechas para moverse, espacio para atacar.
- Móvil/tablet: pad táctil y botón de ataque en pantalla.

## Arquitectura
- Phaser 3: escenas, HUD, menú, entradas y estados de combate.
- Three.js: renderizado 3D del escenario, Titán y Kaiju.
- `src/visual/config`: configuración independiente de contenido.
- `src/visual/scenes`: menú y combate.
- `src/visual/world`: escena 3D y modelos provisionales construidos con geometría.
- `src/visual/ui`: interfaz y controles.
- `docs/visual-to-godot.md`: mapa de transferencia conceptual a Godot.

Los modelos geométricos son placeholders. No representan modelos finales ni assets oficiales.

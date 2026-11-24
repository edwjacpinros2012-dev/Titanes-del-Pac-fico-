# Pipeline de arte 3D

## Dirección artística

La identidad visual es ciencia ficción industrial cinematográfica: maquinaria pesada, ingeniería costera, acero y titanio con desgaste funcional, niebla salina, lluvia, hormigón húmedo, luz de advertencia y escala monumental. Mantener siluetas legibles y una paleta coherente en todas las áreas.

## Producción de personajes

Entregar modelos originales en GLB/GLTF, escala consistente, origen en el suelo, materiales PBR, UVs, esqueleto y animaciones con nombres estables.

### Animaciones mínimas
- `idle`, `walk`, `run`, `turn`
- `attack_primary`, `ability_primary`
- `hit_react`, `stagger`, `victory`
- `maintenance`, `deployment`

Cada Jaeger debe tener silueta, proporciones, piezas, colores y marcas coherentes entre sus vistas y animaciones. Los Kaijus necesitan anatomía original y comportamiento visual legible por categoría.

## Ambientes

Hangar con grúas, plataformas, ascensores, soportes, pasarelas y personal a escala. Ciudades con puerto, defensas, distritos, rutas de evacuación y referencias de tamaño. Usar módulos reutilizables, colisiones simples, LOD y texturas optimizadas.

## Higgsfield en preproducción

Usar Higgsfield para explorar imágenes maestras, continuidad de personajes, keyframes y clips cinematográficos. Aprobar las imágenes fijas antes de generar movimiento. Los clips generados son material de tráiler o referencia, no sustituyen modelos 3D, colisiones, rigs ni animación en tiempo real.

Consultar [HIGGSFIELD_VISUAL_WORKFLOW.md](HIGGSFIELD_VISUAL_WORKFLOW.md) para la biblia visual, prompts originales, flujo de revisión y entrega técnica.

## Convención de archivos

- Modelos: `assets/characters/<grupo>/<id>/model/`
- Texturas: `assets/characters/<grupo>/<id>/textures/`
- Animaciones: `assets/characters/<grupo>/<id>/animations/`
- Ambientes: `assets/environments/<id>/`
- Edificios: `assets/buildings/<id>/`
- Datos: `data/characters/`, `data/kaiju/`, `data/buildings/`

## Requisitos de entrega

Cada asset debe incluir origen/licencia, archivo fuente, exportación runtime, escala, pivote, materiales, lista de animaciones, LOD y captura de prueba dentro de Three.js. Los diseños de referencia deben convertirse en modelos propios antes de considerarse contenido del juego.

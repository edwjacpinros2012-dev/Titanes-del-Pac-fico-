# Fase 2 — Vertical slice con dirección artística maestra

La referencia vigente es [DIRECCIÓN_ARTÍSTICA_MAESTRA.md](DIRECCIÓN_ARTÍSTICA_MAESTRA.md), derivada del PDF de 19 páginas *referencia visual del juego titanes del abismo.pdf*. Esta especificación sustituye la referencia visual previa para el proyecto completo, no solo para esta fase.

## Objetivo de fase
Crear una operación jugable que demuestre el lenguaje visual final: Jaeger inicial seleccionable, hangar industrial, ciudad costera, amenaza Kaiju legible, HUD táctico y progreso persistente.

## Requisitos visuales
- Acero azul/negro desgastado, reactores cian/ámbar, hormigón húmedo, vidrio reforzado y metal oxidado.
- Hangares con plataformas, grúas, focos volumétricos, vapor y señalización.
- Ciudad costera nocturna con puerto, edificios altos, rutas de evacuación y agua.
- HUD de integridad, energía, categoría de amenaza, objetivo y sectores.
- Kaiju con silueta orgánica y bioluminiscencia propia, no una figura geométrica básica como entrega final.

## Progresión
- El jugador elige el Jaeger inicial disponible antes del primer despliegue.
- La unidad inicial evoluciona por niveles/Mark y conserva su progreso.
- Las demás unidades aparecen en el hangar bloqueadas con requisitos de campaña.
- La selección se guarda y se aplica al modelo desplegado.

## Criterios y límites
El prototipo actual utiliza geometría provisional. Esta fase no se considera visualmente completa hasta integrar modelos GLB/glTF, materiales PBR, animaciones y pruebas reales en Godot. Ver [QA_PHASE_2.md](QA_PHASE_2.md) y la guía maestra.

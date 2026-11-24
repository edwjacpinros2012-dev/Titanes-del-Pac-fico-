# Mapa de integración: referencia visual → código → Vercel

Este documento registra cómo se traducen las 19 páginas de la biblia conceptual a los sistemas visuales actuales del juego. Los números de página corresponden al PDF de referencia entregado por el equipo.

## Estado de integración

| Páginas | Referencia | Implementación de código | Estado |
|---|---|---|---|
| 1, 11 | Identidad cinematográfica, paleta industrial y atmósfera | `src/visual-direction.ts`, `src/main.ts` | Integración procedural inicial |
| 2–3 | Jaeger azul, variantes y vistas ortográficas | `buildMech('gipsy')` en `src/main.ts` | Silueta procedural refinada; pendiente modelo GLB |
| 4 | Striker: unidad clara, ágil y con propulsores | `buildMech('striker')` | Aletas y propulsores diferenciados; pendiente modelo GLB |
| 5 | Cherno: blindaje pesado | `buildMech('cherno')` | Hombros y blindaje reforzados; pendiente modelo GLB |
| 6–10 | Raker, Brineback, Razorfin, Dreadmaw y Abyssal Crown | `buildKaiju()` | Cinco perfiles de silueta/color según categoría; pendiente malla individual por especie |
| 12 | Hangar monumental | `buildBase()` | Pórtico, grúas interiores, carriles y luces |
| 13–14 | Ciudad costera y puerto | `buildWorld()` | Skyline modular, ventanas, grúas portuarias, océano y corredor |
| 15 | Distrito de evacuación | `buildBase()`, `buildCivilians()` | Zona y figuras civiles procedurales; pendiente arte final |
| 16 | HUD de combate | `buildHud()` | HUD funcional; pendiente skin final y revisión de legibilidad |
| 17 | Mapa estratégico | paneles y director de misiones | Datos de distrito/sector disponibles; mapa táctico gráfico todavía pendiente |
| 18 | Biblioteca de materiales | `src/visual-direction.ts` y materiales Three.js | Paleta/materiales iniciales; faltan mapas PBR authored |
| 19 | Efectos visuales | `src/main.ts`, perfiles de clima | Atmósfera e iluminación iniciales; faltan VFX avanzados y partículas optimizadas |

## Perfiles de entorno

`getVisualProfile(weather)` asigna perfiles de iluminación y materiales a partir del clima de la misión. Los valores son deliberadamente acotados para evitar que los eventos del director produzcan escenas excesivamente oscuras o sobreexpuestas.

- Tormenta/lluvia/marejada: cielo profundo, niebla azul fría, suelo más reflectante y océano oscuro.
- Niebla/bruma: niebla más cercana, iluminación difusa y contraste reducido.
- Viento/cielo nublado: luz fría más amplia, suelo industrial y océano azul grisáceo.
- Otros climas: perfil cinematográfico costero predeterminado.

## Contrato de assets para el futuro

Los modelos finales deben importarse como GLB/GLTF y no como capturas PNG usadas como geometría. Cada modelo debe documentar:
- unidad de medida y escala;
- orientación frontal del modelo;
- pivote raíz y nombres de huesos;
- materiales PBR y mapas disponibles;
- animaciones y nombres de clips;
- LOD y colisiones;
- licencia/origen del recurso.

El siguiente paso de integración será cargar modelos aprobados desde `public/assets/models/` con fallback procedural, de modo que el juego siga funcionando si un archivo artístico falta o no se puede cargar.

## Cómo llega a Vercel

La rama de desarrollo está conectada a validaciones GitHub Actions. Cuando Vercel tenga Git conectado y las Preview Deployments habilitadas, cada push/commit de esta rama puede generar un preview. Este documento no declara que un deployment esté listo: el estado real debe comprobarse en el enlace de deployment de Vercel.

## Limitaciones actuales

- No se ha importado el PDF original como archivo binario de assets en el repositorio.
- El arte conceptual no es una malla 3D ni incluye UV, rig, texturas PBR o animaciones.
- Los modelos procedurales actuales son prototipos visuales construidos con geometría Three.js.
- No sustituir estos prototipos por modelos finales hasta validar carga, escala, materiales, animaciones, colisiones y rendimiento.

# Plan maestro visual — Titanes del Pacífico

## Objetivo
Convertir el prototipo Three.js en una experiencia 3D cinematográfica de ciencia ficción industrial. Este documento prepara producción de arte; no afirma que los modelos o texturas finales ya existan.

## Dirección artística
- Escala: Jaegers de decenas de metros, Kaijus colosales y arquitectura costera monumental.
- Materiales: acero pintado, placas cerámicas, juntas hidráulicas, cables, desgaste localizado, agua salada, hormigón húmedo y vidrio reforzado.
- Luz: amanecer/tormenta costera, niebla volumétrica simulada con capas, contraluces, luces de emergencia y emisivos controlados.
- Paleta: azul petróleo y grafito como base; naranja PPDC para señalización; cian para energía; rojo solo para alertas.
- Cámara: planos bajos que comuniquen escala, encuadres legibles durante el juego y cámara de seguimiento estable.
- Evitar aspecto de juguete, siluetas genéricas, superficies plásticas y exceso de bloom.

## Biblioteca visual que debe producirse

### 1. Jaegers
Para cada unidad:
- Modelo GLB/GLTF optimizado, escala y pivote documentados.
- Malla por piezas articuladas: pelvis, torso, cabeza, brazos, antebrazos, manos, muslos, piernas y pies.
- Rig humanoide mecánico con nombres de huesos consistentes.
- Animaciones: idle pesado, caminar, girar, recibir impacto, ataque, bloqueo, caída/derrota y reparación en hangar.
- Materiales PBR: base color, normal, roughness, metallic y emissive cuando proceda.
- Variantes de daño visual y piezas intercambiables.
- LODs, colisiones simplificadas y límites de triángulos por plataforma.
- Siluetas y proporciones originales; no copiar diseños protegidos de películas.

### 2. Kaijus
- Siluetas distintas por categoría I–V.
- Anatomía y locomoción propias, escala legible junto al Jaeger.
- Rig y clips: idle, desplazamiento, ataque telegráfico, impacto, retirada/derrota.
- Materiales orgánicos PBR, placas, bioluminiscencia moderada y variantes de daño no gráficas.
- Catálogo y fichas deben distinguir arquetipos diseñados de enemigos ya implementados.

### 3. Base / Shatterdome
Módulos modulares con pivotes y nombres estables:
- Hangar abierto con grúa, compuertas, plataformas y escala de Jaeger.
- Centro de mando, reactor, taller, almacén, centro médico y evacuación.
- Defensa perimetral, torres ficticias de vigilancia, barreras, sensores y puertas.
- Calles de servicio, helipuerto, muelles, tuberías, cables y señalética PPDC original.
- Estados visuales por nivel: construcción, operativo, mejorado, dañado y reparación.
- Luces, pantallas y máquinas deben reflejar los niveles reales del sistema, no valores decorativos inventados.

### 4. Ciudades y entorno
- Ciudad costera modular: rascacielos, puerto, puentes, carreteras, barrios y refugios.
- NPC civiles con siluetas variadas y animaciones simples; rutas de evacuación legibles.
- Océano, espuma, lluvia, charcos, niebla, humo no voluminoso en exceso y cielo dinámico.
- Destrucción por estados/variantes controladas, sin simular destrucción realista de forma costosa.

### 5. Interfaz
- HUD diegético inspirado en paneles de mando PPDC: tipografía legible, jerarquía clara y contraste.
- Menús de Hangar, Base, Campaña, Kaiju Codex, Alianzas y Chat con una misma cuadrícula visual.
- Indicadores accesibles de integridad, energía, recursos, objetivo y estado de conexión.
- Diseño responsive para PC, tableta y móvil; no tapar el campo de visión.
- Estados vacíos, carga, error, desconectado y reconexión para todas las vistas online.

## Contrato técnico de assets
- Formato preferido: GLB/GLTF; texturas PBR en PNG/WebP según necesidad.
- Un asset por archivo, nombres en kebab-case, escala en metros y origen/pivote documentado.
- Carpeta propuesta: `public/assets/jaegers/`, `public/assets/kaijus/`, `public/assets/base/`, `public/assets/cities/`, `public/assets/ui/`.
- Manifiesto JSON por asset: id, nombre, ruta, escala, bounds, LODs, clips, versión y estado de aprobación.
- Carga mediante GLTFLoader con fallback procedural si falla el archivo.
- No incorporar assets sin licencia clara ni modelos extraídos de películas/juegos.

## Orden de producción
1. Jaeger principal completo y escala de referencia.
2. Hangar modular con una unidad desplegable.
3. Kaiju de misión 1 y su rig.
4. Animaciones de locomoción y combate.
5. Base modular y reflejo visual de sus niveles.
6. Ciudad costera, civiles y evacuación.
7. Iluminación, efectos, audio y optimización.
8. LODs, pruebas de rendimiento y validación visual por dispositivo.

## Criterio de aceptación
Un elemento solo se marca como terminado cuando el asset existe en el repositorio, carga en Three.js, tiene escala correcta, materiales revisados, animaciones probadas, fallback y presupuesto de rendimiento documentados. Una imagen conceptual o un modelo procedural no cuenta como modelo final.

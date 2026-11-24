# Dirección visual y pipeline Higgsfield — TITANES DEL PACÍFICO

## Norte artístico

Ciencia ficción industrial de escala monumental: maquinaria pesada, ingeniería naval, tecnología militar ficticia, lluvia costera, niebla salina, hormigón húmedo, luces de señalización y desgaste funcional. La imagen debe comunicar peso, escala y humanidad; evitar el aspecto plástico, fantasía medieval o neón excesivo.

## Biblia visual

### Paleta
- Azul petróleo y acero frío para el entorno PPDC.
- Gris titanio, grafito y metal desgastado para Jaegers.
- Ámbar de advertencia para sistemas activos.
- Cian frío para pantallas, sensores y energía.
- Rojo de emergencia solo para alertas críticas.
- Luz cálida localizada en zonas habitadas para mostrar presencia civil.

### Materiales
- PBR con roughness variada, metalness controlada y desgaste en bordes.
- Paneles con tornillos, juntas, cables protegidos, placas de mantenimiento y numeración técnica.
- Vidrio grueso con reflejos sobrios; superficies mojadas sin convertir todo en espejo.
- Escala física coherente: puertas, vehículos, pasarelas y personas sirven como referencia de tamaño.

### Jaegers
- Silueta legible a distancia y distinta por clase.
- Articulaciones mecánicas visibles, actuadores, placas reemplazables y puntos de mantenimiento.
- Emblemas PPDC y numeración original.
- Cada unidad necesita vistas frontal, lateral, posterior, tres cuartos y hoja de materiales.
- Mantener proporciones, color, marcas y accesorios entre todas las imágenes de referencia.

### Kaijus
- Siluetas originales, anatomía coherente y lenguaje visual por categoría.
- Variación de placas, bioluminiscencia y textura sin copiar criaturas de películas.
- Hojas de frente, perfil, espalda, cabeza y escala comparativa.
- Las referencias de imagen no sustituyen el modelo 3D, rig, colisiones ni animación.

### Hangares y ciudades
- Hangar con grúas, soportes, plataformas, ascensores, líneas de servicio y personal a escala.
- Ciudad costera con distritos diferenciados, defensas, puerto, infraestructura y rutas de evacuación legibles.
- Crear módulos reutilizables y variaciones de iluminación/clima para reducir coste de producción.

## Uso de Higgsfield como preproducción

Higgsfield se usa para explorar conceptos, hojas de referencia, keyframes y clips cinematográficos. Su documentación describe generación de imágenes, consistencia de personajes y producción de video con controles de cámara. El material final debe pasar por revisión y convertirse en assets optimizados del juego.

Flujo recomendado:
1. Escribir una ficha canónica del sujeto: ID, silueta, proporciones, paleta, materiales, marcas y elementos que nunca cambian.
2. Generar una imagen maestra limpia de frente/tres cuartos con fondo simple.
3. Generar vistas adicionales usando la imagen maestra como referencia; revisar que no cambien proporciones ni piezas.
4. Crear keyframes para escenas: llegada del Jaeger, activación del hangar, alerta costera y presentación de la ciudad.
5. Para video, seleccionar movimiento de cámara que apoye la escala (dolly lento, grúa, órbita controlada o plano fijo); evitar movimiento aleatorio que deforme el diseño.
6. Aprobar la imagen fija antes de animar. Revisar anatomía, continuidad, marcas, geometría y legibilidad.
7. Modelar/retopologizar en Blender u otra herramienta 3D, crear UVs, materiales PBR, rig, colisiones y LOD.
8. Exportar GLB/GLTF y probar en Three.js dentro del juego.

## Prompts maestros

### Jaeger — hoja de diseño
"Original colossal industrial rescue-defense mech, Pacific coastal defense engineering, full body three-quarter orthographic concept sheet, readable mechanical silhouette, layered titanium armor, exposed hydraulic joints, service panels, heavy feet, believable industrial construction, restrained blue-grey steel palette with amber status lights, realistic PBR material study, neutral studio lighting, clean plain background, consistent proportions, no text, no logos from existing franchises."

### Hangar — keyframe
"Monumental original coastal defense mech hangar, colossal gantry cranes, maintenance platforms, elevator pits, technicians as tiny scale references, wet concrete, steel trusses, volumetric shafts of cold light, restrained amber warning beacons, cinematic wide establishing frame, grounded industrial architecture, realistic scale, no recognizable movie set or franchise elements."

### Ciudad costera — keyframe
"Original Pacific coastal megacity built around a fortified harbor, seawalls, shipyards, elevated transit, evacuation signage, dense humid atmosphere, rain haze, realistic contemporary infrastructure expanded to monumental scale, cinematic aerial establishing frame, cold blue-grey palette and warm inhabited windows, no recognizable real-world landmark."

## Entrega de arte

Cada asset aprobado debe tener:
- archivo fuente y exportación de runtime;
- licencia/origen y fecha de creación;
- ficha de dimensiones, escala, pivote y unidades;
- materiales y texturas con resolución;
- rig y lista de animaciones, si aplica;
- LOD y presupuesto de polígonos;
- captura de prueba dentro del motor.

No integrar videos generados como sustituto del gameplay. Los clips se reservan para tráiler, introducciones y material promocional; el juego usa modelos, animaciones, materiales y efectos en tiempo real.

## Rendimiento
- Priorizar GLB/GLTF optimizado, texturas comprimidas y LOD.
- Reutilizar módulos de edificios y materiales.
- Limitar luces con sombras y partículas simultáneas.
- Mantener versiones fuente fuera del bundle de producción cuando sean pesadas.
- Probar primero en el equipo objetivo de menor capacidad.

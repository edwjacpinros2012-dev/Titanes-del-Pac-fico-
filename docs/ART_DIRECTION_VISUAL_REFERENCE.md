# Dirección artística — Referencia visual original

Fecha: 24 de noviembre de 2026  
Formato objetivo: 16:9 horizontal, cámara 3D cinematográfica  
Motor: Godot 4.3, renderer Compatibility como base de rendimiento

## Identidad

**Tono:** ciencia ficción militar-industrial, escala colosal, costa del Pacífico, tecnología de rescate y defensa, clima oceánico y desgaste funcional.

El mundo debe sentirse construido para operar máquinas gigantes: estructuras reforzadas, plataformas de mantenimiento, puertas monumentales, señalización de seguridad, grúas, depósitos, luces de navegación y zonas de evacuación.

## Paleta

| Uso | Color orientativo | Aplicación |
|---|---|---|
| Azul abisal | #082B3B | océano, sombras profundas |
| Acero frío | #526A78 | armadura y estructuras |
| Grafito | #1C2830 | juntas, maquinaria |
| Cian reactor | #27C9E8 | energía y estados activos |
| Ámbar industrial | #F2A23A | avisos y señalización |
| Rojo alerta | #E94C4C | peligro y estados críticos |
| Niebla costera | #A8BBC1 | atmósfera y distancia |

## Jaegers / Centinelas

- Silueta vertical reconocible a gran distancia.
- Proporciones industriales, placas superpuestas y articulaciones legibles.
- Centro de masa y pies anchos para comunicar peso.
- Materiales PBR con variación de roughness, pintura gastada, bordes pulidos y marcas de mantenimiento.
- Reactor con emisión cian moderada, sin quemar la exposición de la escena.
- Cada unidad debe tener proporciones, cabeza, hombros y silueta diferentes; no resolver la variedad cambiando únicamente el color.
- Animaciones requeridas: idle, walk, run, turn, hit_react, interact y evolution.
- El modelo de colisión debe ser simple y separado de la malla artística.

## Kaijus / Abisales

- Silueta orgánica y asimétrica, inspirada en fauna marina abisal sin copiar criaturas existentes.
- Lectura clara de cabeza, torso, extremidades y cola.
- Placas, crestas y bioluminiscencia como rasgos de especie.
- Variar altura, anchura, postura y locomoción entre clases.
- Estados visuales legibles: patrulla, alerta, aproximación, preparación, recuperación y retirada.
- El prototipo actual usa primitivas geométricas; no debe confundirse con el arte final.

## Shatterdome y base

- Hangar monumental con escala humana secundaria para comparar tamaño.
- Puertas, raíles, plataformas de mantenimiento, grúas y puentes técnicos.
- Reactor, taller, almacén, centro médico, centro de mando y zonas de evacuación.
- Los edificios deben tener siluetas distintas y una función reconocible.
- La construcción debe mostrar estado: plano, obra, operativo, mejorado y dañado.

## Ciudades y regiones

- Costa urbana con horizonte profundo, mar visible y capas de niebla.
- Edificios modulares con variación de altura y densidad.
- Carreteras, muelles, rompeolas, puentes, faros y zonas de evacuación.
- Las regiones posteriores deben variar clima, relieve, vegetación, arquitectura y color ambiental.
- La destrucción se implementará por etapas visuales controladas; priorizar rendimiento y legibilidad.

## Cámara e iluminación

- Formato horizontal 16:9 como referencia principal.
- Cámara con seguimiento amortiguado, encuadre que preserve escala y lectura del objetivo.
- Luz direccional de mañana/tarde, ambiente frío y niebla costera.
- Luces emisivas reservadas para reactores, balizas y señales.
- Evitar demasiadas sombras dinámicas en dispositivos modestos.
- El HUD debe dejar libre el centro de pantalla y adaptarse a distintas relaciones de aspecto.

## HUD y menús

- Jerarquía clara: objetivo, integridad, energía y estado de misión.
- Paneles oscuros translúcidos con bordes técnicos discretos.
- Tipografía sans-serif legible y números tabulares.
- Colores de estado consistentes: cian = información activa, ámbar = advertencia, rojo = crítico, verde = confirmado.
- Botones táctiles grandes, separados y ubicados en los bordes.
- Mantener pausa, accesibilidad, volumen, sensibilidad y calidad gráfica en opciones.

## Pipeline 3D

1. Boceto de silueta y proporciones.
2. Bloqueo de volúmenes.
3. Modelado de alta y baja complejidad.
4. UV y materiales PBR.
5. Rig y animaciones.
6. Exportar GLB/GLTF.
7. Importar en Godot y revisar escala, origen, materiales y animaciones.
8. Preparar LOD y colisiones simplificadas.
9. Integrar en una escena de prueba y medir rendimiento.

## Reglas de originalidad

Las referencias de otros videojuegos sirven para estudiar composición, legibilidad y ritmo de progresión. No reutilizar personajes, modelos, mapas, logotipos, capturas, texturas ni música protegida. Los diseños finales deben ser propios de Titanes del Pacífico.

## Fuentes técnicas

- Godot — organización de escenas y señales: https://docs.godotengine.org/en/stable/tutorials/best_practices/scene_organization.html
- Godot — CharacterBody3D: https://docs.godotengine.org/en/stable/classes/class_characterbody3d.html
- Godot — formatos 3D, GLB/GLTF recomendado: https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/available_formats.html
- Godot — conceptos de nodos, escenas y señales: https://docs.godotengine.org/en/latest/getting_started/introduction/key_concepts_overview.html

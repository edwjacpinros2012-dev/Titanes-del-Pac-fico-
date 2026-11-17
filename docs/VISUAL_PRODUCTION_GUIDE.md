# Guía de producción visual

## Objetivo
Convertir los sistemas en una experiencia visual coherente. Cada elemento visible debe tener función, escala, estado y conexión con los datos.

## Dirección artística
- Ciencia ficción industrial costera: metal usado, señalización de defensa, hormigón húmedo, salitre y luces de emergencia.
- Siluetas legibles: el Centinela debe distinguirse de edificios, fauna y Abisales.
- Paleta funcional: tonos fríos para instalaciones y acentos cálidos para alertas.
- Diseños, emblemas, sonidos, nombres y modelos originales.

## Jerarquía de escenas
WorldRoot
- EnvironmentRoot: cielo, iluminación, niebla y clima.
- TerrainRoot: suelo, agua, caminos y límites.
- BaseRoot: instalaciones, hangar y almacenes.
- ActorsRoot: Centinela, NPC, aliados y Abisales.
- POIRoot: recursos, descubrimientos, brechas y objetivos.
- EffectsRoot: partículas, impactos y audio posicional.
- NavigationRoot: zonas navegables y límites.
- UIRoot: HUD, mapa, objetivos y avisos.

## Escala y lectura
Usar una unidad Godot como metro y mantener una hoja de escala. El piloto/NPC ronda 1.7–1.9 m; puertas y módulos humanos, 2–4 m; vehículos de apoyo, 3–8 m. La altura final del Centinela y de cada clase Abisal se fija en la hoja de escala y se conserva entre modelo, cámara y colisiones.

## Contrato visual de cada entidad
Cada escena debe exponer un ID estable, raíz y colisión coherentes, punto de interacción, estados visuales (bloqueado, disponible, dañado, activo, completado), escala, pivote, LOD y procedencia/licencia del arte.

## Centinela
Separar cuerpo, cabeza, brazos, piernas, núcleo y puntos de montaje. Los módulos deben cambiar silueta y estadísticas desde una misma definición. Animaciones necesarias: reposo, caminar, giro, impacto, interacción, acción de combate ficticia, defensa, retirada y fuera de combate.

## Abisales
Cada clase necesita silueta, locomoción, anticipación de acciones, respuesta a impactos y retirada. El color nunca debe ser la única señal de peligro: añadir forma, icono y texto. Las variantes regionales necesitan una función ecológica y una mecánica reconocible.

## Instalaciones
Cada edificio necesita modelo exterior, mejora visible, estado de construcción/reparación, punto de interacción, conexión visual con energía/almacén y señal clara de avería o falta de recursos.

## Pipeline de assets
1. Bloqueo con primitivas y escala.
2. Silueta y modelo low-poly.
3. UV y materiales.
4. Rig y animaciones.
5. Colisiones y puntos de interacción.
6. LOD y perfil móvil.
7. Integración con estado de juego.
8. Pruebas de cámara, legibilidad y rendimiento.
9. Registro de licencia y versión.

## Rendimiento
Medir CPU/GPU, memoria de texturas, luces/sombras, actores con IA activa, partículas, draw calls y geometría visible. Aplicar LOD, visibilidad por distancia, instancing, pooling y simulación simplificada fuera de cámara. Compatibility no garantiza rendimiento por sí solo.

## Checklist
- [ ] Escala de cámara y modelo coherentes.
- [ ] Colisiones alineadas con la malla.
- [ ] HUD comunica estado y objetivo.
- [ ] Recursos y amenazas se reconocen sin depender solo del color.
- [ ] Daño visible coincide con daño lógico.
- [ ] Estado persiste al guardar/cargar.
- [ ] Asset funciona en perfil móvil bajo.
- [ ] Licencia y procedencia registradas.

# DIRECCIÓN ARTÍSTICA MAESTRA — TITANES DEL PACÍFICO
## Sustituye las referencias visuales anteriores en todas las fases

**Fuente principal:** PDF entregado por el usuario, *referencia visual del juego titanes del abismo.pdf*, 19 páginas. Esta guía convierte sus láminas en requisitos implementables. No es una afirmación de que existan ya modelos 3D finales.

## 1. Identidad visual global
- Realismo cinematográfico industrial, escala colosal y atmósfera costera del Pacífico.
- Paleta base: azul acero profundo, negro industrial, cian reactor, blanco frío, ámbar de alerta y naranja de emergencia.
- Iluminación de alto contraste: focos volumétricos en hangares, reflejos húmedos, niebla costera, lluvia y humo ambiental controlados.
- Materiales PBR: acero azul pintado y desgastado, acero negro industrial, metal oxidado, hormigón húmedo, panel cerámico, vidrio reforzado, metal cepillado y cableado.
- Evitar superficies limpias de juguete, siluetas cúbicas sin detalle y colores saturados uniformes.

## 2. Jaegers: selección, evolución y desbloqueo
La página 2 muestra una progresión de diez generaciones Mark I–X. Las páginas 3–5 muestran vistas ortográficas y familias de Jaegers. Se traducirá a un catálogo de unidades originales del juego:
- Al iniciar: elegir un único Jaeger inicial disponible, con ficha, rol y estadísticas visibles.
- La unidad inicial evoluciona por niveles/Mark; mejoras visibles en placas, reactor, iluminación, desgaste y accesorios.
- Los demás Jaegers permanecen bloqueados hasta cumplir misiones, hitos de campaña y requisitos de hangar.
- Cada unidad debe tener silueta, proporciones, paleta y rol reconocibles; no basta con cambiar el color del mismo modelo.
- Vistas de producción: frontal, trasera, lateral y tres cuartos; escala y proporciones coherentes.
- El catálogo del juego debe separar estado seleccionado, disponible y bloqueado, con requisitos explícitos.

## 3. Kaijus / Abisales
Páginas 6–10: catálogo por familias y categorías crecientes (I–X), con cambios de tamaño, postura, placas, crestas, cola y bioluminiscencia. Convertirlo en criaturas originales:
- Clasificación legible, nombre propio, categoría, tamaño de ficción y bioma.
- Cada familia debe tener anatomía y silueta diferenciadas: cuadrúpeda acorazada, nadadora hidrodinámica, bípedo pesado y forma abisal bioluminiscente.
- La categoría superior cambia masa, silueta y presencia, no solo estadísticas.
- Nunca reutilizar una única malla con otro color como criatura final.

## 4. Mundo, ciudades y defensa civil
Páginas 11–15: megaciudad costera nocturna, infraestructura portuaria, Shatterdome y zona urbana en emergencia.
- Construir ciudad por sectores: centro urbano, puerto, zona industrial, costa, vías elevadas, refugios y rutas de evacuación.
- Hacer que la escala se lea con edificios, vehículos, luces, señalización, agua y siluetas humanas pequeñas.
- El Shatterdome debe ser una instalación funcional: hangar principal, plataformas de despliegue, grúas, talleres, reactor, centro de mando, almacén y clínica.
- El escenario debe responder a eventos: lluvia, niebla, humo, alarmas, daños ambientales y cambios de iluminación, sin bloquear legibilidad ni rendimiento.

## 5. HUD y mapa táctico
Páginas 16–17:
- HUD limpio y oscuro: integridad del Jaeger, núcleo de energía, localización Kaiju, categoría de amenaza, objetivo, evacuación y estado del sector.
- Mapa de ciudad por sectores con rutas de evacuación, zona segura, zona de peligro, base, suministros y ubicación de amenaza.
- Alertas con jerarquía y color consistente: cian para información, ámbar para precaución y rojo/naranja para emergencia.
- Adaptar a pantalla horizontal, mando, teclado y controles táctiles.

## 6. Materiales y efectos
Páginas 18–19:
- Biblioteca de materiales PBR con variación de roughness, metalness, normal, desgaste y suciedad.
- Efectos ambientales: reactor azul/naranja, vapor industrial, humo, lluvia intensa, salpicaduras, niebla costera, chispas estilizadas, ondas de energía y luces de alarma.
- Efectos deben tener LOD, límites de partículas y opción de calidad reducida en equipos modestos.

## 7. Reglas de producción 3D
- Godot: preferir escenas modulares, nodos reutilizables y señales para desacoplar sistemas.
- Modelos finales en GLB/glTF; texturas PBR empaquetadas y nombres consistentes.
- Separar malla, rig, animaciones, materiales y colisiones.
- Jaegers: animaciones de reposo, marcha, giro, despliegue, daño, recuperación y victoria.
- Kaijus: reposo, desplazamiento, alerta, ataque abstracto, daño y retirada.
- Crear LODs, colisiones simplificadas, instancing para edificios repetidos y presupuestos de memoria por plataforma.

## 8. Aplicación a todas las fases
- Fase 1 — fundación: paleta, tipografía, iluminación, cámara, escala y lenguaje visual base.
- Fase 2 — vertical slice: una costa, un Jaeger inicial seleccionable, un Kaiju de referencia, HUD, objetivo y hangar con el estilo maestro.
- Fase 3 — hangar y progresión: evolución Mark, catálogo de unidades, desbloqueos, fichas, vistas de inspección y personalización.
- Fase 4 — mundo: ciudad por sectores, puerto, Shatterdome, refugios y rutas tácticas.
- Fase 5 — contenido: familias Kaiju, misiones, biomas, clima, materiales y efectos.
- Fase 6 — pulido: optimización, accesibilidad, controles, rendimiento, QA y consistencia visual.
Toda nueva escena, panel, recurso, misión, documento y asset debe enlazar esta guía y no volver a la referencia visual anterior.

## 9. Criterios de aceptación
- [ ] No quedan referencias de la guía anterior presentadas como dirección vigente.
- [ ] El menú inicial permite elegir la unidad inicial disponible.
- [ ] La evolución del Jaeger inicial es persistente y visible.
- [ ] Las demás unidades muestran requisitos reales de desbloqueo.
- [ ] Hangar, ciudad, Kaiju y HUD comparten la misma paleta/materiales.
- [ ] Hay vistas de inspección y fichas para las unidades.
- [ ] Los materiales y efectos tienen alternativas de rendimiento.
- [ ] Las escenas Godot se ejecutan y se prueban en el equipo objetivo.

## 10. Estado honesto
Esta guía es la especificación artística derivada del PDF de 19 páginas. Los modelos 3D cinematográficos, rigs, texturas finales, animaciones, ciudad completa y efectos de producción todavía requieren creación e integración. Los placeholders geométricos actuales no deben describirse como arte final.

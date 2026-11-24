# Biblia de referencia visual — TITANES DEL PACÍFICO

> Fuente visual recibida: **“referencia visual del juego titanes del abismo.pdf”**, 19 páginas.  
> Estado: documento de dirección artística y referencia conceptual; no representa modelos 3D finales ni recursos ya integrados al juego.

## 1. Identidad visual general

La portada (p. 1) define una ciencia ficción militar-industrial cinematográfica: escala gigantesca, hangares oscuros, iluminación azul/cian, reactores luminosos, metal pesado, humo, vapor y presencia amenazante de Kaijus. Las páginas 11–16 amplían esta identidad hacia ciudades costeras, bases oceánicas, operaciones de defensa y evacuación.

**Paleta y lenguaje visual**
- Base: azul noche, negro industrial, acero azul, gris hormigón.
- Luces funcionales: cian/azul para energía y tecnología; naranja/rojo para alertas, peligro y reactores cálidos.
- Materiales: metal pintado y desgastado, acero negro, óxido, hormigón húmedo, vidrio reforzado, blindaje cerámico y cableado industrial (p. 18).
- Atmósfera: lluvia, niebla costera, vapor, humo, chispas, salpicaduras y reflejos sobre superficies mojadas (p. 19).

## 2. Jaegers

Las láminas presentan familias y evoluciones visuales; las variantes MARK son exploraciones de diseño y no deben asumirse automáticamente como unidades desbloqueables.

| Referencia | Páginas | Rasgos observables / uso |
|---|---:|---|
| Jaeger azul de reactor cian | 2–3 | Armadura azul oscura, silueta robusta, núcleo circular luminoso. La p. 3 aporta vistas frontal, posterior, lateral y tres cuartos: referencia principal de proporciones y silueta. |
| Familia Striker | 4 | Armadura más clara, blanco/plata con acentos rojos y núcleo naranja; lectura visual de unidad ágil/interceptora. |
| Familia Cherno | 5 | Estructura pesada, tonos oscuros, detalles verdes y construcción industrial expuesta; lectura visual de unidad defensiva. |

**Regla de producción:** conservar una silueta reconocible por familia. Crear primero una vista frontal, lateral, posterior y tres cuartos aprobadas antes de modelar variantes.

## 3. Kaijus

Las páginas 6–10 muestran cinco familias con progresión de categorías y cambios de escala/silueta. Las etiquetas pequeñas de las láminas pueden ser difíciles de leer; usar los nombres y categorías visibles como identificadores de referencia, sin convertir sus cifras en estadísticas de juego sin validación.

| Familia | Página | Dirección de forma |
|---|---:|---|
| Raker | 6 | Criatura cuadrúpeda, perfil bajo, placas dorsales y silueta agresiva. |
| Brineback | 7 | Cuerpo ancho y acorazado, placas superpuestas y volumen pesado. |
| Razorfin | 8 | Perfil marino hidrodinámico, aletas/crestas y cola larga; silueta de depredador oceánico. |
| Dreadmaw | 9 | Figura más vertical y musculosa, mandíbula prominente, placas y extremidades potentes. |
| Abyssal Crown | 10 | Presencia dominante, crestas/corona craneal y acentos energéticos violetas/azules. |

**Regla de producción:** las categorías deben aumentar la amenaza visual mediante proporción, masa, placas, crestas y presencia; evitar que solo cambie el tamaño de una misma malla.

## 4. Mundo, escenarios y operaciones

- **Ciudad costera (pp. 12–14):** skyline denso junto al océano, puentes y vías elevadas, puerto industrial, lluvia y tormenta. La p. 14 ofrece una vista amplia útil para composición y distribución urbana.
- **Hangar Jaeger (p. 13):** instalación monumental con plataforma central, grúas, pasarelas, maquinaria, pantallas y escala humana para comunicar el tamaño del robot.
- **Base oceánica (p. 15):** complejo fortificado sobre el mar, muelles, rompeolas, radares, edificios técnicos y rutas de acceso.
- **Evacuación urbana (p. 16):** calles dañadas, refugios iluminados, vehículos de emergencia, civiles y señalización de rescate. Mantener la escena legible y no saturar el encuadre.
- **HUD de combate (p. 17):** integridad del Jaeger, energía, localización del Kaiju, categoría de amenaza, objetivo, civiles evacuados, defensa urbana y alertas tácticas.
- **Mapa estratégico (p. 18):** sectores residenciales e industriales, puerto, base principal, zonas peligrosas, refugios, rutas de evacuación, posición del Jaeger y detección del Kaiju.

## 5. Materiales y efectos

**Materiales de la p. 19**
- Acero azul pintado y desgastado.
- Acero negro industrial.
- Metal oxidado.
- Hormigón húmedo.
- Paneles de blindaje cerámico.
- Vidrio reforzado.
- Metal cepillado.
- Superficie de reactor luminosa.
- Cableado industrial.
- Pintura amarilla de seguridad.

**Efectos de la p. 19**
- Reactor azul y reactor naranja.
- Vapor industrial, humo ambiental y lluvia intensa.
- Salpicaduras de agua y niebla costera.
- Chispas eléctricas estilizadas y ondas de energía.
- Luces de alarma.

Para cada material PBR, producir mapas coherentes de albedo/base color, normal, roughness y metallic cuando corresponda. Los efectos luminosos deben separarse del material base para controlar intensidad y rendimiento.

## 6. Traducción a producción del juego

### Prioridad A — identidad y prototipos
1. Aprobar diseño base de las tres familias de Jaeger.
2. Aprobar una silueta representativa de cada familia Kaiju.
3. Crear un módulo de hangar y un bloque de ciudad costera.
4. Establecer escala comparativa Jaeger/edificios/Kaiju con referencias humanas.

### Prioridad B — mundo jugable
1. Construir módulos reutilizables de puerto, base, edificios, carreteras y refugios.
2. Preparar sectores urbanos y rutas de evacuación legibles.
3. Separar HUD de combate y mapa estratégico como interfaces distintas.
4. Implementar lluvia, niebla, vapor, humo y reflejos como efectos configurables.

### Prioridad C — calidad y optimización
1. Exportar modelos como GLB/GLTF con pivotes, nombres y escalas consistentes.
2. Preparar LODs, colisiones simplificadas y texturas PBR.
3. Crear rigs y animaciones separadas para locomoción, combate y daño.
4. Validar rendimiento en el navegador objetivo antes de sustituir los modelos procedurales actuales.

## 7. Estructura sugerida de assets

```text
public/assets/
  reference/
    README.md
    jaegers/
    kaiju/
    environments/
    ui/
    materials/
    vfx/
  models/
    jaegers/
    kaiju/
    environments/
  textures/
    pbr/
  animations/
  vfx/
```

Las imágenes de referencia deben mantenerse separadas de los modelos finales. Usar nombres descriptivos y conservar la página de origen en los metadatos o en un archivo de notas.

## 8. Límites de esta referencia

- Las imágenes son arte conceptual/guía visual; no contienen mallas editables, rigs, UVs ni mapas PBR utilizables directamente.
- Las láminas con muchas variantes sirven para explorar lenguaje de diseño; se necesita una ficha individual limpia por unidad para modelado.
- No inferir dimensiones exactas, estadísticas, hitboxes ni comportamiento a partir de las ilustraciones.
- Antes de reemplazar assets existentes, comprobar compatibilidad con la escena, materiales, animaciones, escala y rendimiento.

## 9. Índice de páginas

| Página | Contenido |
|---:|---|
| 1 | Portada e identidad general |
| 2 | Variantes MARK de Jaeger azul |
| 3 | Vistas ortográficas y tres cuartos del Jaeger azul |
| 4 | Variantes MARK de Striker |
| 5 | Variantes MARK de Cherno |
| 6 | Familia Raker, categorías |
| 7 | Familia Brineback, categorías |
| 8 | Familia Razorfin, categorías |
| 9 | Familia Dreadmaw, categorías |
| 10 | Familia Abyssal Crown, categorías |
| 11 | Dirección artística y diseño conceptual de la ciudad |
| 12 | Hangar principal |
| 13 | Ciudad costera panorámica |
| 14 | Base/instalación oceánica |
| 15 | Distrito urbano de evacuación |
| 16 | HUD de combate |
| 17 | Mapa estratégico de sectores |
| 18 | Biblioteca de materiales |
| 19 | Biblioteca de efectos visuales |

---
**Uso previsto:** fuente de consistencia visual para arte, modelado 3D, escenarios, interfaz y VFX de TITANES DEL PACÍFICO.

## 10. Conexión implementada con el runtime

La dirección artística ya tiene una primera conexión funcional con la escena Three.js:

- `src/visual-direction.ts` contiene perfiles cinematográficos para lluvia/tormenta, niebla/bruma y cielo nublado/viento.
- `src/mission-director.ts` entrega el clima de cada misión mediante `MissionBlueprint.weather`.
- `src/main.ts` consulta ese clima para ajustar el color del cielo, la niebla, la iluminación ambiental, la luz principal, el acabado del suelo y el color del océano.
- El escenario incluye una superficie oceánica separada y un corredor costero industrial.
- El HUD identifica el distrito y el clima de la operación.

**Alcance:** esta conexión aplica la paleta y la atmósfera al entorno procedural existente. Las láminas del PDF no se han convertido automáticamente en texturas ni modelos 3D; esos recursos deberán importarse como archivos de arte aprobados y optimizados.

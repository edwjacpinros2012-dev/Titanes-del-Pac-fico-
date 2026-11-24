# Fase 3 — Jaegers, Kaijus, tecnología y dirección 3D

## Objetivo

Convertir el prototipo de figuras simples en unidades 3D originales, reconocibles y conectadas con la progresión. Mantener el juego web Vite + TypeScript + Three.js; no trasladar el proyecto a Godot ni crear una segunda aplicación.

## Dirección artística original

- **Jaegers:** escala colosal, silueta industrial pesada, placas de acero azul/gris, juntas mecánicas oscuras, pistones, paneles de mantenimiento, luces de reactor ámbar y marcas de uso.
- **Striker:** perfil más delgado, hombros aerodinámicos y propulsores dorsales.
- **Cherno:** silueta pesada, hombros y antebrazos reforzados.
- **Gipsy:** unidad equilibrada con reactor central visible.
- **Kaiju:** anatomía asimétrica, placas orgánicas, crestas dorsales, cola articulada y canales bioluminiscentes cian.
- **Escenarios:** costa industrial, puerto, ciudad, niebla, lluvia, escala ambiental y luces de emergencia.

La ilustración conceptual original se generó como guía de diseño en la conversación. No se debe presentar como modelo 3D ni como textura final del juego.

## Implementado en el prototipo web

- Modelado procedural Three.js del Jaeger con torso por capas, reactor, cabeza, visor, hombros, brazos, manos, piernas, articulaciones, pistones y placas.
- Tres perfiles visuales diferenciados para Gipsy, Striker y Cherno.
- Modelo procedural de Kaiju con cabeza, mandíbula, ojos, placas, extremidades, crestas dorsales y cola articulada.
- Animación procedural de reposo, balanceo y movimiento básico.
- Evacuación de civiles con movimiento hacia la zona segura cuando el Kaiju presiona la ciudad.
- Mejoras económicas persistentes y límites de nivel para evitar progresión ilimitada.
- Almacén con capacidad que aumenta realmente al mejorarlo.
- Componentes de armadura utilizables para reparar el Jaeger.
- Compra de datos de inteligencia y árbol de investigación persistente:
  - Blindaje compuesto: mejora la armadura.
  - Interfaz neuronal: mejora la agilidad.
  - Reactor de alto rendimiento: mejora la producción de energía.
- Guardado versión 4 con migración desde versiones anteriores y conservación de las tecnologías investigadas.

## Pendiente para un modelo 3D de producción

El modelo actual está construido con geometría procedural. Todavía no equivale a un modelo de alta calidad esculpido, texturizado y riggeado en Blender.

1. Crear modelos originales de alta resolución y retopología para Jaegers y Kaijus.
2. Separar piezas móviles y definir esqueletos/armatures.
3. Crear clips de animación: reposo, caminar, giro, impacto, recuperación y derrota.
4. Exportar como glTF Binary (.glb) con materiales PBR, texturas y animaciones.
5. Cargar los modelos con Three.js GLTFLoader y reproducir clips con AnimationMixer.
6. Añadir niveles de detalle, compresión y límites de memoria para equipos modestos.
7. Validar cada asset en el navegador y mantener un modelo procedural de respaldo si falla la carga.

## Economía y progresión — reglas de esta fase

- Recursos válidos: aleación, energía e inteligencia.
- Costes y recompensas se validan antes de guardar.
- Compras, reparaciones, mejoras e investigación se persisten como transacciones.
- Capacidad inicial del almacén: 2.500 unidades; cada nivel de almacén añade 1.500.
- Mejoras de Jaeger e instalaciones: máximo 10 niveles.
- La investigación exige misiones completadas y recursos; no se desbloquea todo desde el inicio.
- La campaña y el combate deben conservar consecuencias: integridad del Jaeger, integridad de ciudad, rescates y resultados.

## Referencias técnicas consultadas

- Three.js GLTFLoader: https://threejs.org/docs/pages/GLTFLoader.html
- Three.js — Loading 3D Models: https://threejs.org/manual/pages/loading-3d-models.html
- Blender Manual — glTF 2.0: https://docs.blender.org/manual/en/latest/addons/scene_gltf2.html
- Kenney — licencia CC0 para assets generales: https://kenney.nl/support

Kenney se considera solo para props ambientales genéricos si hacen falta; los Jaegers y Kaijus principales deben seguir siendo diseños originales del proyecto.

## Estado honesto

La fase de prototipo 3D y progresión ya tiene una primera implementación funcional en código. La conversión a assets GLB riggeados, la animación de producción, más arquetipos de Kaiju y la validación visual completa siguen pendientes. No marcar esta fase como terminada hasta comprobar el resultado en navegador.


## Clasificación de unidades y amenazas — ampliación

### Categorías de Jaeger
La categoría define la función táctica y el estilo de juego, no solo la apariencia:
- **Equilibrado — Gipsy:** versátil, adecuado para aprender y adaptarse a distintos escenarios.
- **Interceptor — Striker:** movilidad y respuesta rápida; especializado en reposicionamiento.
- **Guardián — Cherno:** blindaje y protección de zonas urbanas; sacrifica movilidad.

Las estadísticas visibles (armadura, potencia y agilidad) siguen conectadas con la selección y la progresión de cada unidad.

### Categorías de Kaiju
Catálogo original de amenazas de cinco niveles, inspirado en la idea general de escalas de amenaza de la ficción Kaiju, pero con nombres y descripciones originales del juego:
- **CAT-I Raker — Explorador:** amenaza ligera y veloz.
- **CAT-II Brineback — Blindado:** avance resistente.
- **CAT-III Razorfin — Acuático:** presión rápida en la costa.
- **CAT-IV Dreadmaw — Asedio:** resistencia y presión urbana prolongada.
- **CAT-V Abyssal Crown — Colosal:** amenaza estratégica de escala extrema.

El códice describe arquetipos y protocolos de respuesta ficticios. No implica que los cinco estén ya conectados a misiones jugables; el catálogo diferencia contenido diseñado de contenido implementado.

### Defensa y evolución de la base
Las instalaciones ya existentes se conectan a una valoración defensiva común:
- **Defensa perimetral:** aporta 8 puntos por nivel.
- **Centro de evacuación:** aporta 4 puntos por nivel y mejora la protección civil.
- **Centro médico:** aporta 2 puntos por nivel y mejora la protección civil.
- La valoración se limita a 90; reduce el daño urbano de las misiones hasta un máximo del 60%.
- La mejora de instalaciones consume recursos y respeta el máximo de 10 niveles.
- El resultado de una misión aplica la mitigación antes de descontar integridad de ciudad. Victoria, derrota y retirada siguen dejando consecuencias.

### Integración de interfaz
- El Hangar muestra la categoría, especialidad y pasiva de cada Jaeger.
- El panel Kaijus presenta las cinco categorías, rasgos y protocolos.
- El panel Base muestra valoración defensiva, reducción estimada de daño y protección civil.
- Los niveles de las instalaciones siguen reflejándose en los grupos 3D ya existentes.

## Referencias de diseño y tecnología
- El material promocional de Warner Bros. para Pacific Rim muestra el uso de categorías Kaiju como escala de amenaza; se usa únicamente como referencia conceptual, no se copian diseños ni textos: https://wwws.warnerbros.co.jp/pacificrim/media/kaiju_download.pdf
- El reglamento de Pacific Rim de Evil Hat describe chasis de Jaeger diferenciados por tamaño, blindaje y movilidad; se toma como referencia general para distinguir roles, no para copiar estadísticas: https://d1vzi28wh99zvq.cloudfront.net/pdf_previews/431901-sample.pdf
- El informe de AIRC sobre tower defense describe la relación entre construcción de base, producción de recursos y defensa ante oleadas: https://document.acqirc.org/publication_documents/reports/1671037095.1049.8.2A_Report.pdf
- Three.js GLTFLoader: https://threejs.org/docs/pages/GLTFLoader.html
- Three.js — Loading 3D Models: https://threejs.org/manual/pages/loading-3d-models.html

## Validación pendiente
Los cambios de interfaz y lógica requieren ejecutar `npm run build` y probar el juego en navegador. La mitigación defensiva ya se aplica al resultado persistente de misión, pero no debe anunciarse como multijugador ni como simulación completa de asedios en tiempo real.
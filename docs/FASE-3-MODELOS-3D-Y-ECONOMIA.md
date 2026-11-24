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

# Ruta de desarrollo

## Objetivo
Juego 3D original de exploración, supervivencia, recolección, fabricación, construcción y guerra de robots gigantes contra monstruos colosales. El jugador comienza como recluta con un Mark I y una base pequeña. Godot 4.3.

## Nuevo bloque de producción
- [x] Director de amenaza multidimensional desacoplado: preparación, condición del Centinela, sincronización, apoyo, inteligencia, presión regional y riesgo.
- [x] Catálogo de cuatro regiones con desbloqueos, biomas, peligros, recursos y objetivos.
- [x] Reglas de balance y diez niveles de amenaza legibles.
- [x] Guía visual y contratos de integración.
- [x] Guardado local con archivo temporal, copia de seguridad y recuperación.
- [x] Pruebas headless de recursos, guardado y director de amenaza.
- [x] Investigación comparativa con The Planet Crafter, Animal Crossing: New Horizons y demos oficiales de Godot.
- [x] Gestor modular del ciclo de misión: despliegue, operación, objetivos, informe y regreso a base.
- [x] Integrar el gestor de misión con el flujo de encuentros, resultados, recompensas y guardado del informe.\n- [ ] Integrar objetivos de exploración del mapa y reparación dentro del ciclo de misión.
- [x] Conectar el director de amenaza al informe de despliegue y al resultado de misión.\n- [ ] Mostrar avisos de preparación persistentes en el HUD y calibrar su efecto sobre encuentros.
- [ ] Completar restauración de todos los gestores.
- [ ] Construir y validar el primer encuentro 3D en tiempo real.
- [ ] Completar IA por estados y navegación de un Abisal.
- [ ] Conectar daño lógico con partes visuales del Centinela.
- [ ] Integrar catálogo regional en mapa y desbloqueos de campaña.
- [ ] Completar pantallas de hangar, inventario, investigación y resultados.
- [ ] Añadir especialistas asignables y relaciones individuales de NPC.
- [ ] Validar exportaciones y rendimiento en dispositivos reales.

## Orden obligatorio
1. Integridad de guardado y pruebas.
2. Ciclo jugable: salida, exploración, amenaza, operación, resultado, reparación y guardado.
3. Hangar, fabricación y progresión conectados.
4. Base visible y especialistas NPC.
5. Regiones, biomas y campaña.
6. Backend online solo después de estabilizar el modo individual.
7. Arte, audio, accesibilidad, optimización y exportación.

## Reglas de producto
La economía es ficticia. No habrá compras con dinero real, microtransacciones, suscripciones, anuncios ni Google Play Billing. Chat global debe permanecer desactivado hasta tener moderación y privacidad verificadas.

Un sistema solo se considera terminado cuando está integrado, probado manualmente en Godot y documentado. Presets no equivalen a exportaciones; esquemas SQL no equivalen a backend desplegado; archivos no equivalen a funciones verificadas.

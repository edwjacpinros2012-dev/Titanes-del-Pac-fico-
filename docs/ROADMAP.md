# Ruta de desarrollo

## Objetivo
Juego 3D original de guerra de robots gigantes contra monstruos colosales. El jugador comienza como recluta con un Mark I y una base pequeña. Godot 4.3.

## Nuevo bloque de producción
- [x] Rama feature/production-foundation-02 creada.
- [x] Director de amenaza multidimensional desacoplado: preparación, condición del Centinela, sincronización, apoyo, inteligencia, presión regional y riesgo.
- [x] Catálogo de cuatro regiones con desbloqueos, biomas, peligros, recursos y objetivos.
- [x] Reglas de balance y diez niveles de amenaza legibles.
- [x] Guía visual y contratos de integración.
- [x] Guardado local con archivo temporal, copia de seguridad y recuperación.
- [x] Pruebas headless de recursos, guardado y director de amenaza.
- [ ] Integrar el director en el gestor real de encuentros y HUD.
- [ ] Completar restauración de todos los gestores.
- [ ] Construir el primer combate 3D en tiempo real con controles y feedback.
- [ ] Completar IA por estados y navegación de un Abisal.
- [ ] Conectar daño lógico con partes visuales del Centinela.
- [ ] Integrar catálogo regional en mapa y desbloqueos de campaña.
- [ ] Completar pantallas de hangar, inventario, investigación y resultados.
- [ ] Añadir especialistas asignables y relaciones individuales de NPC.
- [ ] Validar exportaciones y rendimiento en dispositivos reales.

## Orden obligatorio
1. Integridad de guardado y pruebas.
2. Vertical slice: salida, exploración, amenaza, combate real, resultado, reparación y guardado.
3. Hangar, fabricación y progresión conectados.
4. Base visible y especialistas NPC.
5. Regiones, biomas y campaña.
6. Backend online solo después de estabilizar el modo individual.
7. Arte, audio, accesibilidad, optimización y exportación.

## Reglas de producto
La economía es ficticia. No habrá compras con dinero real, microtransacciones, suscripciones, anuncios ni Google Play Billing. Chat global debe permanecer desactivado hasta tener moderación y privacidad verificadas.

Un sistema solo se considera terminado cuando está integrado, probado manualmente en Godot y documentado. Presets no equivalen a exportaciones; esquemas SQL no equivalen a backend desplegado; archivos no equivalen a funciones verificadas.

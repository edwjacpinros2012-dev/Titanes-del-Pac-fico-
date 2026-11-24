# Investigación de diseño y arquitectura — Titanes del Pacífico

Fecha de revisión: 24 de noviembre de 2026. Este documento estudia patrones de diseño públicos; no copia código, personajes, modelos, mapas ni arte de otros juegos.

## Hallazgos del proyecto actual

- La versión web usa Vite + TypeScript, Phaser 3.90 y Three.js 0.181.
- El prototipo web ya contiene una escena 3D, una base costera, edificios, un Jaeger, un Kaiju, HUD, controles y un menú de hangar.
- `src/game-systems.ts` implementa campaña de 12 misiones, recursos, economía, mejoras, desbloqueos y guardado local con copia de respaldo.
- La propia interfaz de campaña reconoce que solo la misión 1 está conectada al combate y que las demás son escenarios pendientes. No deben anunciarse como 12 misiones jugables.
- Supabase tiene ocho tablas públicas con RLS: players, player_saves, player_inventory, alliances, alliance_members, global_messages, mission_results, resource_transactions y world_events. La revisión encontró cero filas en esas tablas y ninguna Edge Function.
- El guardado web actual usa localStorage. La presencia de tablas no demuestra que el cliente ya sincronice partidas con Supabase.
- Vercel publicó un commit anterior al último cambio de combate; se debe validar build y publicar el HEAD actual cuando se libere el límite de despliegues.

## Referencias de diseño consultadas

### MechWarrior 5: Mercenaries

La página oficial describe chasis con variantes, estados de daño, equipo, mantenimiento, contratos, gestión de pilotos, facciones y modo de misión independiente. Lección aplicable: separar la preparación del Jaeger, el despliegue, el resultado de misión y la gestión del hangar; el daño y las piezas deben tener efectos legibles y persistentes.

Fuente: https://mw5mercs.com/game

### Daemon X Machina

Las reseñas describen un ciclo de base/hub → selección de misión → combate → recompensas → personalización. También destacan que los objetivos y enemigos deben variar, pues repetir el mismo patrón vuelve monótona la campaña. Lección aplicable: variar condiciones de misión (defensa, rescate, reconocimiento, jefe) y enseñar pocas funciones nuevas por etapa.

Fuentes: https://www.gamespot.com/reviews/daemon-x-machina-review-tinker-toys/1900-6417298/ ; https://www.pcgamer.com/daemon-x-machina-review/

### Titanfall 2

En una entrevista, el equipo explicó que la campaña se diseñó alrededor de movilidad expresiva y sorpresas, en lugar de frenar al jugador constantemente. Lección aplicable: ofrecer desplazamiento claro, tutoriales breves y objetivos que usen el espacio del nivel de formas distintas.

Fuente: https://www.pcgamer.com/titanfall-2-interview-on-mechs-modes-and-the-new-campaign/

## Principios originales para Titanes del Pacífico

1. **Bucle principal:** Shatterdome → revisar Jaeger y base → elegir operación → desplegar → completar objetivos → informe de misión → recompensas → reparar/mejorar → siguiente operación.
2. **Combate legible:** telegráficos visuales claros para ataques enemigos, ventanas de reacción, distancia consistente, impacto visible, cámara estable y HUD que no tape la acción.
3. **Jaegers con identidad:** cada unidad tendrá silueta, paleta, animación, estadísticas y rol distintos; no basta con cambiar el color del mismo modelo.
4. **Kaijus diferenciados:** cada clase tendrá silueta, ritmo, patrón de movimiento, señales visuales y comportamiento de jefe propios. Mantener el diseño y los nombres originales.
5. **Misiones realmente distintas:** no mostrar una misión como jugable hasta que tenga escena/objetivo, condición de victoria/fracaso, recompensa, reinicio y pruebas.
6. **Daño y destrucción escalables:** empezar con piezas visuales simples y efectos de daño por etapas; no simular destrucción compleja antes de tener rendimiento estable.
7. **Accesibilidad:** modo horizontal, controles teclado/táctil, tamaño de HUD adaptable, sensibilidad y opción de reducir efectos intensos.
8. **Persistencia segura:** localStorage como modo invitado; Supabase Auth + RLS para cuentas; validar recompensas y progreso en servidor antes de abrir economía o alianzas online.
9. **Rendimiento web:** limitar luces/sombras dinámicas, reutilizar geometría/materiales, instanciar edificios repetidos, cargar modelos bajo demanda y probar en equipos modestos.
10. **Originalidad:** usar referencias para principios de diseño, no reutilizar recursos protegidos de películas o videojuegos.

## Arquitectura objetivo

- `src/game/`: escena, cámara, control del Jaeger, IA de Kaiju, combate y objetivos.
- `src/content/`: definiciones de Jaegers, Kaijus, misiones, sectores y recompensas en datos.
- `src/ui/`: HUD, menú, hangar, base, campaña y accesibilidad.
- `src/services/`: guardado local, autenticación y sincronización cloud.
- `public/assets/`: ilustraciones originales, texturas, audio y modelos optimizados.
- `supabase/migrations/`: esquema, políticas y funciones transaccionales versionadas.

## Orden de trabajo recomendado

### P0 — estabilidad y guardado
- Ejecutar `npm run typecheck` y `npm run build` en CI.
- Corregir selección de Jaegers bloqueados en el menú inicial y unificar la disponibilidad con la campaña.
- Añadir pruebas para recompensas, reinicio, desbloqueos y guardado corrupto.
- Implementar Auth y sincronización con revisión de RLS; resolver conflictos con número de revisión y nunca confiar en recompensas calculadas por el cliente.

### P1 — vertical slice de calidad
- Terminar una operación completa y repetible de principio a fin.
- Sustituir las primitivas del Jaeger y Kaiju por modelos originales riggeados, con animaciones de locomoción, giro, ataque, impacto y caída.
- Integrar una ciudad con módulos reutilizables, iluminación optimizada, niebla y efectos de ambiente.
- Crear dos tipos adicionales de objetivo y una variante de jefe con patrones fáciles de reconocer.

### P2 — contenido y comunidad
- Convertir las 12 misiones del catálogo en operaciones comprobadas, no solo tarjetas.
- Añadir perfiles, inventario cloud y resultados de misión con políticas de acceso revisadas.
- Mantener chat y alianzas deshabilitados hasta añadir moderación, reportes, bloqueos, límites de frecuencia y controles de seguridad.

## Criterio de terminado

Una función solo se marca como completa si compila, tiene pruebas, funciona con teclado y táctil cuando corresponda, conserva el progreso tras recargar, muestra estados de error y ha sido probada en el despliegue web. Los SVG de hangar son ilustraciones 2D de interfaz, no modelos 3D ni animaciones.

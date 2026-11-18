# Auditoría de segunda fase — brechas concretas del juego

**Fecha:** 18 de noviembre de 2026  
**Rama revisada:** main  
**Método:** revisión directa de archivos Godot, escenas, scripts, datos, documentación y resultados CI previos. No se ejecutó Godot en hardware del usuario; los hallazgos de integración son revisión de código y deben confirmarse con ejecución visual.

## Resumen ejecutivo

La base contiene muchos módulos, pero todavía existe una brecha grande entre **sistemas escritos** y **sistemas que realmente forman un juego continuo**. La escena principal concentra la orquestación y solo instancia una parte de los managers. Varios sistemas (misiones, expediciones, eventos de mundo, supervivencia, crafting genérico, región y construcción genérica) existen como scripts pero no están conectados al flujo de la escena principal.

**La siguiente etapa no debe ser seguir acumulando módulos desconectados.** El orden correcto es: cerrar un loop jugable mínimo, integrar módulos con contratos de datos claros, guardar/restaurar el estado, diseñar UI/controles de plataforma, y después ampliar el contenido.

## Hallazgos concretos por prioridad

### P0 — Bloquean un prototipo jugable completo

1. **Loop central incompleto:** el movimiento y recolección funcionan como prototipo, pero el encuentro se resuelve mediante una comparación de poder/táctica; no existe combate de acción completo con objetivos, duración, lectura de acciones, defensa y feedback.
2. **Integración parcial de managers:** `scripts/main.gd` instancia sincronización de pilotos, brechas, comercio, contratos, helicópteros, criaturas, NPC, encuentros, daño, frente de guerra, campaña, alianzas, tecnología y base. No instancia ni conecta el `MissionTracker`, `ExpeditionManager`, `WorldEventManager`, `RegionManager`, `SurvivalStats` o `CraftingManager` al loop principal en el código revisado. Los scripts sueltos no son funcionalidad accesible al jugador.
3. **Guardado incompleto de la sesión:** el perfil guarda recursos, créditos, investigación, niveles, instalaciones, tecnología, frente de guerra, encuentro/daño, alianza local y estado de NPC. No guarda posición del jugador, nodos recolectados, tiempo del mundo, estado de expediciones, contratos, helicópteros/temporizadores, región actual, clima/eventos, sincronización de pilotos, ni un inventario de misión activo. Algunos módulos no tienen export/import de estado. Debe decidirse qué persiste y añadirse pruebas de round-trip por sistema.
4. **Guardado robusto:** el perfil JSON se escribe directamente al archivo. Falta escritura temporal + sustitución, copia de respaldo, checksum/validación más amplia y recuperación de perfil corrupto. Probar cierre forzado, espacio insuficiente y versión antigua.
5. **Recompensas/consumo transaccional:** cada compra, crafting, recompensa de contrato, evento y misión debe garantizar “deducir o entregar todo, o nada”; confirmar idempotencia (no reclamar dos veces) y que el HUD no sea autoridad de los valores.
6. **Combate y consecuencias:** el estado de daño lógico debe conectarse a una experiencia visible; evitar que los resultados aparezcan como texto sin una actividad jugable. La derrota debe permitir recuperarse sin un ciclo de castigo imposible.

### P1 — Experiencia, legibilidad y contenido

7. **HUD provisional y saturado:** la interfaz principal es un panel con etiquetas largas, scroll y ayudas de teclas. En móvil puede ocupar demasiado espacio y esconder el entorno. Hace falta HUD por contexto, paneles separados (mapa, base, investigación, misión, inventario, combate, ajustes), iconos legibles, estados de objetivo y tutorial contextual.
8. **Controles táctiles incompletos:** el panel táctil tiene botones de movimiento y acciones básicas, pero el listado no incluye todas las acciones de teclado (por ejemplo, reconocimiento, sincronización, estabilizar brecha, guardar y opciones de compra/venta del mercado). No hay control táctil de cámara por arrastre. Verificar múltiples dedos, tamaños, posiciones y safe areas.
9. **Adaptación de pantalla:** el HUD y paneles usan dimensiones/posiciones fijas y no hay layout completo por relación de aspecto, notch/safe-area, ventana redimensionable, escala de UI o accesibilidad. El panel online de escritorio se posiciona a una coordenada fija.
10. **Mundo vacío/provisional:** terreno plano, escenario de demostración, nodos de recursos con primitivas y estructuras de base provisionales. Faltan zonas con verticalidad, caminos, obstáculos, landmarks, interacción ambiental, límites del mundo, streaming/ocultación y LOD.
11. **NPC:** la población tiene personajes de primitivas, rutas sencillas y solicitudes. Falta sistema de diálogo ramificado, interacción con contexto, animación, asignación a instalaciones, especialista con beneficios, rutina coherente, memoria de decisiones y persistencia de ubicación/turno.
12. **Amenazas/ecología:** catálogo original de enemigos, pero falta sistema de señales/rastros, comportamiento por estados, navegación, adaptación al clima/sector, variantes de encuentro, jefes con fases y objetivos distintos. No hacerlos mascotas; conservarlos como amenazas de fantasía.
13. **Misiones:** falta un director de misiones que conecte campaña, contratos, NPC, región, expedición, recursos, investigación y consecuencias. Necesita un registro claro, objetivos verificables, cancelación/reintento y recompensas únicas.
14. **Progresión:** Mark I–V, tecnología y evolución existen en lógica; falta comunicar requisitos, ramas, estadísticas comparables, nuevas habilidades/acciones por desbloqueo, tutorial y ritmo balanceado. El aumento visual de tamaño por nivel no debe sustituir nuevas capacidades.
15. **Base:** instalaciones lógicas y producción; falta colocación/edificación visible, obra por etapas, rutas de NPC, almacén visual, reparación/energía como red comprensible, daño de infraestructura y distribución de servicios.
16. **Economía y logística:** faltan tendencia de producción/consumo, inventario por categoría, historial de transacciones, capacidad por recurso, almacenes regionales, transporte de carga, contratos con variación y control de inflación de recursos.
17. **Audio y feedback:** no hay paisaje sonoro, música original, ambiente por bioma, interfaz sonora, señales de amenaza, feedback de hit/daño ni controles de volumen/subtítulos.
18. **Tutorial y onboarding:** falta ruta de primeros 15 minutos (movimiento, recolección, vuelta a base, mejora, investigación, misión, preparación, encuentro, recuperación y guardado), ayuda contextual, glosario y objetivo principal persistente.

### P2 — Sistemas para ampliar después de cerrar el loop

19. **Director de eventos regionales:** eventos guiados por estado real (escasez, clima, amenaza, daños, descubrimientos, NPC); eventos con inicio, objetivo, resolución, consecuencias y registro. Evitar eventos aleatorios sin contexto.
20. **Mapa de campaña:** regiones conectadas, control, amenaza, POI, recursos, rutas, información descubierta y reconquista. Actualmente el frente persistente se concentra en una zona y el viaje regional no está unido al loop.
21. **Expediciones:** seleccionar equipo/rol, objetivo, presupuesto, riesgo y tiempo; informe con éxito/parcial/incidente; reclamar una vez; persistir o resolver temporizadores offline con límites seguros.
22. **Facciones y reputación:** facciones originales con servicios, rangos y decisiones. Las alianzas demo local no son multiplayer.
23. **Especialistas y asignación:** NPC con roles de ingeniería, ciencia, logística, reconocimiento, comunidad y mantenimiento; slots, beneficios limitados y rotación no punitiva.
24. **Herramientas de campo no bélicas:** balizas, reparación, extracción, puentes, refugios, análisis de rastros y ayudas logísticas que cambien la exploración.
25. **Calidad de vida:** pausa, ajustes gráficos, audio, sensibilidad de cámara, remapeo, contraste, escala UI, idioma, subtítulos, guardar manual, confirmaciones y reanudación.
26. **Observabilidad:** menú debug solo de desarrollo con estado de managers, recursos, señales, timers, perfil, FPS, conteo de nodos y errores; logs estructurados sin datos personales.
27. **Contenido repetible:** variedad de POI, recursos, incidentes, contratos, regiones, objetivos opcionales, recompensa de colección de descubrimientos (sin captura de criaturas) y narrativas ambientales originales.

## Integración faltante: módulos presentes pero no conectados a la escena principal

| Módulo/script | Estado | Trabajo para integrarlo |
|---|---|---|
| `MissionTracker` | Script existente; no instanciado por main revisado | Director de misiones + señales HUD + save/load |
| `ExpeditionManager` | Script existente; no instanciado por main revisado | Panel expedición, progreso, cancelación, recompensas únicas y persistencia |
| `WorldEventManager` | Script existente; no instanciado por main revisado | Director regional; UI de evento, efecto en mundo y save/load |
| `RegionManager` | Script existente; no instanciado por main revisado | Mapa regional, viaje, desbloqueos, sector actual, save/load |
| `SurvivalStats` | Script existente; no instanciado por main revisado | Decidir si el Centinela tiene stamina/carga; conectar acciones y HUD, sin hacer grind |
| `CraftingManager` | Script existente; no instanciado por main revisado | Catálogo de recetas, UI, validación de costes, crafting con tiempo y persistencia |
| `BaseManager` genérico | Script existente; existe otra base lógica integrada | Unificar o aclarar el rol para evitar dos sistemas de base |
| `HUDController`/GameState | Scripts base, mientras main tiene su propio estado y HUD | Unificar autoridad de estado; evitar duplicación de recursos/niveles |

## Riesgos arquitectónicos observados

- `scripts/main.gd` es un coordinador muy grande (más de 45 KB en el archivo consultado) con creación de mundo, input, UI, estado, recompensas, guardado y online. Dividir gradualmente en `GameFlow`, `WorldBootstrap`, `InputRouter`, `HUD`, `SaveCoordinator`, `RewardService` y managers por feature; no hacer una reescritura total de golpe.
- Existe `GameState` (resources con energy/crystal) y el estado principal usa nombres españoles `energia/cristal`; existen también gestores que usan `inventory`. Definir IDs canónicos y migraciones antes de conectarlos.
- Los módulos deben emitir señales; UI muestra estado y no debe ser autoridad para comprar, gastar, reclamar o guardar.
- Todas las recompensas deben tener identificador de claim o estado de misión completada para prevenir duplicados.
- Los timers de juego y timers de mundo real deben diferenciarse. No permitir que el tiempo offline entregue recursos/recompensas de forma insegura.
- El nombre “Titanes del Pacífico” y referencias visuales necesitan originalidad y revisión de marca antes de publicación.

## Referencias externas de plataforma (consultadas)

- Godot 4.3 Android export: requiere configurar Java 17 y Android SDK/plantillas; exportación de tienda necesita bundle firmado y los iconos adaptativos/monocromos. [Documentación oficial](https://docs.godotengine.org/en/4.3/tutorials/export/exporting_for_android.html)
- Godot 4.3 rendimiento: medir con profiler, revisar CPU/GPU y probar en hardware móvil real; el rendimiento depende del dispositivo. [Optimización general](https://docs.godotengine.org/en/4.3/tutorials/performance/general_optimization.html)
- Godot 4.3 GPU móvil: atención al overdraw, densidad de geometría y LOD; probar cada plataforma desde temprano. [Optimización GPU](https://docs.godotengine.org/en/4.3/tutorials/performance/gpu_optimization.html)
- Godot 4.3 requisitos: renderer Compatibility es apropiado para un objetivo amplio, pero los mínimos y recomendados varían; no se puede afirmar compatibilidad universal. [Requisitos](https://docs.godotengine.org/en/4.3/about/system_requirements.html)

## Plan de cierre recomendado

### Fase 0 — Congelar expansión
No agregar más sistemas nuevos hasta que el loop central esté probado.

### Fase 1 — Vertical slice de 20–30 minutos
1. Tutorial: mover/cámara/controles.
2. Recolectar y volver a la base.
3. Fabricar un recurso/equipo desde un menú funcional.
4. Construir o mejorar una instalación visible.
5. Investigar una tecnología que cambie una capacidad.
6. Reconocer una amenaza y leer señales.
7. Encounter jugable con objetivo y feedback.
8. Resultado con recompensa/consecuencia.
9. Reparar y reabastecer.
10. Guardar, cerrar, abrir y restaurar exactamente el estado.
11. Desbloquear una región/POI.
12. Ver objetivo próximo en diario y HUD.

### Fase 2 — Integración y robustez
- Instanciar/conectar los módulos P0 que realmente formen parte del diseño.
- Pruebas de sistema con recompensa/consumo/guardado y casos de error.
- Consolidar GameState y contratos de IDs.
- Añadir backups y recovery al save.
- Completar touch controls y responsive UI.

### Fase 3 — Producción de contenido
- Vertical slice visual de la base y primer bioma.
- Centinela original con modelo, rig y animaciones.
- Una amenaza original con telegráficos, estados y patrones claros.
- Audio/feedback, misión tutorial y misión de defensa.
- Rendimiento objetivo definido por dispositivos de prueba.

### Fase 4 — Plataforma
- Export Windows y Android con artefactos reales.
- Pruebas manuales, hardware, suspend/resume, resolución, rendimiento, memoria y calor.
- Web solo si se decide mantenerla: probar WebGL/compatibilidad y empaquetado.
- Backend online se pospone hasta que offline local esté robusto.

## Checklist de aceptación del loop vertical

- [ ] Inicio nuevo conduce a objetivo/tutorial sin confusión.
- [ ] El jugador puede moverse y controlar cámara en PC y touch.
- [ ] Recolección consume un nodo una vez y respeta capacidad.
- [ ] Fabricación/upgrade descuenta costes completos o no cambia nada.
- [ ] Misión tiene objetivo, progreso, cancelación/reintento y claim único.
- [ ] Reconocimiento produce pistas accionables.
- [ ] Encounter tiene actividad jugable (no solo resultado numérico), señales legibles y opciones.
- [ ] Resultado modifica daño, recursos, región y campaña de forma coherente.
- [ ] Reparación cuesta recursos y permite recuperación.
- [ ] Save/load restaura cada estado que se prometió persistente.
- [ ] HUD se adapta a resolución y no oculta gameplay.
- [ ] Se puede jugar el loop 20 minutos sin errores ni bloqueos.
- [ ] El flujo está documentado y la CI prueba la lógica crítica.

## Conclusión

**El principal trabajo pendiente no es añadir más carpetas o scripts: es convertir los sistemas que ya existen en un juego coherente, accesible y verificable.** Las prioridades son integración, combate/loop real, guardado completo, interfaz y controles, contenido visual, QA de dispositivos y exportación.


## Actual code integration work — follow-up

**Commits on main (18 Nov 2026):**
- `df6a6424` adds `scripts/gameplay/game_loop_manager.gd`: starter mission, progress/reward, region unlock/travel, expedition progress/reward/cancel, regional event resource bonus, and export/import state.
- `eb58083d` connects that manager to main: mission and expedition rewards, collection reports, region unlock after starter mission, UI summary, and profile save/load.
- `ac1fb123` and `b37c46bb` add expedition toggle to touch control and main action dispatch.
- `3739f13e` adds tests for starter mission, unique completion, region locks/unlock/travel, expedition progress/completion, event bonus, and state restoration.
- `42da1923` adds repository checks for new manager and main/touch integration.

**Loop now wired in source:** gather metal → complete starter mission → receive energy/research → unlock Islas Quebradas → start/cancel expedition with M or touch button → gather crystals → expedition rewards. Regional timed event bonus is included in resource pickup and reported through UI.

**Validation limitation:** GitHub Actions for the latest commits is still running at time of writing. These changes are not yet claimed as CI-passed; inspect the latest workflow run before merging/continuing. Godot visual and physical-device testing still require installing/launching the engine on a computer/device.

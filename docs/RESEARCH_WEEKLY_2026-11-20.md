# Informe semanal de investigación de sistemas — 20 de noviembre de 2026

## Resumen

Esta semana se compararon patrones de gestión de población, logística, exploración por descubrimiento, eventos regionales y accesibilidad. El resultado principal no es añadir más managers aislados: **conectar los sistemas que ya existen y darles decisiones visibles, consecuencias y persistencia**.

La revisión de la rama `main` confirma que el proyecto ya tiene ocho NPC con rutas simples y solicitudes; economía/mercado, contratos, expediciones, regiones, criaturas, clima, eventos, campaña Mark I–V y guardado local. Hay módulos que todavía no están conectados a la escena principal. Por eso las propuestas siguientes se adaptan a esas piezas y no crean una segunda economía, un segundo director de misiones, otro sistema de regiones o una población paralela.

**Base revisada:** commit `c308d9de` (20-11-2026).  
**Cambios de QA de esta semana:** prueba adicional de solicitud de NPC, progreso, restauración y reclamación de recompensa. El commit de código `76725ce2` obtuvo CI de Godot **72 aprobadas, 0 fallidas**, importación, sanity check y smoke run completados. El smoke run sigue mostrando mensajes repetidos del renderer dummy (`Parameter \"m\" is null`); el job pasa, pero no es evidencia visual.  
**No se verificó:** recorrido visual en PC, dispositivo Android ni exportación APK. Las ejecuciones de CI disparadas por los commits de documentación todavía estaban en curso al revisar el estado.

## Comparación con sistemas que ya están documentados

| Área | Ya existe en el repo | Brecha comprobada/documentada | Decisión de esta semana |
|---|---|---|---|
| NPC | `NpcPopulationManager`, 8 personas, rutas por turnos, solicitudes, ánimo/confianza/alerta y export/import | Rutinas simplificadas; sin asignación de especialistas a instalaciones, navegación por obstáculos o diálogo ramificado | Ampliar el manager existente; no crear otra población |
| Economía | Mercado, créditos, existencias, producción de base, contratos y recompensas | No hay ledger unificado visible ni transporte regional conectado; transacciones de varios sistemas necesitan anti-duplicado | Crear ledger/transferencias sobre economía actual, no moneda ni inventario nuevos |
| Exploración | Regiones, POI, expediciones, helicópteros y descubrimientos | Mapa de sectores y estados de información no están integrados; expedición genérica tiene conexión incompleta | Un mapa que consuma los datos existentes |
| Misiones/eventos | Misión inicial y expedición en `GameLoopManager`; eventos de bonus temporales | Eventos mayormente aleatorios y simples; el `WorldEventManager` separado no está conectado; falta generación por necesidades | Un único director para misiones/eventos, reutilizando `GameLoopManager` o consolidándolo |
| Clima/ecología | `WeatherManager` y `CreatureEcosystemManager`; criaturas se desplazan y se observan | Clima no conectado al loop principal; observaciones no guardadas; fauna sin estados ecológicos persistentes | Integrar estados y efectos medibles antes de sumar especies |
| Mark I–V | `CampaignManager`, niveles y generación de Mark | Progresión existe en lógica; falta que cada etapa desbloquee capacidades/acciones visibles y un onboarding que lo explique | Capacidades y tutorial por etapa, no otra tabla de niveles |
| Save/load | Perfil con recursos, base, campaña, tecnología, frente de guerra, daño, NPC y loop; JSON con respaldo | Estado de mundo y otros módulos aún quedan fuera del snapshot según auditoría | Prioridad a un round-trip completo, versionado y pruebas |
| UI/accesibilidad | HUD y controles teclado/touch en prototipo | HUD provisional/saturado, layouts fijos, paridad de controles y opciones incompletas | Menús por contexto, ajustes guardados y tutorial corto |

## Referencias y patrones de diseño

### 1. RimWorld — programación de trabajo y horarios de habitantes
**Fuentes**
- [Work priorities](https://rimworldwiki.com/wiki/Work)
- [Schedules and activity thresholds](https://rimworldwiki.com/wiki/Menus)

**Qué aporta:** separar las tareas disponibles, la prioridad de cada tarea y la actividad general del día; las personas no deben intentar todas las tareas ni ignorar siempre sus necesidades.

**Adaptación original:** ficha de especialista con 1 rol principal, habilidad y preferencia; asignación a una instalación con un beneficio limitado. Las rutinas del personal se simplifican en cuatro bloques (trabajo, descanso, desplazamiento y emergencia) sin simular cada minuto.

**Evitar duplicado:** el proyecto ya mueve NPC entre puntos de ruta y tiene roles; esta idea no requiere una nueva IA de población.

### 2. Factorio — logística con solicitudes, fuentes y límites
**Fuente:** [Logistic network](https://wiki.factorio.com/Logistic_network)

**Qué aporta:** los pedidos de destino y las fuentes de suministro tienen límites; la movilidad de recursos depende de cobertura, energía, capacidad y prioridades. La automatización no es gratis ni infinita.

**Adaptación original:** panel de demanda de base y depósitos regionales, con cargas simuladas por viaje, límite de carga y gasto de energía. Primero transferencias manuales entre depósitos; automatización solo después de desbloquear un módulo logístico.

**Evitar duplicado:** no añadir otra tienda, inventario o robot genérico. Usar los recursos y almacén actuales.

### 3. Subnautica — escaneo, fragmentos y descubrimiento por bioma
**Fuentes**
- [Scanner](https://subnautica.fandom.com/wiki/Scanner_(Subnautica))
- [Scanner Room](https://subnautica.fandom.com/wiki/Scanner_Room_(Subnautica))

**Qué aporta:** observar y escanear transforma hallazgos en información/planos; una herramienta de exploración puede localizar elementos y consumir recursos de base, haciendo que preparar una expedición importe.

**Adaptación original:** cada POI tiene un conjunto de pistas/lecturas; analizar 1–3 registros desbloquea un módulo, una ruta o una nota de fauna. Un radar regional entrega indicios, no revela todo el sector.

**Evitar duplicado:** `DiscoveryLog`, POI y helicópteros ya existen. Integrar escaneo y persistencia en esos sistemas.

### 4. Frostpunk — eventos con contexto y decisiones
**Fuentes**
- [Events (community reference)](https://frostpunk.fandom.com/wiki/Events)
- [Frostpunk — gameplay overview](https://en.wikipedia.org/wiki/Frostpunk)

**Qué aporta:** eventos vinculados a cronología, decisiones o estados de la población; presentan contexto, una ventana de respuesta y consecuencia en el estado de la comunidad.

**Adaptación original:** evento de base provocado por falta de energía, almacenamiento lleno, clima adverso, infraestructura dañada o descubrimiento. Mostrar causa, opciones, costo/beneficio, plazo suave y registro de resultado. Siempre dejar una salida de recuperación.

**Evitar duplicado:** los eventos regionales ya dan un bonus de recurso. Extenderlos con condiciones y consecuencias en vez de crear otro manager paralelo.

### 5. No Man's Sky — asentamientos y gestión de comunidad
**Fuente oficial:** [Frontiers Update](https://www.nomanssky.com/frontiers-update/)

**Qué aporta:** población y asentamiento con variables que se muestran y se gestionan desde una interfaz; la comunidad y la producción forman parte de la progresión.

**Adaptación original:** un tablero de base que resume población, ánimo, confianza, alerta, producción y mantenimiento. Las decisiones de eventos afectan a dos o tres variables visibles, nunca a una docena de cifras ocultas.

**Evitar duplicado:** ánimo/confianza/alerta y ocho NPC ya existen; mejorar su panel y conectarlos a instalaciones.

### 6. Celeste — accesibilidad y comodidad de control
**Fuente oficial:** [Changelog](https://www.celestegame.com/changelog.html)

**Qué aporta:** ajustes separados para remapeo, vibración y movimiento de cámara; accesibilidad y comodidad no deben depender de un único modo de dificultad.

**Adaptación original:** controles remapeables, sensibilidad, vibración, movimiento de cámara, tamaño de texto/UI, contraste, subtítulos y acciones hold/toggle. Si se añade asistencia de gameplay, debe ser opcional, granular, reversible y por perfil.

**Evitar duplicado:** no crear un menú de control distinto por plataforma; centralizar acciones y ajustar la UI sobre `PlatformInput`.

## Propuestas priorizadas

### P0 — Completar el loop y la persistencia antes de expandir

**Propuesta:** cerrar el recorrido principal y completar un snapshot de guardado que incluya posición/región, estado de misión/expedición, descubrimientos, observaciones, clima/evento y nodos recolectados, según el alcance de cada módulo. Conservar el versionado y respaldo actual, y agregar migraciones cuando cambie el formato.

- **Dependencias:** `SaveManager`, `main.gd`, `GameLoopManager`, `DiscoveryLog`, `CreatureEcosystemManager`, `WeatherManager`, `RegionManager`.
- **Aceptación:** guardar → cerrar → abrir; recursos y estado restaurados; ningún objetivo/recompensa se repite; perfil corrupto recupera respaldo o muestra error; perfiles antiguos se migran sin perder datos.
- **Riesgos:** snapshot parcial, timers que pagan al cargar, restaurar nodos duplicados, estado de misión inconsistente.

### P1 — Especialistas asignables

**Propuesta:** asignar 6 roles (ingeniería, investigación, logística, reconocimiento, comunidad, mantenimiento) a slots de instalaciones. Una persona no puede ocupar dos slots. Un especialista aporta un bonus medible con tope, una tarea contextual y una descripción; la asignación se puede cambiar sin castigo permanente.

- **Dependencias:** `NpcPopulationManager`, `BaseDevelopmentManager`, producción/investigación, HUD, export/import del perfil.
- **Aceptación:** asignar/desasignar cambia exactamente un efecto; slot/rol inválido no modifica estado; bonus se ve antes y después; guardar/cargar mantiene asignación; sin bonus acumulado duplicado; 1 test positivo y 3 negativos.
- **Riesgos:** duplicar productividad, UI que muestra un especialista pero manager no lo aplica, demasiada microgestión. MVP: un slot por instalación elegible y seis roles; no simular fatiga individual todavía.

### P1 — Ledger y transporte de recursos

**Propuesta:** historial único de entradas, salidas, motivo, origen/destino y balance; transferencias entre almacén central y depósitos de región mediante viaje de carga ficticio. Los contratos y producción registran su transacción; no alteran recursos por una segunda vía.

- **Dependencias:** economía/mercado, `BaseDevelopmentManager`, inventario, regiones, contratos y save.
- **Aceptación:** balance por recurso coincide con suma de entradas/salidas; no hay saldo negativo; carga no supera capacidad; viaje cancelado o repetido no duplica; UI explica fuente y destino; persistencia del historial y cargas.
- **Riesgos:** log muy grande, recompensas duplicadas, el transporte convierte exploración en trámite. Limitar historial, automatización y número de cargas en MVP.

### P1 — Director de misiones/eventos emergentes

**Propuesta:** generar oportunidades por necesidades verificables (faltante de recurso, edificio sin energía, clima, hallazgo pendiente, sector bajo presión o solicitud de NPC). Elegir de plantillas, mostrar causa y evitar repetición. Misiones y eventos comparten una fuente de estado y resolución idempotente.

- **Dependencias:** `GameLoopManager`, contratos, NPC, economía, región, clima y frente de guerra.
- **Aceptación:** un evento no aparece sin condición registrada; máximo 1 evento urgente y 2 oportunidades; cooldown por plantilla; resultado éxito/parcial/expirado; recompensa única; cancelación/reintento; no bloquea el objetivo principal.
- **Riesgos:** conflicto con evento aleatorio actual, temporizadores demasiado exigentes, cadenas imposibles. Consolidar el `WorldEventManager` no conectado; no instanciar ambos directores.

### P2 — Mapa de sectores de campaña

**Propuesta:** mapa de 8 nodos para región inicial, con ruta, estado (desconocido, reconocido, disponible, bajo presión, asegurado), POI, recursos y condición de desbloqueo. El reconocimiento cambia lo que se sabe; viajar requiere ruta válida.

- **Dependencias:** `RegionManager`, `GameLoopManager`, `WarfrontStateManager`, POI, reconocimiento.
- **Aceptación:** nodos y rutas configurados en datos; ruta bloqueada muestra motivo; sector se desbloquea una sola vez; recon no revela todo; recuperar un sector abre al menos un servicio/expedición; guardado round-trip.
- **Riesgos:** mapas enormes prematuros, bloqueo sin alternativa y doble fuente de control regional. MVP con 8 nodos estáticos, sin mapa procedimental.

### P2 — Ecosistema y clima con consecuencias pequeñas

**Propuesta:** 2 especies iniciales con 3 estados observables (desplazamiento, alerta, reposo) y 2 condiciones ambientales (lluvia/niebla o tormenta). Clima modifica visibilidad, ritmo de reconocimiento y disponibilidad de un POI; no modifica arbitrariamente recompensas de combate. Las observaciones se guardan.

- **Dependencias:** `CreatureEcosystemManager`, `WeatherManager`, POI, `DiscoveryLog`, perfil.
- **Aceptación:** transición determinista reproducible; efecto de clima mostrado; sin duplicar observación/recompensa; datos persisten; límites de entidades activos y timers.
- **Riesgos:** demasiados actores y procesos por frame, clima molesto o sin explicación. Usar timers y estados simples; dejar fauna decorativa en baja actualización.

### P2 — Mark I–V con capacidades y onboarding gradual

**Propuesta:** mantener el `CampaignManager` y sus umbrales; cada Mark añade una capacidad o mejora funcional clara (movilidad, lectura del entorno, estabilidad, herramientas de exploración, gestión energética), con comparativa antes/después y misión de práctica. No hacer cinco mejoras que solo aumenten estadísticas.

- **Dependencias:** `CampaignManager`, evolución, árbol tecnológico, habilidades, UI, tutorial.
- **Aceptación:** cada Mark cambia una capacidad comprobable; requisitos/recompensa visibles; tutorial repetible; no se salta una etapa por save inválido; test de desbloqueos y migración.
- **Riesgos:** balance, salto de dificultad, progresión confundida con niveles de personaje. Separar nivel, Mark y tecnología.

### P3 — Onboarding, UI y accesibilidad

**Propuesta:** tutorial de 6–8 pasos con objetivo persistente: mover → recolectar → regresar → fabricar/mejorar → explorar → misión → guardar. Paneles separados (base, mapa, hangar, investigación, misión, inventario) y ajustes accesibles.

- **Dependencias:** flujo de escenas/UI, `PlatformInput`, save, sistema de acciones.
- **Aceptación:** tutorial se puede repetir/saltar; texto no depende solo del color; UI escala; acciones equivalentes teclado/mando/touch; remapeo sin perder confirmación; texto/subtítulos configurables; preferencias persisten.
- **Riesgos:** HUD más pesado, controles duplicados y tutorial que bloquea. Un paso por pantalla, skip y ayuda contextual.

### P4 — Rendimiento y QA medible

**Propuesta:** profiler de desarrollo (FPS, memoria, nodos, criaturas activas, tiempos de manager) y límites por distancia/sector. Medir antes de optimizar; priorizar equipos modestos.

- **Dependencias:** build reproducible, profiler Godot, escena de prueba con carga escalada.
- **Aceptación:** escena 10 min sin error; baseline de FPS/RAM en PC y Android real; entidades fuera de sector reducen actualización; no hay timers duplicados tras recargar; se registran datos de prueba.
- **Riesgos:** optimizar sin métricas, esconder bugs con throttling, declarar soporte móvil sin dispositivo.

## Orden recomendado de implementación

1. P0: guardado de estado faltante + round-trip y migración.
2. P0: una vertical slice jugable, de tutorial a misión, recompensa, recuperación y recarga.
3. P1: asignación de especialistas (un slot, un efecto, una UI simple).
4. P1: ledger de recursos y transferencias limitadas.
5. P1: director único de misiones/eventos, basado en estado.
6. P2: mapa de sectores y recon.
7. P2: clima/ecología; conectar dos especies primero.
8. P2: Mark I–V y tutoriales de capacidad.
9. P3: UI/UX, accesibilidad y controles.
10. P4: perfilado PC modesto y Android real; luego ampliar contenido.

## Cambio pequeño realizado esta semana

Se añadieron casos de QA al test de lógica para la población NPC:
- valida la población de ocho;
- confirma que la solicitud se asigna al NPC más cercano;
- una acción no relacionada no avanza el objetivo;
- progreso y propietario sobreviven a export/import;
- la reclamación entrega la recompensa configurada una sola vez y avanza el ciclo.

No se añadió una mecánica nueva ni se afirmó que la UI de especialistas esté implementada. La integración visual y el comportamiento de los NPC en Godot siguen pendientes.

## Fuentes adicionales

- [No Man's Sky — Frontiers Update](https://www.nomanssky.com/frontiers-update/) (oficial)
- [Factorio — Logistic network](https://wiki.factorio.com/Logistic_network)
- [RimWorld — Work](https://rimworldwiki.com/wiki/Work)
- [RimWorld — Menus/Schedule](https://rimworldwiki.com/wiki/Menus)
- [Subnautica — Scanner](https://subnautica.fandom.com/wiki/Scanner_(Subnautica))
- [Subnautica — Scanner Room](https://subnautica.fandom.com/wiki/Scanner_Room_(Subnautica))
- [Frostpunk — Events](https://frostpunk.fandom.com/wiki/Events)
- [Celeste — Official changelog](https://www.celestegame.com/changelog.html)

Las referencias describen patrones; los nombres, personajes, criaturas, mapas, UI, assets y código del proyecto deben permanecer originales.

# Informe semanal de investigación — 27 de noviembre de 2026

## Resumen ejecutivo

La revisión confirma que el proyecto tiene más sistemas de los que su interfaz permite comprender. La mejora de mayor valor ahora es **hacer visibles las causas y consecuencias de cada sistema y asegurar que su estado sobreviva al cierre del juego**, antes de ampliar el catálogo de contenido.

Esta semana se compararon patrones de simulación de colonias, gestión de producción, sucesos de recuperación, ecología emergente, selección de misiones, accesibilidad y perfilado de rendimiento. Las propuestas se apoyan en los managers que ya existen: no se recomienda crear una segunda economía, otra población NPC ni un segundo director de eventos.

**Base inspeccionada:** rama `main`, commit `54bdd06dfbbe38668badb7be7390d0e73bd59b5d`.  
**Cambios de código realizados durante esta revisión:** persistencia y presentación del clima en el flujo principal, además de pruebas y comprobaciones estáticas.  
**No se declara:** una exportación APK, una prueba visual en PC/Android ni la finalización del sistema ecológico o de reconocimiento.

## 1. Estado real encontrado en el repositorio

| Área | Código que ya existe | Brecha que sigue abierta |
|---|---|---|
| NPC | `NpcPopulationManager`: 8 personas, roles, rutas sencillas por turnos, solicitudes, ánimo, confianza y alerta | No hay asignación de especialistas a instalaciones ni bonus laborales persistentes |
| Economía | `TradeManager`, créditos ficticios, compra/venta, contratos y producción de base | Falta un historial único de entradas/salidas y una vista de producción por instalación |
| Base | `BaseDevelopmentManager`: 10 instalaciones, costes, requisitos, niveles y producción | La producción se muestra de forma resumida; falta explicar el origen y destino de cada cambio |
| Misiones/eventos | `GameLoopManager`: misión inicial, expedición, tres regiones y evento temporal de bonus de recurso | Un solo objetivo principal inicial; eventos poco contextuales; el director separado documentado anteriormente no está integrado |
| Exploración | Regiones, expediciones, POI y reconocimiento por helicópteros | Falta un mapa de sectores conectado con rutas, conocimiento parcial y estados persistentes |
| Ecología | `CreatureEcosystemManager`: ocho especies que recorren el entorno y pueden observarse | La observación y los estados ecológicos no tienen persistencia integral; las criaturas actualizan movimiento continuamente |
| Clima | `WeatherManager`: despejado, lluvia, niebla y tormenta; modificador de reconocimiento disponible | Antes de este cambio no se creaba desde `main.gd` ni se guardaba en el perfil |
| Mark I–V | `CampaignManager` calcula cinco generaciones según nivel de campaña | Los umbrales existen, pero cada Mark aún necesita una capacidad funcional propia y una explicación al jugador |
| Guardado | `SaveManager` usa JSON local, escritura temporal y respaldo; el perfil guarda varios managers | El snapshot principal todavía no representa todo el estado del mundo, como fauna observada y posición/objetos del jugador |
| UI y accesibilidad | HUD, controles y paneles de estado | Falta navegación consistente, ajustes de accesibilidad accesibles desde el inicio y una interfaz menos saturada |

### Comparación con la investigación anterior

Las propuestas de especialistas, ledger, mapa, misiones emergentes, clima/ecología y tutorial ya estaban registradas en los informes anteriores. Esta revisión **no las vuelve a presentar como descubrimientos nuevos**. Añade criterios más precisos: trazabilidad de producción, recuperación de puestos parcialmente desarrollados, eventos secundarios opcionales, actualizaciones ecológicas por intervalos y una política clara de migración de partidas.

## 2. Referencias de esta semana y patrones útiles

### A. Oxygen Not Included — integridad de recursos y automatización

**Fuente:** [November 2026 Quality of Life Update](https://store.steampowered.com/news/app/457140/view/714544468141801835)

La actualización de noviembre de 2026 corrigió casos en los que los objetos almacenados podían convertirse en unidades parciales al pasar por almacenamiento o automatización.

**Qué aporta:** incluso una economía de simulación necesita reglas exactas para cantidades, almacenamiento y transferencias. Un error pequeño de redondeo puede crear o perder recursos.

**Adaptación original:** reforzar las operaciones de `TradeManager`, contratos, producción y futuras transferencias con cantidades enteras, validación previa y operación todo-o-nada. Registrar una transacción una sola vez.

**Evitar duplicados:** no crear otra moneda ni otro inventario. Usar los recursos y créditos actuales.

### B. Against the Storm — estadísticas de producción y efectos globales

**Fuente oficial:** [Quality of Life Update 1.7](https://eremitegames.com/quality-of-life-update-1-7/)

La actualización añadió estadísticas de población, consumo y producción, además de separar los efectos globales de los bonus específicos de trabajadores o edificios. También incorporó pausa automática al perder el foco de la ventana.

**Qué aporta:** el jugador entiende mejor por qué cambia una cifra y qué instalación o modificador produce el resultado.

**Adaptación original:** ampliar el panel de base para mostrar, por instalación, recurso producido, ritmo, consumo y modificadores. Separar claramente bonus globales de bonus locales. Evaluar una opción de pausa automática al cambiar de aplicación en PC.

**Evitar duplicados:** ampliar `BaseDevelopmentManager` y el HUD actual; no crear otro gestor de producción.

### C. Against the Storm — evento de asentamiento abandonado

**Fuente:** [Abandoned Settlement world event](https://store.steampowered.com/news/app/1336490/view/4441205298304123167)

El evento permite comenzar una partida en un asentamiento parcialmente desarrollado, con decisiones y objetivos ya activos. Esto modifica el comienzo de la sesión sin exigir un mapa completamente nuevo.

**Qué aporta:** los sucesos pueden variar el estado inicial y crear una misión de recuperación con contexto, no solo entregar un bonus aleatorio.

**Adaptación original:** un “Puesto costero sin relevo”: iniciar una operación con algunas instalaciones dañadas, inventario limitado y una solicitud civil activa. El jugador decide entre reparar, recuperar suministros o priorizar el reconocimiento. El resultado cambia el estado del sector y los servicios disponibles.

**Evitar duplicados:** usar las plantillas del `GameLoopManager` o consolidar el director de eventos ya documentado; no instanciar dos directores paralelos.

### D. Rain World — ecología basada en relaciones entre estados

**Fuente técnica de diseño:** [Unity — Exploring procedural design in Rain World: The Watcher](https://legacy-activation.unity3d.com/fr/blog/exploring-procedural-design-rain-world)

El artículo explica cómo situaciones inesperadas pueden surgir de sistemas de comportamiento y relaciones entre criaturas y entorno, en vez de depender de eventos escritos uno por uno.

**Qué aporta:** una ecología creíble puede empezar con pocas reglas consistentes, no con cientos de criaturas ni secuencias guionizadas.

**Adaptación original:** para dos especies iniciales, probar estados simples como reposo, desplazamiento, alerta y retirada. Las condiciones de región y clima pueden influir en la transición. Las criaturas lejanas deben actualizarse a menor frecuencia.

**Evitar duplicados:** extender `CreatureEcosystemManager`; no crear un segundo catálogo de especies ni una simulación compleja de cadena alimentaria.

### E. Godot 4.3 — perfilado antes de optimizar

**Fuentes oficiales:** [Profiler](https://docs.godotengine.org/en/4.3/tutorials/scripting/debug/the_profiler.html), [CPU optimization](https://docs.godotengine.org/en/4.3/tutorials/performance/cpu_optimization.html) y [3D performance](https://docs.godotengine.org/en/4.3/tutorials/performance/optimizing_3d_performance.html).

La documentación recomienda identificar el cuello de botella mediante medidas de tiempo de cuadro, física, inactividad y renderizado antes de optimizar. También explica técnicas como culling y niveles de detalle.

**Qué aporta:** reducir procesos por intuición puede ocultar problemas; primero hace falta una escena de referencia y mediciones repetibles.

**Adaptación original:** medir la escena con 8, 16 y 32 criaturas, registrar tiempo de cuadro, uso de memoria y tiempo de carga, y después evaluar actualizaciones por intervalos y distancia.

**Nota de versión:** la documentación archivada de Godot 4.3 advierte que esa versión ya no está soportada. No se recomienda cambiar el motor automáticamente en esta tarea; primero hay que probar una migración separada con una copia del proyecto y comparar resultados.

### F. Microsoft Xbox Accessibility Guidelines — navegación consistente

**Fuente:** [XAG 112: UI navigation](https://learn.microsoft.com/en-in/gaming/accessibility/xbox-accessibility-guidelines/112)

La guía destaca orden de foco predecible, estructuras coherentes entre pantallas y acceso a ajustes de accesibilidad desde el inicio.

**Qué aporta:** la accesibilidad debe estar disponible antes de que el jugador tenga que resolver menús complejos.

**Adaptación original:** primera pantalla con tamaño de texto, contraste, subtítulos, reducir movimiento y esquema de controles; mantener el mismo orden de foco y nombres de acciones en todos los paneles.

**Evitar duplicados:** centralizar opciones sobre el sistema de entrada y HUD actual.

## 3. Propuestas priorizadas

### P0 — Persistencia integral y transacciones seguras

**Propuesta:** completar el snapshot del mundo por fases: clima, observaciones de fauna, posición y objetos recolectados, estado de misión/expedición y resultados pendientes. Reforzar operaciones de recompensa y gasto para que una transacción no pueda aplicarse dos veces.

- **Dependencias:** `SaveManager`, `main.gd`, `GameLoopManager`, `WeatherManager`, `CreatureEcosystemManager`, `TradeManager`.
- **Criterios de aceptación:** guardar/cerrar/abrir conserva el estado; datos inválidos vuelven a valores seguros; una recompensa no se duplica; perfil anterior sigue siendo legible; cada manager tiene una prueba round-trip.
- **Riesgos:** snapshot parcial, restauración de nodos duplicados y temporizadores que vuelven a pagar tras cargar.
- **Estado de esta semana:** clima añadido al perfil y cubierto por pruebas de lógica; el resto del snapshot sigue pendiente.

### P1 — Especialistas asignables en instalaciones existentes

**Propuesta:** permitir asignar a una persona a una instalación compatible. Cada persona ocupa como máximo un puesto y aporta un solo efecto acotado y visible.

- **Dependencias:** `NpcPopulationManager`, `BaseDevelopmentManager`, producción, investigación, HUD y guardado.
- **Criterios de aceptación:** asignar cambia un único efecto; no se permite duplicar a la misma persona; un puesto incompatible no altera estado; guardar/cargar conserva la asignación; el panel muestra el beneficio real.
- **Riesgos:** bonus acumulados por error y exceso de microgestión. Empezar con pocos puestos y sin simular fatiga individual.

### P1 — Ledger y estadísticas de producción

**Propuesta:** registrar origen, destino, cantidad y motivo de cada entrada/salida; mostrar producción y consumo por instalación.

- **Dependencias:** `TradeManager`, `BaseDevelopmentManager`, contratos, inventario y `SaveManager`.
- **Criterios de aceptación:** saldo coincide con transacciones; cantidades negativas o fraccionarias se rechazan; operación inválida no modifica ningún valor; una transacción repetida no vuelve a pagar; HUD explica los cambios.
- **Riesgos:** doble contabilización entre producción, mercado y recompensas. Un solo punto de aplicación por transacción.

### P1 — Puesto costero de recuperación y misiones por contexto

**Propuesta:** un evento de recuperación que parte de un estado parcial y se activa por condiciones verificables. El tablero presenta un objetivo principal y una tarea opcional.

- **Dependencias:** `GameLoopManager`, contratos, NPC, base, regiones y guardado.
- **Criterios de aceptación:** el evento explica por qué aparece; solo hay un evento urgente activo; existe una salida si faltan recursos; éxito/parcial/expiración producen resultados distintos; recompensa única y estado persistente.
- **Riesgos:** eventos que bloquean la campaña o aparecen en exceso. Usar cooldowns y límites.

### P2 — Mapa de campaña por sectores

**Propuesta:** grafo inicial de sectores con rutas, POI, recursos, nivel de información y estado regional. El reconocimiento revela pistas gradualmente.

- **Dependencias:** regiones, `GameLoopManager`, frente regional, POI y helicópteros.
- **Criterios de aceptación:** ruta bloqueada explica el requisito; desbloqueo es idempotente; el reconocimiento no revela todo; guardar/cargar mantiene rutas y conocimiento.
- **Riesgos:** mapa demasiado grande antes de tener operaciones jugables. Empezar con pocos sectores conectados.

### P2 — Clima y ecología con consecuencias pequeñas

**Propuesta:** validar el efecto climático ya conectado al reconocimiento y relacionarlo después con los estados de dos especies iniciales.

- **Dependencias:** `WeatherManager`, `CreatureEcosystemManager`, POI, reconocimiento y guardado.
- **Criterios de aceptación:** el jugador ve el efecto antes de salir; el mismo estado produce el mismo resultado durante una sesión de prueba; observación no duplica recompensa; entidades lejanas actualizan menos.
- **Riesgos:** penalizaciones poco claras y coste de CPU. El clima debe ser una condición legible, no un castigo aleatorio.

### P2 — Mark I–V con capacidades distintas

**Propuesta:** mantener los umbrales actuales y vincular cada etapa a una capacidad verificable de exploración, estabilidad, información o gestión energética.

- **Dependencias:** `CampaignManager`, árbol tecnológico, controles, tutorial y guardado.
- **Criterios de aceptación:** cada Mark desbloquea una acción comprobable; requisitos y beneficio se muestran antes; no se salta una etapa con un perfil inválido; pruebas de desbloqueo.
- **Riesgos:** confundir nivel de campaña con generación. Mantenerlos como conceptos separados.

### P3 — Onboarding y accesibilidad

**Propuesta:** tutorial breve, repetible y saltable; configuración de texto, contraste, subtítulos, reducción de movimiento y controles antes de la primera operación.

- **Dependencias:** HUD, `PlatformInput`, navegación UI y guardado de preferencias.
- **Criterios de aceptación:** foco predecible con teclado/mando; acciones equivalentes en touch; texto escalable; tutorial no bloquea; preferencias persisten.
- **Riesgos:** añadir más paneles a un HUD ya cargado. Separar pantallas por contexto.

### P4 — Rendimiento y perfilado

**Propuesta:** escena de benchmark con carga escalable y registro local de métricas.

- **Dependencias:** Godot Profiler, escena principal, sistema de criaturas y dispositivos de prueba.
- **Criterios de aceptación:** baseline repetible; pruebas de 10 minutos sin errores; medidas en PC modesto y Android real; cualquier optimización se compara con el baseline.
- **Riesgos:** declarar compatibilidad sin probar hardware. No afirmar rendimiento ni soporte de plataforma sin mediciones.

## 4. Cambios realizados en GitHub

Se hizo una implementación pequeña para cerrar una brecha real de clima/guardado, sin crear otro gestor:

1. `WeatherManager` ahora exporta e importa su estado, valida identificadores de clima y limita intensidad/tiempo a rangos seguros.
2. `main.gd` instancia el manager, muestra el estado del clima en el HUD y lo incluye en el perfil local.
3. Un cambio de clima guarda el nuevo estado del perfil. El clima también ajusta el radio del reconocimiento aéreo y el informe de finalización muestra el multiplicador aplicado.
4. Se añadieron pruebas para restauración, intensidad, tiempo, modificador de niebla, texto, fallback de clima inválido y límites.
5. `repo_sanity.py` comprueba que el manager está conectado al flujo principal y al guardado.

**Commits de implementación:**
- [WeatherManager: persistencia y estado legible](https://github.com/edwjacpinros2012-dev/Titanes-del-Pac-fico-/commit/5e03af7fb2283dae93c2950369a2c00d404ac596)
- [Conectar clima al HUD y al perfil](https://github.com/edwjacpinros2012-dev/Titanes-del-Pac-fico-/commit/12c5c316eb3b95d1a4738654cc3393c4ab8c9574)
- [Pruebas de persistencia y validación del clima](https://github.com/edwjacpinros2012-dev/Titanes-del-Pac-fico-/commit/6f068a8cbcb99308c8802d912c5dab9dda62542f)
- [Comprobaciones estáticas de integración](https://github.com/edwjacpinros2012-dev/Titanes-del-Pac-fico-/commit/77ebb21bd5aa19c0324e95991602aab6b20b2747)
- [Aplicar clima al radio de reconocimiento](https://github.com/edwjacpinros2012-dev/Titanes-del-Pac-fico-/commit/4597f47abc7787dea1cf4cce813b5bb25bc1509f)
- [Prueba del efecto climático sobre el radio](https://github.com/edwjacpinros2012-dev/Titanes-del-Pac-fico-/commit/1ed710f909a9782ba1b3bd10a7c9f38ce8b4a243)
- [Sanity check del efecto climático](https://github.com/edwjacpinros2012-dev/Titanes-del-Pac-fico-/commit/74a8f073f69d440c81ae604f4ab717326523f48f)
- [Enlace del informe semanal desde README](https://github.com/edwjacpinros2012-dev/Titanes-del-Pac-fico-/commit/e5e8b850c107f6bbcb37872d0e282b6ef6cccee3)

## 5. Validación y límites

- El test de lógica contiene **81 aserciones** y el script de sanity contiene **40 comprobaciones**; estos son recuentos de código, no resultados de ejecución.
- En la consulta del HEAD final, los tres contextos de Vercel estaban **pendientes**. Son comprobaciones de despliegue web y no demuestran que Godot haya ejecutado las pruebas.
- La consulta disponible de ejecuciones de GitHub Actions no devolvió una ejecución verificable para este commit. Por tanto, no se declara CI de Godot aprobada en esta revisión.
- El entorno de revisión no tiene Godot instalado y no pudo clonar el repositorio por falta de conexión de red. La validación local de Godot queda pendiente.
- No se hizo prueba manual en Windows ni en Android.
- No se exportó ni instaló ningún APK.
- El modificador climático se muestra en el HUD y ya afecta el radio del reconocimiento aéreo. Todavía no modifica los estados de la fauna.

## 6. Siguiente orden recomendado

1. Confirmar ejecución de GitHub Actions para los commits de clima.
2. Ejecutar CI de Godot para la integración climática y comprobar manualmente el radio de reconocimiento en cada condición.
3. Guardar observaciones de fauna y posición/objetos recolectados.
4. Añadir un único puesto de especialista a una instalación y probar el efecto.
5. Crear el primer evento de recuperación reutilizando el loop actual.
6. Medir rendimiento antes de aumentar criaturas o tamaño de mapa.

La regla de esta revisión sigue siendo la misma: un sistema solo se considera terminado cuando está integrado, probado y accesible desde el flujo principal.

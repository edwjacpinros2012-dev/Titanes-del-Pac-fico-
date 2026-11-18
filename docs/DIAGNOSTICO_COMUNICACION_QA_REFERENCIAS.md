# Diagnóstico de integración, comunicación y QA por sistemas

Fecha: 17 de noviembre de 2026. Revisión documental GitHub (main). Motor objetivo: Godot 4.3.

> Alcance y honestidad: se revisaron README, auditoría A–Z, roadmap, estado de contenido y arquitectura. Esta revisión no equivale a ejecutar Godot en un equipo local ni a inspeccionar cada script fuente. CI headless previo está documentado como aprobado, pero aquí no se inició una nueva ejecución. Los sistemas marcados como presentes necesitan pruebas de integración funcional en Godot.

## Resultado ejecutivo

El prototipo tiene muchos subsistemas declarados, pero la brecha crítica es comprobar que todos intercambian datos coherentes, que la escena/HUD los invoca, que el guardado restaura sus estados y que las recompensas no se duplican. P0: perfil/guardado, flujo de misión, recursos-economía, estado de campaña y arranque/escena. No expandir online ni chat hasta que el modo individual esté fiable.

## Semáforo por sistema (documentación/código declarados; integración por probar)

| Sistema | Estado conocido | Comunicación prevista | Riesgo/bloqueo | Prueba de aceptación |
|---|---|---|---|---|
| GameRoot/escena principal | prototipo | AppFlow -> escena -> managers -> HUD | entradas/estado duplicados | iniciar, pausar, cambiar panel y volver sin duplicar managers |
| Control y cámara | controlador presente | Input -> Centinela -> cámara/HUD | sensibilidad/colisión, touch | teclado y touch mueven; cámara no atraviesa suelo; pausa detiene movimiento |
| Recursos e inventario | inicial | WorldNode -> Inventory -> HUD/Save | recogida duplicada, límites | nodo se consume una vez; UI y save coinciden |
| Fabricación | inicial | receta -> Inventory/Energy -> producto | costes parciales si falla | sin ingredientes no craft; con ingredientes deduce y entrega una sola vez |
| Base/instalaciones | gestión lógica | Build -> requisitos -> Inventory/Energy -> producción | prerequisitos y UI desincronizados | upgrade cuesta exacto; nivel y producción reflejan estado; save/load conserva |
| Energía | sistema lógico | producción/consumo -> instalaciones | valores negativos o energía infinita | balance muestra excedente/deficit; operación bloqueada sin energía si aplica |
| Investigación/tecnologías | árbol inicial | Research -> costes -> effects -> otros managers | efecto no aplicado o repetido | desbloqueo único; efecto cuantificable; persiste y no vuelve a cobrar |
| Evolución Mark I–V | progresión inicial | Hangar -> Research/Resources -> Campaign | salto de etapa o requisito confuso | Mark siguiente exige prerequisitos y muestra estadísticas/beneficio |
| Contratos/mercado | local | Contract -> Economy/Inventory -> UI | doble pago, stock negativo | contrato se paga una vez; venta no excede stock; créditos ficticios |
| Expediciones/POI | sistema inicial | Expedition -> World/Discovery -> Reward | timers/recompensas no persistentes | enviar, resolver, reclamar y cargar sin duplicación |
| Helicópteros | reconocimiento inicial | Recon -> Mission/Timer -> Inventory/Intel | misión/temporizador se pierde | envío y retorno; una recompensa; restauración de estado |
| Ecosistema/descubrimiento | inicial | Ecology -> POI/Quest/Research | descubrimientos repetidos | registrar hallazgo una vez; desbloquea contenido correcto |
| NPC/solicitudes | demo integrada | NPC -> Dialogue/Request -> Inventory/Community | solicitudes simultáneas o sin pago | una activa; completar y reclamar una vez; NPC vuelve a estado correcto |
| Clima/ciclo día-noche | sistema lógico | WorldTime -> Weather/Visuals/Gameplay | UI/visual no siguen estado | cambiar tiempo/clima; efectos y save se coordinan |
| Brechas/frente regional | local | Breach/Warfront -> Campaign/Reward | sector perdido no restaura o presión incoherente | estado se conserva; resultado cambia presión/control |
| Encuentros/daño | simulación de estadísticas | Encounter -> Campaign/Damage/Reward | no es combate real; resultado opaco | mostrar cálculo y consecuencias; retiro/derrota no rompe perfil |
| Reparación | lógica | Damage -> RepairCost -> Inventory/Energy | reparación gratuita o parcial | coste correcto; subsistema mejora; sin saldo no reparas |
| Alianza local | demo | Alliance -> Community/Save | se confunde con online | solo local, sin chat ni cuentas reales |
| Backend/cloud | esquemas/clientes | Auth -> servidor/RLS -> SaveSync | no desplegado/seguridad | no usar en producción; validar servidor y permisos antes de activar |
| Chat | desactivado | Moderation/Report/Block | privacidad y moderación | permanecer apagado hasta controles reales y pruebas |
| Export Android/Web/PC | scripts/presets | build scripts -> SDK/templates -> package | export no verificada | artefacto real, instala/abre, controles y rendimiento en dispositivo |
| Audio/UI/accesibilidad | parcial | settings -> UI/input/audio | faltan test de escalado/lectura | controles reasignables, tamaño, contraste, audio, subtítulos |

## Contrato de comunicación recomendado

1. Managers no deben editar directamente UI; emiten señales de cambio y HUD consulta estado.
2. Inventario/Economía es autoridad de recursos y créditos; ninguna misión entrega recursos directamente sin pasar por un método de recompensa idempotente.
3. Profile/SaveService guarda snapshots versionados. Los managers registran métodos to_save_data() y load_save_data(); una carga no debe emitir recompensas ni reactivar misiones completadas.
4. Mission/Contract/Expedition/Helicopter usan identificadores únicos de instancia y estado: available -> active -> ready_to_claim -> claimed; la reclamación se hace una sola vez.
5. Research/Base/Evolution validan prerequisitos y costes antes de cambiar el estado; deducción y aplicación deben ser atómicas.
6. World/Encounter solo publica resultados; Campaign/Damage/Reward recibe un evento una vez. Separar simulación de presentación.
7. Offline-first: las funciones locales no esperan servicios cloud. Errores de backend nunca deben bloquear cargar/guardar local.
8. UI debe mostrar coste, requisito, resultado, error y confirmación; botones deshabilitados no deben cambiar estado.

## Matriz de pruebas P0 (hacer en Godot)

### Perfil y guardado
- [ ] Perfil nuevo crea valores por defecto válidos.
- [ ] Guardar, cerrar, abrir y restaurar inventario, créditos, nivel, investigación, instalaciones, daño, NPC, campaña y estado de misión.
- [ ] Corrupt file: fallback/backup y mensaje claro; no crash.
- [ ] Version migration: perfil anterior no pierde campos.
- [ ] Suspend/resume y autosave; guardar en pausa.
- [ ] Posición/nodos recolectados/tiempo/clima/contratos/expediciones/helicópteros/descubrimientos: decidir explícitamente persistencia y verificar.

### Recursos y economía
- [ ] Recolección no duplica; capacidad/limites se respetan.
- [ ] Fabricación valida receta y deduce exacto.
- [ ] Mercado: compra/venta no produce stock o créditos negativos.
- [ ] Contratos, expediciones, solicitudes y reconocimientos no pagan dos veces.
- [ ] Producción pasiva respeta energía, tiempo y límites de almacenamiento.

### Integración y UX
- [ ] Cada panel refleja la misma fuente de estado; no hay valores contradictorios.
- [ ] Cambiar panel no crea duplicados de señales o timers.
- [ ] Teclado, mando y touch ejecutan el mismo comando lógico.
- [ ] HUD móvil: landscape, safe areas, botones legibles, escala.
- [ ] Cualquier acción inválida da feedback y no altera el estado.

### Mundo/campaña
- [ ] Clima, ciclo, brechas, presión y control regional sobreviven a cargar.
- [ ] Encuentro: victoria/éxito parcial/retirada/derrota producen consecuencias correctas y transparentes.
- [ ] Reparar componente valida recursos y no puede elevar integridad por encima del máximo.
- [ ] Los NPC no bloquean movimiento ni quedan fuera de la escena; solicitudes tienen estados válidos.

### CI y plataformas
- [ ] Godot 4.3 headless importa proyecto y ejecuta escena sin errores.
- [ ] Revisión de warnings y errores en log.
- [ ] Windows export/launch en PC.
- [ ] Android APK instalado y probado con touch; no basta el preset.
- [ ] Web export ejecuta en navegador compatible; documentar limitaciones.
- [ ] Performance profile: FPS, RAM, tiempo de carga y cantidad de entidades en PC modesto y móvil objetivo.

## Referencias adicionales y patrones a adaptar (sin copiar contenido protegido)

- **Factorio** — producción, transporte, almacenamiento, energía y escalones de automatización. Adaptación original: rutas de suministros y robots logísticos de apoyo a instalaciones, desbloqueados gradualmente; interfaz sencilla con prioridades y límites. Fuente: https://www.factorio.com/game/content y https://wiki.factorio.com/Logistic_network
- **Subnautica** — descubrimiento y progresión por preparación/equipamiento, biomas con recursos y riesgos distintos. Adaptación: mapa oceánico de sectores, notas de campo, escáner y mejoras que abren zonas; mantener el bucle de exploración-recompensa. Fuente: https://store.steampowered.com/app/264710/Subnautica/
- **XCOM 2: War of the Chosen** — presión de campaña, misiones con oportunidad/coste y agentes persistentes; ya está referenciado en docs previos. Adaptación: alerta regional y calendario de operaciones, sin castigos que bloqueen el progreso.
- **Frostpunk** — gestión de prioridades y dilemas de recursos; adaptación: eventos de base con opciones claras, impactos temporales y alternativas sin decisiones irreversibles.
- **RimWorld** — simulación de colonos y eventos emergentes; adaptación: NPC con rol, tarea, estado de ánimo y eventos que combinan recursos/tiempo; empezar con pocos estados deterministas.
- **No Man's Sky** — asentamientos, especialistas, expediciones; ya existe referencia en NPC docs. Adaptación: asignar especialista a edificio, tarea y bonus explicable.
- **Monster Hunter** — preparación, pistas y objetivos opcionales; ya investigado. Adaptación: rastros/escaneo, objetivos de investigación y recompensas de preparación.
- **Valheim** — progresión por bioma y preparación; adaptación: zonas con requisitos de exploración y mejora, rutas seguras como logro opcional.
- **Deep Rock Galactic** — roles cooperativos y objetivos secundarios; adaptación posterior online: tareas asíncronas de alianza, contribución limitada y recompensas compartidas, sin chat hasta moderación.
- **Civilization** — mapa de campaña, regiones con ventajas y expansión estratégica; adaptación: mapa de sectores con control, suministro, descubrimientos y coste de operación.

## Nuevas propuestas priorizadas

### P0 — Integración/robustez (antes de añadir más contenido)
- Auditoría de save/load por manager, migration y backup.
- RewardLedger con IDs únicos para reclamaciones de contratos, expediciones, NPC y misión.
- EventBus/señales tipadas para eventos de gameplay y evitar dependencias circulares.
- Panel diagnóstico en modo debug: versión perfil, manager activo, estado misión, recursos, energía, presión regional, timers y errores recientes.

### P1 — Loop vertical jugable
- Tutorial contextual de 5 pasos: mover, recolectar, escanear, volver, mejorar.
- Una operación jugable que conecte exploración -> objetivo -> encuentro ficticio abstracto -> informe -> reparación/recompensa -> upgrade.
- Mapa sectorial con 3 sectores, recursos y amenazas, conectados a CampaignManager.
- NPC especialista asignable a una instalación con bonus visible y coste/tiempo de reasignación.

### P2 — Profundidad/vida
- Eventos dinámicos basados en reglas (no aleatoriedad arbitraria): falta de energía, sector con recursos, NPC solicita apoyo, descubrimiento.
- Logística con prioridades, almacén y límite; automatización sencilla.
- Ecología con población/actividad de amenaza y consecuencias por exploración, no simulación costosa.
- Rival/amenaza persistente con historial de encuentros y patrones desbloqueables.

### P3 — Pulido multiplataforma
- Settings completos: cámara, controles, UI scale, contraste, subtítulos, audio y reducción de movimiento.
- LOD/visibilidad, pool de entidades, límites de partículas y pruebas de memoria.
- Tutorial y guía de retorno; feedback de coste/recompensa.

### P4 — Online (solo tras validar solo)
- Operaciones asíncronas de alianza, permisos servidor, anti-duplicación, bloqueos/denuncias/moderación.
- Chat apagado hasta pruebas de privacidad y moderación.

## Definition of Done
Un sistema solo se marca como funcional cuando: (1) está conectado al flujo de escena, (2) el estado se conserva o se documenta como temporal, (3) coste/recompensa visible, (4) errores no rompen el perfil, (5) pruebas automatizadas o manuales registradas, (6) una persona puede seguir un tutorial sin comandos ocultos, (7) se verificó al menos una plataforma objetivo. Los documentos no equivalen a implementación ni exportación.

## Fuentes consultadas
- Factorio: https://www.factorio.com/game/content
- Factorio Logistic Network Wiki: https://wiki.factorio.com/Logistic_network
- Subnautica Steam: https://store.steampowered.com/app/264710/Subnautica/
- Referencias existentes: docs/SYSTEMS_REFERENCE_RESEARCH_EXPANSION.md, docs/NPC_POPULATION_AND_GAME_REFERENCES.md, docs/SYSTEMS_RESEARCH_AND_ARCHITECTURE.md

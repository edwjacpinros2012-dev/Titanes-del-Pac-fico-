# Investigación ampliada de sistemas y referencias — Titanes del Pacífico

**Actualizado:** 17 de noviembre de 2026  
**Objetivo:** descubrir sistemas que complementen el prototipo y convertirlos en propuestas propias. Esta investigación no autoriza copiar personajes, lore, mapas, interfaces, música, modelos ni assets de otros juegos.

## Resumen: qué falta más allá del combate

El proyecto ya tiene gestores locales para recolección, fabricación, instalaciones, investigación, economía, contratos, expediciones, NPC, regiones y encuentros simulados. Lo que más falta es que estos sistemas se comuniquen y produzcan historias y decisiones visibles: el mundo debe reaccionar, la base debe cambiar, las misiones deben surgir de necesidades y el progreso debe abrir opciones nuevas.

## Referencias y lecciones de diseño (adaptar, no copiar)

| Referencia | Sistema/idea general | Lección adaptable |
|---|---|---|
| Monster Hunter: World / Wilds | Rastros, preparación, objetivos opcionales, materiales que alimentan equipo y expediciones | Cada misión debe tener señales previas, opciones de preparación y recompensas conectadas a otros sistemas |
| Minecraft | Recolección, fabricación, descubrimiento y objetivos que surgen de las reglas | Crear objetivos procedurales simples desde necesidades reales del jugador, sin reemplazar la campaña |
| Wild Hearts | Construcción rápida contextual que ayuda a explorar y resolver situaciones | Herramientas de campo no bélicas: puentes, balizas, refugios, extracción y apoyo logístico |
| No Man's Sky | Base, especialistas, expediciones, asentamientos y progresión de descubrimientos | NPC con roles que producen beneficios medibles; expediciones que entregan reportes y recursos |
| Frostpunk (referencia de gestión) | Escasez, prioridades, población, decisiones y consecuencias | La base puede tener dilemas de asignación, moral y mantenimiento; evitar castigos arbitrarios |
| Valheim (referencia de supervivencia/exploración) | Biomas, descubrimiento, construcción y progresión por materiales | Cada región debe ofrecer una identidad, recursos, desafíos y razones de volver |
| Palworld (referencia de base y tareas) | Producción y automatización de tareas de asentamiento | Especialistas asignados a instalaciones con límites, descansos y efectos claros; usar una solución original |
| Open-world systemic design (Zelda como referencia general) | Interacciones consistentes entre estados ambientales y objetos | Reglas pequeñas, visibles y coherentes que permitan múltiples soluciones a problemas de exploración |

## Sistemas nuevos propuestos (ordenados por impacto)

### 1. Simulación de mundo y director de eventos
- Variables por región: control, amenaza, actividad civil, clima, recursos, alerta y rutas abiertas.
- Director de eventos basado en reglas y cooldowns; evita eventos simultáneos abrumadores.
- Eventos: evacuación, apagón, tormenta, rescate, anomalía, convoy civil, descubrimiento, alerta regional, reparación de infraestructura.
- Resolver eventos altera estado regional, reputación, recursos y próximos contratos.
- No generar evento sin explicación, objetivo, duración, resultado y registro.

**MVP:** 6 tipos de eventos; reglas de prioridad; una UI de aviso; estado guardable; 3 resultados por evento (éxito, parcial, expirado).

### 2. Misiones emergentes por necesidades
- Generador usa condiciones verificables: falta de materiales, instalación dañada, región amenazada, NPC solicita ayuda, descubrimiento sin analizar.
- Cada misión se crea desde plantilla + variables; nunca de forma completamente aleatoria sin contexto.
- Categorías: exploración, recuperación, investigación, escolta civil abstracta, reparación, rescate, defensa de infraestructura, reconocimiento, diplomacia y logística.
- Evitar repetir la misma plantilla consecutivamente; recompensas no deben romper economía.
- Mantener objetivos accesibles y comprensibles; no usar timers innecesariamente punitivos.

**MVP:** 12 plantillas, 3 objetivos máximo por misión, dificultad basada en Mark, región y preparación, con fallback si el jugador no puede completar.

### 3. Ecología y comportamiento de amenazas (fantasía)
- Cada especie original define bioma, temperamento, rango, señales, ciclo, objetivo y reacción al entorno.
- Estados generales: dormida/oculta, desplazamiento, alerta, interacción con entorno, enfrentamiento de fantasía, retirada, recuperación.
- Rastros y señales anticipan encuentros; las variantes alteran comportamiento y recompensa, no solo estadísticas.
- Encuentros conectados a clima, hora, región y presión del mundo.
- Los monstruos siguen siendo amenazas enemigas; no mascotas ni captura.

**MVP:** 3 familias, 2 variantes cada una; señales de presencia y estados visibles; comportamiento de navegación y combate abstracto en el marco de ficción.

### 4. Especialistas, turnos y productividad
- NPC asignables a instalaciones: ingeniería, investigación, logística, exploración, comunidad y mantenimiento.
- Cada instalación tiene slots, requisito de especialista y bonificación con tope.
- Fatiga/descanso representado de forma simple y amable; no obligar al jugador a microgestionar horarios.
- Eventos de NPC: petición, descubrimiento, conflicto leve, capacitación o cambio de puesto.
- Los especialistas tienen preferencias y una ficha clara de beneficios; la relación individual se guarda.

**MVP:** 6 roles, 1 slot por instalación inicial, 3 atributos de especialista y UI de asignación.

### 5. Logística y cadena de recursos
- Producción, consumo, capacidad de almacenamiento, mantenimiento y transporte se calculan en intervalos.
- Almacén central y depósitos regionales; expediciones/heli logístico pueden transferir cargas con límites.
- Recurso escaso provoca alternativas, no bloqueo permanente: contratos, fabricación alternativa, intercambio, expedición.
- Mostrar por qué cambia una cifra: fuente, gasto, saldo y tendencia.
- Evitar duplicación por guardado/carga y economía explotable.

**MVP:** balance de 5 recursos, almacén con capacidad, producción y consumo visibles, transferencias manuales seguras.

### 6. Reputación, diplomacia y alianzas NPC
- Reputación individual por facción, separada de confianza comunitaria.
- Acciones: ayudar, comerciar, explorar, reparar, compartir descubrimientos y resolver eventos.
- Rangos desbloquean servicios, misiones y apoyo; decisiones tienen consecuencias explicadas.
- Alianzas NPC no equivalen a multiplayer real.
- Mantener chat online desactivado hasta tener controles de seguridad, privacidad y moderación implementados y probados.

**MVP:** 3 facciones ficticias, 5 rangos, 4 acciones que modifican reputación y servicios desbloqueables.

### 7. Mapa táctico de campaña y control regional
- Mapa de nodos conectados; sectores con estado de control, infraestructura, recursos, amenaza y acceso.
- Rutas afectadas por eventos y condiciones ambientales.
- Reconocimiento revela información y reduce incertidumbre; no entrega omnisciencia.
- Recuperar sector desbloquea instalaciones, proveedores o expediciones; perderlo reduce beneficios pero ofrece ruta de recuperación.
- El estado regional persiste y se resume en la pantalla de campaña.

**MVP:** 8 sectores conectados para la región inicial, 3 estados de control, un POI por sector y rutas bloqueables por eventos.

### 8. Expediciones asíncronas y recuperación
- Seleccionar equipo/rol, objetivo, duración de juego, riesgo general y presupuesto de recursos.
- Expedición produce informe, hallazgo, recompensa, incidente o necesidad de recuperación.
- No simular progreso online mientras la app está cerrada sin backend confiable.
- La expedición local debe avanzar de manera determinista con el tiempo de juego guardado y validar cambios.

**MVP:** 3 tipos de expedición, reportes con 2-3 outcomes, costo/recompensa explicados.

### 9. Calidad de vida y onboarding
- Tutorial en pasos: mover, recoger, volver, fabricar, investigar, reparar, aceptar contrato y guardar.
- Diario de objetivos y checklist de campaña.
- Mapa, inventario, hangar, tecnología, base, contratos y comunidad en navegación unificada.
- Opciones: sensibilidad, volumen, texto, contraste, remapeo, vibración y controles.
- Tutorial se puede repetir; mensajes no deben tapar la acción.

### 10. Accesibilidad y controles por dispositivo
- Input actions centralizadas, remapeables.
- HUD que respeta safe areas, escalado y orientación.
- Controles teclado, mando y touch con paridad de acciones.
- Subtítulos, iconos con texto, tamaños, contraste y reducir efectos.
- Objetivo: pruebas en PC de gama baja y Android modesto; registrar FPS, memoria, tiempos de carga y errores.

### 11. Sistema de incidentes, diagnóstico y QA
- Registro de eventos del juego para bug report local (sin datos personales).
- Modo debug solo en builds de desarrollo: reset, inspección de recursos, estado de misión y NPC.
- Pruebas automáticas de economía, inventario, misiones, estados regionales y save migration.
- QA manual por recorrido de misión y dispositivo.
- Todo sistema se considera implementado únicamente tras integración y pruebas.

## Arquitectura sugerida para Godot

Usar gestores desacoplados y señales para que el director de eventos no dependa directamente de escenas concretas:

- `WorldState`: región, clima, hora, sectores, amenaza y estado de eventos.
- `EventDirector`: selecciona y programa eventos por reglas.
- `QuestGenerator`: plantilla + condición + objetivo + recompensa + fallback.
- `EcologyManager`: especies, señales, estados y encuentros.
- `SpecialistManager`: asignación, habilidades, descanso y bonificaciones.
- `LogisticsManager`: producción, consumo, capacidad y transferencias.
- `FactionManager`: reputación, rango y servicios.
- `CampaignMapManager`: nodos, rutas, control y desbloqueos.
- `ExpeditionManager`: estado y resultados de expediciones.
- `AccessibilitySettings`: preferencias de controles/UI/audio.
- `TelemetryLocal`: registros de QA sin información personal.

Regla de dependencia: los managers calculan estado y emiten señales; las escenas presentan ese estado. No colocar reglas de economía, misión o guardado dentro de botones/UI.

## Datos iniciales que conviene definir

- `data/events/*.json`: tipos, condiciones, duración, outcomes y recompensas.
- `data/quests/templates.json`: objetivos, restricciones, recompensas y fallback.
- `data/ecology/species.json`: bioma, señales, estados, variantes y drops ficticios.
- `data/npcs/specialists.json`: rol, habilidades, instalación compatible y bonus.
- `data/factions/*.json`: reputación, rangos, servicios y cambios.
- `data/world/sectors.json`: conectividad, control, POI, recursos y amenazas.
- `data/expeditions/*.json`: tipo, costo, duración de juego y resultados.
- `data/accessibility/defaults.json`: opciones base de UI y controles.

## Prioridad de implementación

1. **P0:** save/restore integral, pruebas automáticas y primera misión vertical jugable.
2. **P1:** mapa de campaña para región inicial + estados de sector.
3. **P1:** director de eventos y misiones emergentes (MVP pequeño).
4. **P1:** especialistas y logística conectados a instalaciones existentes.
5. **P2:** ecología por bioma y señales de rastreo.
6. **P2:** reputación de 3 facciones y servicios desbloqueables.
7. **P2:** expediciones asíncronas y reportes.
8. **P3:** onboarding, accesibilidad, rendimiento y polish.
9. **P4:** online real solo después de modo solo validado, con servidor autoritativo y controles de privacidad.

## Criterios de aceptación

- Cada nuevo sistema se puede abrir desde el flujo principal.
- Tiene tutorial o ayuda contextual.
- Los datos no se pierden al cerrar y volver a cargar.
- Los costos, beneficios, requisitos y resultados se muestran al jugador.
- Pruebas automáticas cubren reglas y casos extremos.
- Una prueba manual documenta la ruta y el resultado.
- No hay duplicación de recursos, misiones ni recompensas tras reanudar.
- El sistema tiene un fallback para bloqueos o recursos insuficientes.
- No se declara “terminado” por la mera existencia de un archivo.

## Fuentes de investigación consultadas

- Monster Hunter: World — rastreo, investigación y objetivos opcionales: https://www.gamedeveloper.com/design/how-i-monster-hunter-world-i-s-director-breathed-new-life-into-the-game-s-old-bones
- Monster Hunter Wilds — variación de preparación, rutas, materiales y condiciones: https://github.com/chernysh-denis/puzzle-genome-atlas-corpus/blob/main/knowledge/games/m-r/monster-hunter-wilds.md
- Minecraft y generación de objetivos a partir de reglas: https://par.nsf.gov/servlets/purl/10253897
- Wild Hearts — construcción contextual con utilidad en campo: https://www.inverse.com/gaming/wild-hearts-interview
- Análisis de crafting systems (64 sistemas en 47 juegos): https://dhq-static.digitalhumanities.org/pdf/000339.pdf
- Referencias generales de crafting, progresión y diseño: https://gamedev.net/tutorials/game-design/game-design-and-theory/developing-your-game-concept-by-making-a-design-document-r3004
- Open-world systemic design: https://www.zachsimms.com/game-dev/design/open-world/

## Próxima tarea técnica

No convertir todas las ideas en módulos aislados. Primero elegir un recorrido pequeño que pruebe las dependencias: un evento regional crea una misión; la misión usa un especialista o recurso; al completarla cambia reputación y control de sector; se entrega recompensa; el guardado persiste todo; al reabrir el juego el estado se conserva. Este recorrido es la prueba de integración de la nueva capa sistémica.

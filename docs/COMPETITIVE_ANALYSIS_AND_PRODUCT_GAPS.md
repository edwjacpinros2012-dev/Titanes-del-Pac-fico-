# Análisis comparativo y brechas de producto

**Fecha:** 17 de noviembre de 2026. **Motor objetivo:** Godot 4.3.

## Conclusión ejecutiva

Titanes tiene una combinación atractiva: pilotar un coloso mecánico, sobrevivir a expediciones, desarrollar una base, gestionar especialistas y recuperar regiones. La oportunidad no está en intentar ser más grande que cada referencia, sino en unir esos bucles en una experiencia coherente.

La brecha principal no es la cantidad de sistemas escritos. Es la integración: que una expedición cambie el estado de la base, que los daños afecten al siguiente despliegue, que los especialistas aporten beneficios visibles, que las regiones reaccionen a los resultados y que el guardado restaure el estado completo.

## Comparación de referencias

| Referencia | Fortaleza observable | Lección aplicable | Diferenciación propia |
|---|---|---|---|
| Pacific Drive | Expediciones con riesgos, recolección y regreso a una base que se mejora entre salidas | Cada salida necesita preparación, descubrimiento, presión, extracción y consecuencias persistentes | El centro de Titanes son el Centinela, los pilotos y la defensa regional; no un vehículo de supervivencia |
| MechWarrior 5: Clans | Campaña centrada en pilotos, equipo, especialistas, misiones y decisiones de preparación | El hangar y el equipo de apoyo deben importar tanto como la misión; los aliados necesitan roles legibles | Titanes debe ofrecer regiones persistentes, exploración y desarrollo de una base, no solo una secuencia lineal |
| War Robots | Modos PvE, roles diferenciados, progresión de unidades y objetivos cooperativos de comunidad | Diseñar variedad de objetivos y roles evita que cada encuentro se sienta igual | Priorizar una campaña PvE individual sólida; las funciones sociales se posponen hasta poder moderarlas y proteger la privacidad |
| Godot Demo Projects | Ejemplos pequeños y reproducibles de navegación, físicas, interfaz y optimización | Validar cada subsistema en una escena de prueba aislada antes de integrarlo | Usar patrones técnicos propios y verificar compatibilidad con Godot 4.3; no asumir que una demo de otra versión funciona sin cambios |

## Matriz honesta del estado propio

| Área | Estado que puede sostener el repositorio | Brecha de producción |
|---|---|---|
| Progresión Mark I–V | Hay datos y lógica inicial de campaña/evolución | Faltan pruebas de balance y una pantalla de hangar que conecte piezas, pilotos, daños y costes |
| Base y economía | Hay gestores de base, energía, comercio y contratos | Falta una economía de extremo a extremo que se guarde y afecte a las misiones |
| Exploración | Hay gestores de mundo, puntos de interés, recursos y ciclo ambiental | Falta una región recorrible con objetivos, navegación y feedback visual consistentes |
| Criaturas | Hay catálogo, ecosistema y un cerebro de movimiento básico | Falta IA de encuentro con estados, percepción, navegación validada y reacción a resultados |
| Centinela | Hay controlador de movimiento, habilidades y modelo de daños | Falta conectar cada subsistema dañado con controles, animación, interfaz y reparación |
| Misiones | Hay datos y seguimiento básico de objetivos | Faltaba un ciclo formal con fases, resultados, recompensas y regreso; se añade un gestor modular en este cambio |
| NPC | Hay un gestor de población | Faltan personajes individuales con nombre, rol, horario, relación, asignación y efectos medibles |
| Regiones | Hay catálogo y gestor de desbloqueo | Falta conectar presión regional, eventos, misiones y cambios visibles del mapa |
| Guardado | Hay guardado con respaldo y recuperación | Falta un perfil completo versionado y pruebas de restauración de cada sistema |
| Multiplataforma | Hay presets y scripts de preparación | No hay exportaciones Android/PC/Web verificadas en dispositivos reales |

## Principios de diseño adoptados

1. Expedición con consecuencias: preparar, desplegar, explorar, cumplir objetivos, resolver el encuentro, extraer, reparar y mejorar.
2. Progresión multidimensional: el desafío depende de preparación del piloto, sincronización, condición del Centinela, apoyo, inteligencia, presión regional y riesgo; no solo del nivel.
3. Victoria no garantizada: victoria, éxito parcial, retirada y derrota producen resultados distintos. Una derrota no borra injustamente todo el progreso, pero sí genera costes y presión.
4. NPC útiles: cada especialista debe tener función concreta, asignación visible y efecto comprobable.
5. Contenido dirigido por datos: regiones, criaturas, misiones, recompensas y balance se configuran en datos y no se duplican en grandes scripts.
6. Primero un modo individual completo: no iniciar chat global ni multijugador antes de tener controles de privacidad, moderación, bloqueo, denuncias y pruebas de servidor.
7. Rendimiento desde el prototipo: limitar entidades activas, usar niveles de detalle, colisiones simples, actualizaciones escalonadas y perfiles gráficos para móviles.

## Plan de cierre de brechas

### P0 — Primer ciclo jugable
- Conectar el gestor de operaciones con mapa, Centinela, director de amenaza y resultados.
- Crear un encuentro repetible en Costa de la Aurora.
- Asegurar que el resultado actualice recursos, daños y presión regional.
- Restaurar esos valores después de cerrar y volver a abrir el juego.

### P1 — Hangar y base
- Mostrar condición por subsistema, módulos, generación Mark y pilotos asignados.
- Convertir instalaciones en productores/servicios con tiempo, coste y requisitos.
- Mostrar especialistas, tareas, disponibilidad y efectos.

### P2 — Mundo y campaña
- Conectar catálogo regional con mapa, eventos y cadenas de misiones.
- Añadir objetivos de reconocimiento, rescate, recuperación, defensa, escolta y contención.
- Crear criaturas con perfiles de comportamiento originales y señales legibles.

### P3 — Calidad de producto
- Tutorial progresivo, accesibilidad, controles remapeables y opciones de rendimiento.
- Pruebas automáticas y manuales por plataforma.
- Arte, animación, audio y localización finales.
- Solo después, revisar backend, alianzas y funciones online.

## Fuentes consultadas

- Pacific Drive: https://store.steampowered.com/app/1458140/Pacific_Drive/
- MechWarrior 5: Clans: https://store.steampowered.com/app/2000890/MechWarrior_5_Clans/
- Análisis de MechWarrior 5: Clans: https://www.pcgamer.com/games/action/mechwarrior-5-clans-review/
- War Robots, guía oficial: https://warrobots.com/news/403
- Godot Demo Projects: https://github.com/godotengine/godot-demo-projects
- Godot NavigationAgents: https://docs.godotengine.org/en/latest/tutorials/navigation/navigation_using_navigationagents.html
- GDQuest, ejemplo de controlador 3D y licencias: https://github.com/gdquest-demos/godot-4-3d-third-person-controller

## Licencias y originalidad

Las referencias sirven para estudiar estructuras y decisiones de diseño. No reutilizar modelos, texturas, música, nombres de personajes, diálogos, mapas, interfaces distintivas ni código sin revisar su licencia. El controlador de GDQuest separa la licencia del código de la de los recursos artísticos; cualquier reutilización futura debe respetar ambas. Para Titanes se prioriza código y recursos originales.

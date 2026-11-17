# Análisis comparativo y brechas de producto

**Fecha:** 17 de noviembre de 2026. **Motor objetivo:** Godot 4.3.

## Conclusión ejecutiva

La propuesta de Titanes combina exploración, recolección, evolución de una base, especialistas y una guerra ficticia de colosos. La oportunidad está en conectar esos sistemas en un ciclo coherente, no en acumular menús o funciones aisladas.

La brecha principal es la integración: una expedición debe cambiar el estado de la base, los daños deben afectar el siguiente despliegue, los especialistas deben aportar beneficios visibles, las regiones deben reaccionar a los resultados y el guardado debe restaurar el estado completo.

## Comparación con referencias de diseño

| Referencia | Fortaleza observable | Lección aplicable | Diferenciación de Titanes |
|---|---|---|---|
| The Planet Crafter | Exploración, recolección, construcción de base, producción automatizada y transformación gradual del entorno | Hacer que los recursos obtenidos permitan construir algo visible y que el mundo cambie de forma persistente | En Titanes, la evolución del mundo se conecta con regiones, instalaciones, pilotos y la defensa de los asentamientos |
| Animal Crossing: New Horizons | Habitantes con identidad, actividades cotidianas, colección, tiendas, donaciones y cambios por horario/temporada | Los NPC necesitan personalidad, rutina, relaciones y motivos para hablar con el jugador; la base debe sentirse habitada | Nuestros especialistas deben además tener profesiones, asignaciones y efectos medibles sobre investigación, reparación, exploración y producción |
| Godot Demo Projects | Ejemplos reproducibles y pequeños de navegación, físicas, interfaz y optimización | Validar subsistemas en escenas de prueba aisladas antes de integrarlos en el juego principal | Crear implementaciones propias y comprobar que cada ejemplo sea compatible con Godot 4.3 |

## Matriz honesta del estado propio

| Área | Estado que puede sostener el repositorio | Brecha de producción |
|---|---|---|
| Progresión Mark I–V | Hay datos y lógica inicial de campaña/evolución | Faltan pruebas de balance y una pantalla de hangar que conecte piezas, pilotos, daños y costes |
| Base y economía | Hay gestores de base, energía, comercio y contratos | Falta una economía de extremo a extremo que se guarde y afecte a las misiones |
| Exploración | Hay gestores de mundo, puntos de interés, recursos y ciclo ambiental | Falta una región recorrible con objetivos, navegación y feedback visual consistentes |
| Criaturas | Hay catálogo, ecosistema y un cerebro de movimiento básico | Falta IA de encuentro con estados, percepción, navegación validada y reacción a resultados |
| Centinela | Hay controlador de movimiento, habilidades y modelo de daños | Falta conectar cada subsistema dañado con controles, animación, interfaz y reparación |
| Misiones | Hay datos y seguimiento básico; ahora se añade un gestor de fases, objetivos, resultados y regreso | Falta integración completa con interfaz, mapa, economía, daños y guardado |
| NPC | Hay un gestor de población | Faltan personajes individuales con nombre, rol, horario, relación, asignación y efectos medibles |
| Regiones | Hay catálogo y gestor de desbloqueo | Falta conectar presión regional, eventos, misiones y cambios visibles del mapa |
| Guardado | Hay guardado con respaldo y recuperación | Falta un perfil completo versionado y pruebas de restauración de cada sistema |
| Multiplataforma | Hay presets y scripts de preparación | No hay exportaciones Android/PC/Web verificadas en dispositivos reales |

## Principios de diseño adoptados

1. Expedición con consecuencias: preparar, desplegar, explorar, cumplir objetivos, resolver el encuentro, extraer, reparar y mejorar.
2. Progresión multidimensional: el desafío depende de preparación del piloto, sincronización, condición del Centinela, apoyo, inteligencia, presión regional y riesgo; no solo del nivel.
3. Victoria no garantizada: victoria, éxito parcial, retirada y derrota producen resultados distintos. Una derrota no borra injustamente todo el progreso, pero sí genera costes y presión.
4. NPC útiles: cada especialista debe tener una función concreta, una asignación visible y un efecto comprobable.
5. Contenido dirigido por datos: regiones, criaturas, misiones, recompensas y balance se configuran en datos y no se duplican en grandes scripts.
6. Primero un modo individual completo: no iniciar chat global ni multijugador antes de tener controles de privacidad, moderación, bloqueo, denuncias y pruebas de servidor.
7. Rendimiento desde el prototipo: limitar entidades activas, usar niveles de detalle, colisiones simples, actualizaciones escalonadas y perfiles gráficos para móviles.

## Plan de cierre de brechas

### P0 — Primer ciclo jugable
- Conectar el gestor de operaciones con el mapa, el Centinela, el director de amenaza y los resultados.
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

- The Planet Crafter: https://store.steampowered.com/app/1284190/The_Planet_Crafter/
- Animal Crossing: New Horizons, exploración y vida de la isla: https://animalcrossing.nintendo.com/new-horizons/explore/
- Animal Crossing: New Horizons, residentes y comunidad: https://www.nintendo.com/us/store/products/animal-crossing-new-horizons-us-109505/
- Godot Demo Projects: https://github.com/godotengine/godot-demo-projects
- Godot NavigationAgents: https://docs.godotengine.org/en/latest/tutorials/navigation/navigation_using_navigationagents.html

## Originalidad

Las referencias sirven para estudiar estructuras y decisiones de diseño. No reutilizar personajes, nombres, diálogos, mapas, música, arte ni interfaces distintivas. Para Titanes se priorizan personajes, regiones, criaturas, código y recursos visuales originales.

# Investigación de sistemas y arquitectura recomendada

Fecha: 2026-11-17. Motor objetivo: Godot 4.3. Plataformas objetivo: Android, PC y Web; otras plataformas requieren exportación y pruebas propias.

## Principios de arquitectura
1. Mantener sistemas pequeños con una responsabilidad clara. Main debe coordinar, no contener toda la lógica.
2. Usar escenas reutilizables para unidades, edificios, biomas, interfaz y encuentros.
3. Usar Resources o JSON versionados para definiciones de Centinelas, Abisales, misiones, objetos y mejoras; evitar duplicar estadísticas en scripts.
4. Usar señales para eventos entre sistemas y evitar referencias rígidas entre subsistemas.
5. Guardar estado persistente con versiones y validación de datos. El guardado local debe poder migrar perfiles antiguos.
6. Separar la simulación del mundo de la presentación visual para que el juego funcione en equipos modestos.

## Arquitectura objetivo por capas

```
GameRoot
├── AppFlow (menús, carga de escenas, pausa)
├── World
│   ├── RegionScene / BiomeScene
│   ├── PlayerCentinel
│   ├── AbisalDirector
│   └── WorldEvents
├── UI
│   ├── HUD
│   ├── BaseScreen
│   ├── HangarScreen
│   ├── ResearchScreen
│   ├── WarMapScreen
│   └── MissionDebrief
└── Systems
    ├── ProfileService
    ├── InventoryEconomy
    ├── BaseProduction
    ├── ResearchService
    ├── CampaignDirector
    ├── WarfrontService
    ├── MissionService
    ├── DamageRepairService
    └── AudioSettings
```

## Sistemas recomendados y diseño propio

### 1. Operaciones con preparación y consecuencias
Antes de cada misión: nivel de amenaza, potencia estimada, requisitos, objetivo, recompensa y riesgos. Después: informe de factores, daños, recursos perdidos, presión territorial y progreso. No ocultar al jugador por qué perdió.

### 2. Combate por componentes
Separar integridad de torso, actuadores, sensores y núcleo. Los daños deben modificar movilidad, detección o estabilidad. Reparar requiere recursos y tiempo de juego; no debe borrar permanentemente al jugador por una derrota aislada. Los valores concretos deben calibrarse con pruebas.

### 3. Director de Abisales
Máquina de estados: patrullar, investigar, aproximarse, atacar, cambiar patrón, retirarse. El director selecciona comportamiento según distancia, salud, terreno y estado de misión. Primero una IA determinista y depurable; luego variaciones.

### 4. Guerra regional
Cada región tiene control, presión, suministro, amenaza y edificios/objetivos. Las derrotas elevan presión; éxitos la reducen. La pérdida de una región debe bloquear o encarecer algunas operaciones, no bloquear toda la partida. La reconquista debe ser una cadena de objetivos.

### 5. Economía y base
Cada instalación declara coste, prerequisitos, nivel, producción y efectos. El inventario usa capacidad compartida por recurso. Evitar que la producción pasiva vuelva irrelevante la exploración; los materiales raros deben venir de expediciones y objetivos.

### 6. Investigación
Árbol ramificado con decisiones y requisitos. Los efectos deben ser visibles y medibles; evitar mejoras que solo aumentan números sin cambiar decisiones de juego.

### 7. Alianzas
En una primera fase: objetivos cooperativos asíncronos y donaciones limitadas de recursos ficticios. En fases posteriores: operaciones de alianza. Chat solo cuando haya moderación, reportes, bloqueo y controles adecuados; no se habilita con un simple campo de texto.

### 8. Rendimiento multiplataforma
Usar renderer Compatibility, LOD, visibilidad por distancia, límites de criaturas activas, sombras selectivas, escenas por sectores y perfiles de calidad. Medir en hardware real antes de fijar objetivos de FPS.

## Comparación de patrones de juegos
- XCOM 2: mapa estratégico y presión de campaña; adaptar la idea de amenazas temporales y consecuencias de misiones.
- Darkest Dungeon: desgaste acumulado; adaptar recuperación y preparación, sin crear castigos irreversibles desproporcionados.
- RTS de base: economía, producción y expansión; adaptar costes y líneas de suministro, sin copiar unidades o interfaz.
- Survival/exploration: descubrimiento, riesgo y fabricación; adaptar biomas, expediciones y recursos escasos.
- Juegos cooperativos: objetivos compartidos y roles; implementar después de tener servidor autoritativo.

## Estado observado del proyecto
Implementado en código (requiere pruebas funcionales): controlador y mundo 3D provisional, movimiento, recursos, base lógica, producción, mercado ficticio, contratos, helicópteros, ecosistema inicial, catálogo de Abisales, investigación, campaña por niveles, alianzas locales, perfil local, encuentros por comparación de potencia y presión territorial inicial.

Parcial: integración HUD, restauración completa, guardado al cambiar de escena, balance, IA, combate, arte, dispositivos móviles, exportación y backend.

No implementado como producto terminado: combate 3D en tiempo real, daño por partes, IA táctica, mapa regional real, multijugador online, servidor autoritativo, matchmaking, chat moderado, modelos/animaciones finales, APK probado y publicación.

## Orden recomendado de producción
P0: evitar pérdida de datos, reportes de misión y balance transparente.
P1: combate 3D mínimo jugable (movimiento, ataque, defensa, colisiones, salud y retirada).
P2: IA de un Abisal con 3 patrones, telegráficos legibles y estados.
P3: hangar con estadísticas comparables y reparación por componente.
P4: mapa regional con 3 regiones y control persistente.
P5: base 3D construible y producción conectada.
P6: campaña de 5 operaciones con rutas y consecuencias.
P7: pruebas de rendimiento/exportación en Android, PC y Web.
P8: backend y multijugador solo después de estabilizar el modo individual.

## Referencias técnicas
- Godot 4.3, Project organization: https://docs.godotengine.org/en/4.3/tutorials/best_practices/project_organization.html
- Godot 4.3, Scene organization: https://docs.godotengine.org/en/4.3/tutorials/best_practices/scene_organization.html
- Godot 4.3, Resources: https://docs.godotengine.org/en/4.3/tutorials/scripting/resources.html
- Godot 4.3, Saving games: https://docs.godotengine.org/en/4.3/tutorials/io/saving_games.html
- Godot 4.3, Performance: https://docs.godotengine.org/en/4.3/tutorials/performance/index.html
- Godot 4.3, Optimizing 3D performance: https://docs.godotengine.org/en/4.3/tutorials/performance/optimizing_3d_performance.html

## Nota de alcance
Este documento no afirma que el juego tenga multijugador, servidores, combate final ni exportaciones instalables. Describe qué existe, qué es parcial y el orden seguro para terminarlo.

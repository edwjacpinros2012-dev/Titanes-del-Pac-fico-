# Auditoría maestra A–Z del proyecto

**Fecha de auditoría:** 17 de noviembre de 2026  
**Motor declarado:** Godot 4.3, GDScript, renderer Compatibility  
**Rama revisada:** `main`  
**Repositorio:** https://github.com/edwjacpinros2012-dev/Titanes-del-Pac-fico-

> Este documento es el índice de verdad del proyecto. Distingue código existente, integración visible, validación automática y trabajo pendiente. Un archivo, una clase o una migración SQL no prueban por sí solos que una función esté terminada.

## 1. Diagnóstico ejecutivo

El proyecto es un **prototipo 3D modular en desarrollo**, no un juego comercial terminado ni una APK lista para instalar. Tiene una escena principal, un Titán provisional, recolección, economía ficticia, progresión, instalaciones de base, investigación, reconocimiento, NPC, criaturas, encuentros tácticos calculados por estadísticas, daño persistente simplificado, campaña y una base técnica para comunidad online.

La brecha principal es cerrar el ciclo de juego real: explorar → detectar amenaza → combatir en tiempo real → recibir consecuencias → reparar y reabastecer → mejorar el Centinela y la base → desbloquear nuevas regiones → repetir con desafíos más complejos. Hoy existen varias piezas de ese ciclo, pero el combate 3D real, la IA avanzada, la navegación, los escenarios completos y la validación manual todavía no están terminados.

### Semáforo honesto

| Área | Estado auditado |
|---|---|
| Proyecto Godot 4.3 y escena principal | Código presente; CI headless aprobado |
| Movimiento del Titán | Controlador presente; pruebas manuales pendientes |
| Recolección y recursos | Sistema inicial integrado; balance y pruebas pendientes |
| Economía y contratos | Sistemas locales; balance y pruebas pendientes |
| Base y producción | Gestión lógica; construcción visual completa pendiente |
| Investigación y evolución | Progresión lógica; validación integral pendiente |
| NPC y solicitudes | Código integrado; CI headless aprobado; interacción manual pendiente |
| Criaturas y Abisales | Catálogos y representaciones provisionales; IA final pendiente |
| Guerra y resultados | Simulación estadística; no es combate 3D real |
| Daño del Centinela | Cuatro subsistemas lógicos; conexión con animaciones/impactos reales pendiente |
| Regiones | Cuatro definidas en datos; solo Costa de la Aurora es frente persistente implementado |
| Guardado | Perfil JSON local versionado; cobertura y restauración integral pendientes |
| Alianzas | Demostración local; backend online no desplegado |
| Supabase | Cliente y SQL preparados; proyecto real, políticas y funciones por probar |
| Chat | Debe permanecer cerrado hasta moderación operativa |
| Android | Preset y scripts; APK real no generado ni probado |
| Web | Preset; falta export HTML5 real y publicar los archivos exportados |
| Windows/Linux | Presets; ejecutables reales y pruebas pendientes |
| Arte/audio | Primitivas y referencias provisionales; producción final pendiente |
| Publicación | No hay lanzamiento ni aprobación de tienda |

## 2. A–Z: inventario funcional

### A — Abisales y amenazas
**Existe:** catálogo JSON de enemigos, roles y niveles; encuentro inicial y selección de amenaza por nivel de campaña.  
**Falta:** modelos originales finales, animaciones, percepción, navegación, patrones, estados, telemetría, jefes con fases y encuentros 3D jugables.

### B — Base
**Existe:** diez instalaciones lógicas, requisitos, costes, niveles y producción local. Centro de mando y generador tienen escenas iniciales.  
**Falta:** edificios visibles completos, colocación libre, colisiones, rutas, interiores, energía por red, daño a edificios, construcción por etapas y defensa automatizada.

### C — Combate
**Existe:** preparación previa, lectura del rol enemigo, tácticas abstractas, comparación de potencia, resultados victoria/éxito parcial/retirada/derrota y consecuencias.  
**Falta — BLOQUEADOR P0:** combate 3D en tiempo real, controles de ataque/defensa/esquiva, impactos, hitboxes, salud de ambos, recuperación, cámaras, feedback, pausa y pantalla de resultados. No anunciarlo como acción real hasta implementarlo.

### D — Daño y reparación
**Existe:** chasis, movilidad, sensores y reactor; resultados aplican daño lógico; movilidad y potencia reciben penalización; reparación consume metal y energía.  
**Falta:** daño ligado a partes visibles, animación/efectos, averías durante combate, piezas reemplazables, mantenimiento de campaña, interfaz detallada y pruebas de economía de reparación.

### E — Economía
**Existe:** créditos ficticios, compra/venta de materiales, contratos y recompensas locales. No hay dinero real.  
**Falta:** balance por etapas, límites anti-exploit para futuro online, historial, interfaz completa, tutorial, economía de regiones y pruebas de inflación/escasez.

### F — Facciones y alianzas
**Existe:** gestor local de demostración, esquema SQL y cliente inicial para operaciones online.  
**Falta:** facciones NPC con objetivos, reputación por facción, diplomacia, permisos reales en servidor, invitaciones, roles, temporadas y pruebas con varias cuentas. La alianza local no es multijugador.

### G — Guardado
**Existe:** JSON local versionado, autosalvado y métodos de exportación/importación de varios gestores.  
**Auditoría concreta del snapshot actual:** sí guarda recursos, créditos, datos de investigación, nivel de base, estado de instalaciones, nivel del Titán, nivel de campaña, alianza local, tecnologías, frente de guerra, estado del encuentro y daño del Centinela, además del estado comunitario de NPC. **No aparecen en el snapshot principal** el progreso de contratos, estado de expediciones, misión activa de helicópteros/tiempo de vuelo, estado de brechas, descubrimientos del ecosistema, posición del jugador, nodos ya recolectados, clima/ciclo horario ni estado de sincronización de pilotos. Algunas de estas funciones podrían reiniciarse al cargar; deben decidirse y probarse, no asumirse persistentes.\n\n**Falta — BLOQUEADOR P0:** inventario de cada campo persistente; migraciones entre versiones; guardado atómico/backup; recuperación ante archivo corrupto; prueba de cerrar/abrir; completar y verificar restauración de contratos, helicópteros, criaturas, posición, expediciones, brechas, temporizadores, instalaciones y daño.

### H — Helicópteros
**Existe:** reconocimiento con dos unidades provisionales, envío y regreso con recompensas/datos.  
**Falta:** navegación física, aterrizaje, rutas, obstáculos, rescate, carga visual, daños, combustible ficticio y misiones con decisiones.

### I — Investigación
**Existe:** nueve tecnologías en tres ramas y efectos sobre exploración, logística, producción, mantenimiento, movilidad y preparación.  
**Falta:** árbol visual, prerequisitos visibles, tutorial, equilibrio, animaciones de investigación y pruebas de que cada bonificación afecta el sistema correcto y se conserva al cargar.

### J — Centinelas y evolución
**Existe:** Titán Alfa provisional, nivel y crecimiento de escala, controlador, enlace de pilotos y perfiles de evolución.  
**Falta:** varios modelos propios, siluetas diferenciadas, hangar, piezas, módulos, estadísticas por clase, animaciones, rig, audio, progresión Mark I–V integrada y equilibrio. La escala por nivel no reemplaza un sistema de piezas.

### K — Kit de recursos y fabricación
**Existe:** inventario, nodos, recetas, recolección y fabricación modular.  
**Falta:** interfaz de inventario, peso/capacidad, recetas desbloqueables, colas, fabricación visible, almacenamiento por instalación y pruebas de pérdida/duplicación.

### L — Localización y plataformas
**Existe:** entrada teclado, mando y controles táctiles; configuración horizontal y renderer compatible; presets Android/Web/Windows/Linux.  
**Falta:** diseño adaptable por resolución, accesibilidad, remapeo, pruebas de mandos reales, rendimiento móvil, macOS/iOS y traducciones. “Multiplataforma” no se considera terminado por tener presets.

### M — Misiones y campaña
**Existe:** gestor de campaña, niveles, contratos, expediciones y solicitudes de NPC.  
**Falta:** capítulos narrativos completos, escenas, objetivos encadenados, tutorial, decisiones, recompensas únicas, condiciones de fracaso y una campaña de principio a fin.

### N — NPC y población
**Existe:** ocho NPC con nombres, roles, rutas simples, diálogo inicial, solicitudes, moral, confianza y alerta comunitaria.  
**Falta:** horarios por instalación, asignación de especialistas, relaciones individuales, memoria de decisiones, diálogo ramificado, rescate de población, animaciones, pathfinding y pruebas de interacción. La confianza actual es global, no una relación individual completa.

### O — Online y cuentas
**Existe:** cliente Godot para Auth, perfil, alianzas, chat pendiente, bloqueos y denuncias; migraciones SQL preparadas.  
**Falta:** crear y asegurar un proyecto Supabase real, revisar migraciones, configurar URL/clave pública, funciones servidor, RLS probada, expiración/renovación de sesión, recuperación de cuenta, borrado de datos, límites de frecuencia, protección anti-trampas y pruebas de seguridad. Nunca introducir secretos de servidor en el cliente.

### P — Presentación, HUD y accesibilidad
**Existe:** HUD textual inicial y botones táctiles.  
**Falta:** pantallas de título, pausa, opciones, hangar, mapa, inventario, tecnología, mercado, contratos, NPC, resultados, créditos, subtítulos, tamaños de texto, navegación accesible y UI de mando/touch coherente.

### Q — QA y calidad
**Existe:** workflow que importa y arranca la escena en Godot 4.3 headless; matriz de pruebas y documentación.  
**Falta:** pruebas unitarias de lógica, pruebas de integración, pruebas de regresión de guardado, sesiones manuales, perfiles de rendimiento, pruebas de memoria, pruebas Android/Web y reporte de errores reproducibles.

### R — Regiones y mundo
**Existe:** datos para Costa de la Aurora, Selva Esmeralda, Cordillera Ígnea y Fosa Abisal; POI, clima, ciclo día/noche, brechas y eventos iniciales.  
**Falta:** mapa de navegación, desbloqueos funcionales de las cuatro regiones, biomas jugables distintos, objetivos regionales, recursos específicos, rutas, puntos de interés, control territorial multirregional y viajes entre zonas. Solo la Costa de la Aurora tiene frente persistente.

### S — Supervivencia
**Existe:** módulo de estadísticas de supervivencia y sistemas ambientales iniciales.  
**Falta:** decidir qué necesidades aportan diversión sin convertirse en castigo, conectarlas a interfaz y tutorial, probar su equilibrio y guardar/restaurar su estado. Evitar mecánicas tediosas sin propósito.

### T — Terreno, criaturas y ecosistema
**Existe:** terreno provisional, nodos, rocas, vegetación básica, clima, ciclo horario, criaturas ambientales y catálogo de doce Abisales.  
**Falta:** biomas, terreno esculpido, agua real, navegación, comportamiento ecológico, animaciones, sonido, densidad optimizada y variedad visual original.

### U — Usabilidad y tutorial
**Existe:** controles asignados y mensajes de estado.  
**Falta:** tutorial interactivo paso a paso, objetivos claros, glosario, explicación de derrota/reparación, guía de botones por dispositivo y opciones de accesibilidad.

### V — Visuales, VFX y audio
**Existe:** primitivas low-poly y materiales básicos.  
**Falta:** dirección artística cerrada, modelos originales, UV/materiales, rigging, animaciones, partículas, efectos de brechas, iluminación por bioma, música, efectos, mezcla, subtítulos y optimización de assets.

### W — Web y distribución
**Existe:** preset Web y página inicial bajo `web/index.html`.  
**Falta:** exportar el proyecto Godot a HTML5, ubicar el resultado en el directorio publicado, probar carga/controles/sonido y validar el despliegue. Una página web no es el juego exportado.

### X — eXperiencia de progresión
**Existe:** recursos, niveles, investigación, contratos, base, daño y presión territorial.  
**Falta:** ritmo de desbloqueos, hitos, variedad de decisiones, recompensas no repetitivas, dificultad adaptativa y pruebas de que el jugador no se queda sin recursos ni puede progresar sin esfuerzo.

### Y — Yunque de publicación y propiedad intelectual
**Existe:** guías de originalidad, distribución gratuita y preparación Android.  
**Falta:** nombre comercial definitivo y revisión de marca, licencias de cada asset/fuente/audio, política de privacidad, clasificación por edades, ficha de tienda, pruebas exigidas y publicación administrada por un adulto responsable cuando corresponda. No copiar personajes, diseños, nombres, música, mapas ni recursos de franquicias existentes.

### Z — Zona de lanzamiento
**Existe:** scripts y presets de exportación.  
**Falta:** instalar Godot 4.3 y plantillas compatibles, configurar OpenJDK 17 y Android SDK, exportar APK/AAB, instalarlo en dispositivos, corregir errores, medir rendimiento, firmar una versión release, exportar PC/Web y completar una lista de aceptación. No hay APK final verificado.

## 3. Validación automática revisada

Las cinco ejecuciones recientes del workflow `.github/workflows/godot-validation.yml` terminaron en **success**:

- 44173405253 — población NPC y solicitudes.
- 44173433163 — integración NPC y estado comunitario.
- 44173438746 — botón táctil NPC.
- 44173486363 — interacciones de reparación, investigación y moral.
- 44173492400 — documentación de NPC.

El workflow ejecuta importación headless y arranque breve de la escena principal. Esto no prueba jugabilidad, calidad visual, exportación, rendimiento en teléfono, conexión online ni integridad completa del guardado.

## 4. Prioridades obligatorias y orden de cierre

### P0 — Cerrar la base jugable antes de expandir
1. Crear pruebas automatizadas de inventario, economía, daño, campaña, guerra y guardado.
2. Auditar el snapshot de guardado y completar restauración determinista.
3. Construir una misión vertical jugable: salir de base, recolectar, detectar un Abisal, luchar en 3D, retirarse o ganar, recibir daños/recompensas, reparar y guardar.
4. Hacer que esa misión funcione con teclado, mando y pantalla táctil.
5. No añadir nuevas regiones o sistemas online hasta que este recorrido esté probado.

### P1 — Combate 3D
1. Salud y estados del Centinela y del Abisal.
2. Movimiento de combate y orientación.
3. Acciones de ataque, defensa, evasión y habilidades ficticias.
4. Colisiones, detección de impactos y ventanas de vulnerabilidad.
5. IA de enemigo por estados y patrones legibles.
6. Resultado, daño por subsistema, recompensa y retirada.
7. Cámara, audio, animación y feedback.
8. Pruebas de balance y rendimiento.

### P2 — Progresión conectada
1. Hangar y configuración de piezas.
2. Especialistas NPC asignables a instalaciones con efectos verificables.
3. Relaciones individuales y decisiones de comunidad.
4. Construcción visible y energía/almacén conectados.
5. Contratos y campaña que enseñen cada sistema.

### P3 — Mundo
1. Activar regiones existentes en el mapa.
2. Crear biomas diferenciados y rutas.
3. Añadir objetivos regionales y frentes persistentes.
4. Rescate y consecuencias de perder sectores.
5. Facciones NPC y diplomacia local.

### P4 — Online, solo cuando el modo individual sea sólido
1. Revisar SQL y políticas RLS.
2. Desplegar entorno de prueba.
3. Implementar validación de progreso y recompensas del lado servidor.
4. Probar con cuentas de prueba y roles distintos.
5. Mantener chat cerrado hasta moderación real, bloqueo y denuncias operativas.

### P5 — Producción y lanzamiento
1. Dirección artística y assets originales.
2. Audio, animación, UI y accesibilidad.
3. QA de hardware y rendimiento.
4. Exportaciones Android, Windows, Linux y Web.
5. Privacidad, propiedad intelectual, clasificación y publicación.

## 5. Criterio de “terminado”

Ninguna tarea pasa a completada solo porque exista un script. Se exige:

- [ ] Código implementado y revisado.
- [ ] Conexión desde la escena principal o flujo correspondiente.
- [ ] Interfaz y controles para los dispositivos objetivo.
- [ ] Guardado y restauración si modifica progreso.
- [ ] Prueba automática pertinente.
- [ ] Prueba manual en Godot.
- [ ] Prueba en hardware cuando afecte plataforma.
- [ ] Documentación y limitaciones actualizadas.

## 6. Investigación y referencias

Se toman ideas generales de diseño, no contenido protegido ni assets de terceros:

- No Man’s Sky — asentamientos, ciudadanos, especialistas, productividad y dilemas: https://www.nomanssky.com/frontiers-update/ y https://www.nomanssky.com/beacon-update/
- Godot 4.3 — exportación Android: https://docs.godotengine.org/es/4.3/tutorials/export/exporting_for_android.html
- Godot 4.3 — exportación de proyectos y plantillas: https://docs.godotengine.org/es/4.3/tutorials/export/exporting_projects.html
- Godot 4.3 — compilaciones Android con Gradle: https://docs.godotengine.org/en/4.3/tutorials/export/android_gradle_build.html
- Investigación ya documentada sobre horarios NPC, facciones, relaciones y progresión: `docs/NPC_POPULATION_AND_GAME_REFERENCES.md`, `docs/REFERENCE_RESEARCH.md` y `docs/SYSTEMS_RESEARCH_AND_ARCHITECTURE.md`.

La documentación oficial de Godot confirma que los presets no sustituyen las plantillas y SDK necesarios para exportar. Para Android se deben configurar OpenJDK 17, Android SDK y las plantillas compatibles con la versión del editor. El paquete exportado debe instalarse y probarse en hardware real.

## 7. Decisiones de producto que no deben perderse

- El jugador comienza como recluta con un Centinela Mark I y una amenaza de nivel bajo.
- La dificultad aumenta gradualmente, pero la preparación, investigación y decisiones importan.
- Puede haber victoria, éxito parcial, retirada y derrota; no todas las misiones terminan en victoria.
- La derrota tiene consecuencias recuperables y comprensibles, no pérdida arbitraria de todo el progreso.
- Recursos, créditos y comercio son ficticios; no introducir compras reales, anuncios ni suscripciones.
- Los Abisales son enemigos; no convertirlos en mascotas.
- Los diseños, personajes, historia, música, mapas, diálogos, interfaz y modelos deben ser originales.
- Chat global desactivado hasta contar con moderación y privacidad probadas.
- No prometer multijugador, APK, guardado nube o compatibilidad final antes de validarlos.

## 8. Próximo trabajo técnico recomendado

El siguiente bloque de implementación debe ser **“Vertical Slice 01: primera salida y primer combate real”**. Antes de construir más sistemas grandes, completar un escenario pequeño con inicio, objetivo, amenaza, combate real, consecuencias, regreso a base, reparación, recompensa y guardado. Esa será la primera prueba integral que permita medir si las piezas actuales forman un juego y no solo una colección de gestores.

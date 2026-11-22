# Manual maestro de agentes y herramientas — Titanes del Pacífico

> Documento rector del proyecto. Antes de modificar código, cada agente debe leer este archivo y la documentación de sistemas enlazada abajo. La prioridad es conservar e integrar el juego existente, no reiniciarlo.

## 1. Identidad y objetivo

**Titanes del Pacífico** es un juego original de acción, exploración, supervivencia, construcción de bases y guerra contra Kaijus colosales. La inspiración es el género de mechas contra monstruos; no se deben copiar personajes, nombres, diseños, mapas, música, marcas ni recursos protegidos de otras franquicias.

El objetivo es construir un juego realmente jugable, visualmente convincente y progresivamente conectado. Una interfaz bonita sin juego funcional no cuenta como entrega. Un sistema lógico desconectado tampoco cuenta como integración terminada.

## 2. Regla absoluta de conservación

Antes de cambiar cualquier archivo:
1. Inspeccionar la rama, estado Git, estructura y documentación vigente.
2. Leer los sistemas relacionados y sus dependencias.
3. Identificar qué funciona, qué está incompleto y qué no existe.
4. No reemplazar ni borrar sistemas existentes para simplificar una tarea.
5. No sobrescribir cambios de otros agentes ni archivos modificados por el usuario.
6. Trabajar en una rama de tarea; no trabajar directamente en `main`.
7. Cambios pequeños, reversibles y documentados.
8. No añadir credenciales, tokens, claves privadas ni datos personales al repositorio.

Si existe un conflicto, detenerse y explicar el conflicto antes de resolverlo. Nunca declarar una función terminada solo porque compila.

## 3. Visión funcional que debe preservarse

### 3.1 Ciudad viva y NPC
- Población civil y personal militar con nombres, profesiones, rutinas, turnos y rutas.
- Diálogos e interacciones con utilidad real.
- Ingenieros, científicos, reconocimiento, intendencia, defensa, médicos, pilotos y representantes civiles.
- Solicitudes, encargos, recompensas, moral comunitaria, confianza y alerta.
- La población debe reaccionar a victorias, derrotas, seguridad, suministros y estado de la base.
- Las ciudades y asentamientos deben tener servicios, edificios, población y necesidades. No reducirlos a decoraciones.

### 3.2 Base y defensas
- Centro de mando, hangar, reactor, refinería, laboratorio, almacén, radar, puerto aéreo, centro de alianzas y taller de reparación.
- Niveles, costes, requisitos, producción y efectos.
- Construcción y ampliación progresiva de instalaciones.
- Defensas de ciudad y costa, sensores, barreras, torretas ficticias, protección civil y reparación.
- Los ataques y el estado de guerra deben afectar las instalaciones sin borrar injustamente el progreso.

### 3.3 Centinelas / Jaegers y generaciones Mark
- Progresión Mark I, Mark II, Mark III, Mark IV y Mark V.
- Hangar, catálogo, selección, pilotos, despliegue, mantenimiento, reparación y mejoras.
- Piezas, módulos, integridad, energía, habilidades y experiencia.
- Los modelos y animaciones finales se deben producir o integrar con Blender y exportar a Godot mediante formatos compatibles como GLB/glTF.
- No sustituir arte final o assets existentes sin aprobación y copia de seguridad.

### 3.4 Kaijus y combate
- Catálogo de Kaijus originales con roles, patrones, amenazas y debilidades.
- Combate jugable en tiempo real: movimiento, cámara, ataques, defensa, energía, impactos, IA, objetivos y resultado.
- Tácticas, preparación, terreno, investigación, piloto, daños y decisiones deben influir.
- No garantizar victoria por tener más poder.
- Resultados posibles: victoria, éxito parcial, retirada y derrota.
- La derrota debe explicar sus causas, aplicar consecuencias razonables y ofrecer recuperación.
- Evitar bucles de fracaso que hagan imposible continuar.

### 3.5 Regiones y guerra territorial
- Regiones, sectores, exploración, presión enemiga, operaciones, disputa, pérdida y reconquista.
- Los resultados de misión cambian el estado del frente.
- Perder un sector no debe borrar toda la campaña.
- Registrar consecuencias y mostrar cómo recuperarse.

### 3.6 Economía y progresión
- Recursos del juego: metal, energía, cristal, datos de investigación y créditos ficticios.
- Recolección, inventario, capacidad, producción, comercio, fabricación, contratos y recompensas.
- Investigación y tecnologías que modifiquen producción, exploración, almacenamiento, defensa y reparación.
- Mercado exclusivamente de economía ficticia; no introducir pagos reales, apuestas ni microtransacciones.

### 3.7 Alianzas y comunidad online
- Crear y buscar alianzas, nombre, etiqueta, descripción y privacidad.
- Miembros, líder, oficiales, reclutas, solicitudes, invitaciones, aprobación y salida.
- Objetivos cooperativos, contribuciones, eventos y clasificación cuando estén implementados.
- Chat global y de alianza con moderación, bloqueo, denuncias, restricciones y controles de seguridad.
- Supabase está preparado en esquema/código inicial, pero no se debe afirmar que el online está operativo hasta configurar, desplegar y probar el backend con cuentas de prueba.
- No activar chat global sin moderación real. Nunca exponer claves de servicio en el cliente.

### 3.8 Guardado, campaña y plataformas
- Guardar y restaurar perfil, inventario, Centinelas, base, NPC, campaña, regiones y resultados de guerra.
- Probar persistencia después de cerrar y abrir el juego.
- PC como objetivo prioritario; Android y web requieren exportaciones y pruebas separadas.
- Vercel publica la aplicación web compatible; no ejecuta ni reemplaza el juego nativo de Godot.

## 4. Herramientas y responsabilidades

| Herramienta | Uso correcto | No confundir con |
|---|---|---|
| Godot 4.x | Motor, escenas, lógica, físicas, IA, UI y exportación | No es un modelador 3D |
| Blender | Modelado, rigging, materiales y animación 3D | No sustituye al motor |
| VS Code | Edición, terminal, agentes y depuración | No demuestra que el juego funcione |
| GitHub | Repositorio, ramas, PR, historial y documentación | Un commit no equivale a prueba visual |
| Git/Git Bash | Control de versiones y comandos | No es el repositorio remoto |
| Copilot Agent | Implementar tareas en el espacio de trabajo autorizado | No debe aprobar sus propios cambios sin pruebas |
| ChatGPT | Dirección, diseño, auditoría, prompts, revisión y apoyo de implementación | No debe afirmar que editó archivos si no lo hizo |
| Gemini u otros agentes | Segunda opinión, diseño o tareas acotadas | No deben modificar los mismos archivos simultáneamente |
| Supabase | Auth, PostgreSQL, RLS y Realtime | No está activo hasta configurarlo y probarlo |
| Vercel | Hosting y despliegue de la aplicación web | No publica automáticamente el ejecutable Godot |
| Node/npm/Vite | Tooling de la web existente | No reemplaza el proyecto Godot |

## 5. Organización de agentes

### Agente 0 — Director / arquitecto
Mantiene la visión, prioriza, define contratos entre sistemas y evita duplicación. No permite que se eliminen características sin autorización. Mantiene el tablero de estado.

### Agente 1 — Auditor de repositorio y GitHub
Inspecciona estructura, ramas, commits, PR, documentación, archivos duplicados y deuda técnica. No modifica código sin una tarea explícita. Informa rutas y evidencia.

### Agente 2 — Programador principal Godot
Implementa escenas, scripts, señales, recursos, guardado y conexión entre sistemas. Debe ejecutar Godot headless y pruebas relevantes.

### Agente 3 — Gameplay y combate
Se ocupa del movimiento, cámara, controles, golpes, defensa, colisiones, IA de Kaijus, objetivos, victoria, derrota, reinicio y HUD. Debe demostrar la misión en ejecución.

### Agente 4 — Mundo, ciudad y NPC
Se ocupa de ciudad, asentamientos, población, rutinas, diálogos, servicios, edificios, defensas y reacción de la comunidad.

### Agente 5 — Base, economía y progresión
Se ocupa de instalaciones, producción, inventario, recursos, comercio, fabricación, contratos, investigación, mejoras y balance.

### Agente 6 — Centinelas y hangar
Se ocupa del catálogo, generaciones Mark, selección, pilotos, piezas, módulos, animaciones, despliegue y reparación.

### Agente 7 — Kaijus, campaña y guerra
Se ocupa de catálogo, roles, amenazas, regiones, presión, operaciones, resultados, pérdidas, recuperación y reconquista.

### Agente 8 — Online y alianzas
Se ocupa de Supabase, perfiles, alianzas, rangos, solicitudes, invitaciones, chat moderado, seguridad y sincronización. Debe separar claramente prototipo local y online real.

### Agente 9 — Artista técnico Blender
Produce assets originales, optimizados y con escala, pivotes, materiales, esqueletos y nombres consistentes. Entrega GLB/glTF y documentación de importación.

### Agente 10 — QA / tester
Prueba rutas felices, errores, regresiones, guardado, controles, rendimiento y compatibilidad. No cambia el resultado esperado para hacer pasar una prueba sin justificarlo.

### Agente 11 — Integrador y release
Integra cambios revisados, verifica conflictos, pruebas, builds y PR. No mezcla cambios ajenos ni publica a producción sin autorización explícita.

## 6. Prompt maestro obligatorio para TODOS los agentes

Copia este bloque al iniciar cada agente:

> Trabajas en el proyecto **Titanes del Pacífico**, repositorio `edwjacpinros2012-dev/Titanes-del-Pac-fico-`. Lee primero `docs/AGENT_PLAYBOOK_MASTER.md`, el README y la documentación relacionada con tu tarea.
>
> Tu misión es mejorar el juego existente sin reiniciarlo ni eliminar características. Conserva ciudad viva, NPC, bases, defensas, instalaciones, recursos, economía, fabricación, investigación, Centinelas Mark I–V, hangar, Kaijus, combate, campaña, regiones, derrotas con recuperación, alianzas, chat global moderado y guardado.
>
> Antes de editar: informa rama, estado Git, archivos relacionados, dependencias y riesgos. Comprueba si hay cambios de usuario u otros agentes. Trabaja en una rama dedicada. No hagas `git reset --hard`, no borres archivos, no sobrescribas cambios ajenos, no hagas force-push y no subas secretos.
>
> Implementa solamente el alcance acordado. Reutiliza sistemas existentes; evita duplicar managers, perfiles, inventarios, escenas o señales. Si la integración requiere cambios fuera del alcance, explica y pide autorización antes.
>
> Al terminar, ejecuta pruebas automatizadas y comprobaciones de Godot/build que correspondan. Para gameplay, abre la escena y comprueba controles, cámara, colisiones, HUD, objetivos, victoria, derrota y reinicio. Las pruebas headless no sustituyen la verificación visual.
>
> Entrega un informe con: (1) resumen, (2) archivos creados/modificados, (3) sistemas conectados, (4) pruebas exactas y resultados, (5) pasos para reproducir, (6) limitaciones conocidas, (7) riesgos y (8) commit/PR si fue autorizado. No digas “terminado” si no hay evidencia. Si no puedes ejecutar una prueba, dilo claramente. No hagas commit, push, merge ni despliegue salvo autorización expresa.

## 7. Prompts especializados listos para copiar

### A. Godot / programador principal
> Actúa como programador principal Godot. Audita antes de editar. Implementa la tarea indicada reutilizando escenas, autoloads, recursos y managers existentes. Mantén compatibilidad con Godot 4.7.2 del proyecto. Evita duplicar sistemas de guardado, perfil, inventario, combate o progresión. Ejecuta pruebas headless y abre el proyecto para validar la escena afectada. Informa rutas y resultados exactos. No hagas commit ni push sin permiso.

### B. Gameplay / misión jugable
> Audita la misión actual. Debe ser una experiencia jugable real: control del Centinela, cámara funcional, movimiento, colisiones, ataques, defensa, energía, Kaijus con IA, objetivos claros, HUD, victoria, derrota, consecuencias, recompensas, reparación y retorno al hangar. La misión debe conectarse con inventario, guardado, campaña y guerra territorial existentes. No reemplaces el juego entero con una demo aislada. Prueba manualmente y con tests.

### C. Ciudad, NPC y defensas
> Revisa los managers NPC y base existentes. Construye progresivamente una ciudad 3D habitable con edificios, población, rutas, turnos, diálogos, servicios, defensas y daños recuperables. Los NPC deben tener funciones y solicitudes conectadas con economía, misiones y moral. Conserva los ocho NPC ya definidos y amplía sin borrar. Entrega evidencia visual en Godot.

### D. Alianzas y online
> Audita los scripts de comunidad y migraciones Supabase. Conserva creación de alianzas, miembros, roles, solicitudes, invitaciones, chat global y de alianza, bloqueos, denuncias y moderación. Distingue prototipo local de backend desplegado. No actives chat público hasta verificar Auth, RLS, moderación, rate limits y reportes. Nunca expongas service_role. Prueba con dos cuentas y roles diferentes.

### E. Blender / arte técnico
> Diseña assets originales para Titanes del Pacífico, sin copiar franquicias existentes. Antes de modelar, revisa escala y convenciones del proyecto Godot. Entrega modelos optimizados, pivotes correctos, materiales, UV, rig y animaciones cuando correspondan, exportados a GLB/glTF. No sustituyas assets existentes sin aprobación. Documenta polígonos, texturas, escala, nodos y pasos de importación.

### F. QA / auditor
> No implementes primero: verifica. Revisa cambios y requisitos. Ejecuta pruebas automatizadas, arranque del proyecto, escenas relevantes, controles, persistencia, economía, misión, victoria y derrota. Comprueba que NPC, alianzas, chat, bases y regiones no se hayan desconectado. Separa errores críticos, altos, medios y bajos. No modifiques pruebas para ocultar fallos.

### G. GitHub / integrador
> Revisa rama, diff, archivos nuevos, archivos borrados, cambios no relacionados y pruebas. No mezcles trabajo de otros agentes. Usa PR descriptiva, commits pequeños y reversibles. No hagas merge ni push a main sin autorización. Nunca uses git add . sin revisar el estado. Conserva el historial y deja instrucciones de rollback.

### H. Vercel / web
> Audita el proyecto web por separado del proyecto Godot. Identifica Root Directory, Framework Preset, Build Command, Output Directory y rutas. Verifica que la web sea una versión web compatible y no intentes publicar el ejecutable nativo de Godot como si fuera Vite. Inspecciona logs y errores antes de cambiar ajustes. Crea previews para probar; no despliegues a producción sin autorización. No imprimas ni solicites tokens.

## 8. Protocolo de tareas y aceptación

Cada tarea debe incluir:
- Objetivo observable.
- Sistemas existentes que toca.
- Archivos probables.
- Qué no debe cambiar.
- Criterios de aceptación.
- Pruebas requeridas.
- Evidencia solicitada.

Una tarea se acepta solo cuando:
1. El proyecto abre sin errores bloqueantes.
2. Las pruebas relevantes pasan.
3. Se verificó el comportamiento real de la escena o servicio.
4. El guardado y la carga siguen funcionando si fueron afectados.
5. No se rompieron sistemas relacionados.
6. Los cambios están explicados y revisables.
7. El usuario puede reproducir la prueba con instrucciones claras.

Estados del tablero: **No auditado**, **Pendiente**, **En desarrollo**, **Implementado sin verificar**, **Verificado**, **Bloqueado**. No usar “completo” sin pruebas.

## 9. Flujo de GitHub

- `main`: rama estable.
- `feature/<tema>`: trabajo nuevo.
- `fix/<tema>`: correcciones.
- `docs/<tema>`: documentación.
- Cada agente trabaja en su propia rama.
- Antes de integrar: revisar diff, ejecutar tests y confirmar que no hay cambios ajenos.
- PR debe describir objetivo, archivos, pruebas, capturas y riesgos.
- No borrar ramas ni cerrar PR sin revisar.
- No usar force push.
- No subir archivos temporales, builds grandes ni secretos.

## 10. Vercel y publicación web

- Vercel sirve la aplicación web existente (Vite/TypeScript/Three.js/Phaser si corresponde).
- Godot nativo requiere exportación específica para web si se decide publicar una versión Godot Web.
- No asumir que la web actual es el juego Godot.
- Primero inspeccionar el proyecto y su configuración; luego arreglar build y preview.
- Producción solo después de validar preview y tener autorización.
- Mantener secretos en variables protegidas de Vercel, nunca en el código ni logs.

## 11. Orden recomendado de desarrollo

1. Auditar estado actual y conservar trabajo.
2. Hacer que la misión de Godot sea realmente jugable y estable.
3. Conectar misión con hangar, recursos, reparación y guardado.
4. Integrar resultados con campaña, regiones y presión enemiga.
5. Reconectar NPC y solicitudes con acciones reales.
6. Completar base, edificios y defensas visibles.
7. Completar Centinelas, Kaijus, modelos y animaciones.
8. Completar alianzas locales y después backend online seguro.
9. Completar pruebas, rendimiento, exportaciones y publicación.

No intentar desarrollar todo simultáneamente. Integrar verticalmente por etapas sin borrar la visión global.

## 12. Informe obligatorio de cada agente

```text
PROYECTO:
AGENTE / ROL:
RAMA:
OBJETIVO:
ESTADO INICIAL DE GIT:
ARCHIVOS REVISADOS:
ARCHIVOS CREADOS:
ARCHIVOS MODIFICADOS:
SISTEMAS CONECTADOS:
PRUEBAS EJECUTADAS:
RESULTADOS EXACTOS:
PRUEBA VISUAL/MANUAL:
LIMITACIONES:
RIESGOS / CAMBIOS AJENOS:
PASOS PARA REPRODUCIR:
COMMIT / PR:
ESTADO FINAL: PENDIENTE | IMPLEMENTADO SIN VERIFICAR | VERIFICADO | BLOQUEADO
```

## 13. Documentos del proyecto que deben consultarse

- `README.md`
- `docs/ABC_MASTER_AUDIT.md`
- `docs/FAILURE_AND_WARFRONT_AUDIT.md`
- `backend/supabase/README.md`
- `backend/supabase/migrations/`
- `scripts/npc/npc_population_manager.gd`
- `scripts/base/base_development_manager.gd`
- `scripts/war/kaiju_war_manager.gd`
- `scripts/online/community_client.gd`
- `scripts/core/save_manager.gd`

Si una ruta no existe en la rama actual, no inventar su contenido: buscar su ubicación real y reportarla.

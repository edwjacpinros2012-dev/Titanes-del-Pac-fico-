# Informe maestro y transferencia a Gemini — Titanes del Pacífico
**Actualizado:** 23 de noviembre de 2026

## Visión
Juego original de supervivencia, gestión, exploración, combate de Jaegers contra Kaijus, defensa de ciudades y progresión tecnológica. Inspiración de escala/ciencia ficción, pero universo, criaturas, robots, nombres y assets deben ser originales.

## Principios de diseño
- El jugador no es invencible. Se puede ganar, perder, sufrir daños, retirarse o cumplir objetivos parcialmente.
- Derrotas tienen consecuencias recuperables y claras: recursos gastados, reparaciones, daños a instalaciones, evacuaciones; no bloquear injustamente toda progresión.
- Sistemas no cuentan como terminados porque exista un script: deben estar integrados en una escena/UI, probados, guardados/restaurados y documentados.
- No duplicar sistemas ni crear archivos sin conectarlos.
- Mantener seguridad y privacidad, moderación y protección contra abusos para funciones online.

## Dos targets
1. Godot 4: juego principal, escenas 3D, lógica GDScript, base, misiones, combate, exploración.
2. Web Vite/TypeScript con Phaser/Three.js: demo/presentación/loop web. No es una exportación del juego Godot. Evitar duplicar lógica sin plan.

## Sistemas ABC
A Kaijus: catálogo inicial; faltan IA por estados, comportamiento por especie, animación, hit feedback y variedad.
B Base: instalaciones; falta construcción conectada, niveles, costos, producción, consumo, daño y UI.
C Combate: prototipo; integrar movimiento, ataques, defensa, esquiva, habilidades, hitboxes/impactos, resultados.
D Daño: conectar estado lógico a piezas/visual, UI, reparación, persistencia.
E Economía: recursos/mercado; balance, límites, historial, transacciones consistentes y anti-duplicación.
F Facciones/alianzas: prototipo/local; roles, permisos, cooperación y backend online.
G Guardado: probar todos los managers, restauración, backups, migraciones, escrituras seguras.
H Helicópteros: sistema inicial; integrar escenas, misiones, timers y recompensas.
I Investigación: árbol, prerequisitos, efectos visibles, UI, balance.
J Jaegers: catálogo/progresión; modelos originales, clases, capacidades únicas, mantenimiento, componentes.
K Crafting/inventario: recetas y recursos; colas, capacidad, costos, UI y validación.
L Plataformas: presets PC/web/Android; controles, safe areas, remapeo, rendimiento y pruebas reales.
M Campaña: misión/loop inicial; objetivos encadenados, briefing, evaluación, reintentos y contenido.
N NPC/población: habitantes, rutas/solicitudes iniciales; diálogo, rutinas, profesiones, relaciones y persistencia.
O Online: Supabase preparado; no afirmar online productivo sin Auth, RLS, funciones de servidor, privacidad y seguridad.
P HUD/UI: paneles provisionales; navegación, pantallas completas, feedback, accesibilidad.
Q QA: pruebas/CI; faltan integración, regresión, QA manual, profiling, plataformas.
R Regiones: datos iniciales; mapa, biomas, rutas, POI y estado regional conectado.
S Supervivencia: módulos; definir/ integrar recursos, necesidades, estados, UI y guardado.
T Terreno: mundo provisional; biomas, navegación, landmarks, agua, vegetación, ecosistema.
U Tutorial: onboarding, guía de controles, objetivos, feedback, pausa y opciones.
V Visual/audio: arte provisional; dirección cinematográfica original, modelos, materiales, rig, animación, iluminación, audio, VFX y optimización.
W Web/Vercel: demo Vite; verificar salida, build y acceso; no equivale a exportar Godot.
X Progresión: Marks/desbloqueos; ritmo, hitos, efectos tangibles y requisitos.
Y Producción: instalaciones; balance de tasas, consumo, almacenamiento y conexión a economía.
Z Release: sin release comercial; exportar, probar hardware, privacidad, licencia/IP, rendimiento y checklist de tienda.

## Diseño de Jaegers
Atributos a diferenciar: fuerza, blindaje, movilidad, energía, estabilidad, sensores y resistencia. Mejoras de armadura, motores, sensores, armas/componentes, reparación, Marks, desbloqueos y apariencia. No basta con cambiar el skin; cada clase debe aportar una estrategia.

## Diseño de Kaijus
Especies y clases: rápidos, blindados, acuáticos, terrestres, grandes, atacantes de instalaciones y grupo. Estados AI sugeridos: explorar, detectar, perseguir, atacar, defender, reaccionar, cambiar objetivo, retirada/derrota. Comportamiento según especie, terreno, daño y objetivos.

## Combate
Movimiento, ataques ligeros/pesados, defensa, esquiva, habilidades, bloqueos, impactos, retroceso, partes dañables, cooldown, energía, objetivos y resultado. Resultados: victoria, victoria costosa, parcial, retirada, derrota, Jaeger incapacitado. Consecuencias con recuperación razonable.

## Base, ciudades, habitantes
Instalaciones: hangar, taller, fábrica, investigación, generador, radar, defensa costera, centro médico, refugio, almacén, centro de mando y puerto. Deben tener costos, niveles, producción/consumo, tiempo, daños y UI. NPC con profesión, ubicación, necesidades, especialidad, confianza, rutinas, solicitudes y persistencia. Ciudades pueden crecer, producir, evacuar, sufrir ataques, perder edificios y reconstruirse.

## Alianzas y online (futuro)
Alianzas: nombre, emblema, líder, miembros, rangos/permisos, chat, objetivos, reputación e historial. Rangos: líder, administrador, oficial, miembro, recluta. Cooperación en defensa, misiones, expediciones y proyectos. Chat global, alianza, grupo, misión; moderación, límites, bloquear/reportar y antispam. No simular online con datos locales. Implementar backend seguro, auth, RLS, validación del lado servidor, rate limits y moderación antes de activarlo.

## Economía
Recursos: acero, energía, componentes, suministros, créditos, datos científicos, aleaciones, repuestos, combustible, comida y materiales raros, según balance. Obtención, almacenamiento, consumo, fabricación, intercambio, pérdida y uso en construcción/reparación/investigación. Evitar duplicar recompensas o exploits.

## Exploración
Regiones (Pacífico, costas, islas, Japón, Filipinas, Australia, Américas, océano, brechas y zonas de alto riesgo) con mapa, ciudad/base, recursos, bioma, amenaza, misiones, Kaijus, eventos, rutas y estado. Expediciones: recolectar, investigar, rescatar, encontrar piezas/tecnología, descubrir zonas, enfrentar amenazas y puestos avanzados; riesgo y duración que consumen recursos.

## Campaña
Loop de misión: briefing, preparar Jaeger, equipar, desplegar, explorar/combate, objetivos, eventos/decisiones, resultado, reparar, recompensas y desbloqueos. Objetivos: eliminar, defender, proteger, evacuar, recuperar, investigar, reparar, escoltar, resistir, sobrevivir/retirarse. Decisiones afectan ciudades, población, recursos, alianzas, base, reputación, tecnología y misiones siguientes.

## Marks/progresión
Marks deben habilitar mejoras/tecnología/piezas/armas/capacidades, no sólo stats. Requieren investigación, materiales, créditos, componentes y objetivos.

## Dirección artística
Realismo cinematográfico, industrial militar sci-fi, escala monumental, iluminación volumétrica, lluvia/agua/humo/partículas, metal físicamente plausible, desgaste, ciudades densas y destrucción legible. Jaegers: silueta única, armor modular, articulaciones, pistones, cableado, paneles, cabina, refrigeración y desgaste. Kaijus: anatomía original, siluetas únicas, peso, piel, cicatrices y animación. Hangar: grúas, plataformas, técnicos, puentes, consolas y puertas enormes. Ciudad: edificios, tráfico, habitantes, refugios, evacuación, defensas, zonas destruidas/reconstruidas. Audio: ambientes, motores, metal, impactos estilizados, alarmas, radio, océano, maquinaria; audio contextual.

## Estado web/deploy conocido
- Repo: https://github.com/edwjacpinros2012-dev/Titanes-del-Pac-fico-
- Branch main.
- Demo web usa Vite/TypeScript y Phaser/Three.js; no es Godot export.
- Auditoría ABC previa menciona problemas de salida Vercel (STATIC_BUILD_NO_OUT_DIR), CSS import order y bundle pesado.
- Se añadió vercel.json para Vite, build npm run build, output dist. Confirmar configuración real del proyecto.
- Deployment producción commit fa2e0644321e6530541cdddfd3983107361c273a: READY en Vercel; URL https://titanes-del-pac-fico-pdudsvl23-edwpin.vercel.app. READY sólo confirma deploy, no QA de gameplay.
- Docs audit: docs/ABC_AUDIT_2026-11-23.md
- vercel.json en raíz.

## Prioridades
P0: verificar web; loop jugable de misión con inicio/combate/resultados/recompensa/reinicio; hangar/selección; guardado robusto; Godot abrir con renderer real sin errores.
P1: integrar NPC/base/economía/investigación/expedición/Kaiju/daño; segunda misión; controls/UI.
P2: ampliar campaña/regiones/arte/audio; online sólo después de backend seguro.

## Definition of Done
Cada sistema tiene escena/UI accesible; casos positivo/negativo/límite; sin exploits de recursos; persistencia si aplica; feedback de error; pruebas automatizadas y manuales; plataformas etiquetadas por estado. Mantener separados Código, Integrado, CI, Manual y Hardware. No inventar porcentajes globales.

## Instrucciones para Gemini
Antes de editar: inspecciona repo completo y rama actual; lee README, project.godot, scenes/scripts, package.json, web, docs y pruebas. Entrega inventario de sistemas con estados (implementado, parcial, stub, pendiente, bug), dependencias, archivos responsables, riesgos y propuesta de 3 tareas pequeñas. No afirmar que ejecutaste Godot si no puedes.

Trabaja en cambios pequeños y seguros. Antes de tocar un sistema, identifica el flujo y sus dependencias; reutiliza código existente, no dupliques managers ni crees archivos sin integración. Prioriza P0, gameplay verificable y bugs sobre añadir features enormes. Para cada cambio, explica archivos, objetivo, integración, tests y cómo probar manualmente. Ejecuta tests/build disponibles y reporta exactamente resultado; si no puedes ejecutar, dilo. No cambies secrets, claves/API, permisos, settings de seguridad, backend auth o políticas sin autorización explícita. No publiques/deployes ni merges a main sin revisión del propietario. Preserva el juego original y las mecánicas especificadas. Propón mejoras, pero implementa sólo tareas acotadas y revisables.

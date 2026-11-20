# Diagnóstico de campaña, Jaegers, Kaijus y recompensas — 19 nov 2026

## Alcance verificado

Revisión directa de los archivos `src/game-systems.ts`, `src/game-panels.ts`, `src/main.ts`, `package.json`, `README.md` y documentación de auditoría. No se ejecutó `npm run build` en esta sesión; por tanto, los cambios de TypeScript aún necesitan verificación de compilación y prueba visual.

## Hallazgo crítico: existen dos caminos de juego

- La raíz incluye un proyecto Godot (escenas/scripts) y documentación que lo declara como juego principal.
- `package.json` instala Phaser 3 + Three.js y Vite; `src/main.ts` construye una demo web.
- El README dice que `web/` es informativa y que el juego Godot no se exportó a HTML5, pero la demo Vite también contiene un mundo 3D y paneles.
- Debe decidirse y documentarse qué build será la experiencia principal. Vercel sirve la demo Vite; no debe confundirse con una exportación de Godot.

## Estado de la demo Vite

| Sistema | Qué existe en código | Qué falta para llamarlo completo |
|---|---|---|
| Escena 3D | Three.js: suelo, iluminación, base de bloques, un Jaeger y un Kaiju de primitivas | Arte/modelos originales, rig, animaciones, escenarios con composición y pruebas visuales |
| Controles | Movimiento básico y ataque de proximidad | Tutorial, esquiva/defensa abstractas, feedback, colisiones, pausa, reinicio y control táctil probado |
| Jaegers | Gipsy, Striker y Cherno como datos; cambiar selección modifica estadísticas y color del modelo placeholder | Modelos diferentes, perfiles realmente visibles, capacidades desbloqueadas comprobables, estado/repair y mejoras que cambien juego |
| Kaiju | Un modelo placeholder y una barra de integridad | Catálogo, estados de comportamiento, variantes, patrones legibles y escenarios distintos |
| Campaña | 12 nombres/descripciones; estado de completado/unlocked en save | Escenarios 2–12 no están construidos ni se pueden desplegar; objetivos por misión, evaluación y replay |
| Recompensas | La victoria de la demo otorga recursos y XP | Registro de resultados, bonificaciones por objetivo, rango, historial y economía equilibrada |
| Desbloqueos | Striker al completar 2 misiones; Cherno al completar 4 | Unidades y contenidos nuevos que correspondan a los hitos, pantalla de desbloqueo y validación de progreso |
| Hangar | Panel de selección y estadísticas básicas | Modelos 3D inspeccionables, diferencias de gameplay verificadas, equipamiento/repair y UI real |
| Base | Panel de edificios, mejoras y producción local | Construcción visual, recursos sincronizados, instalaciones con funciones, y feedback de cambio en el mundo |
| Tienda | Compra de algunos artículos con recursos local | Consumibles realmente usados, recetas, límites, inventario visible e historial |
| Alianzas | Demo local de nombre/alianza | Backend y multiplayer real. La demo no equivale a una alianza online |
| Guardado | localStorage con validación, backup y snapshot | Pruebas de cierre/reapertura, migraciones, exportación/importación, nube y control de duplicados |
| Android | UI móvil preliminar | APK/AAB real, pruebas en dispositivos, controles, rendimiento y orientación |
| Audio | No verificado como sistema completo | Ambiente, feedback de interfaz, efectos, mezcla, ajustes y subtítulos |

## Diagnóstico específico de progreso

### Campaña
- Solo el combate prototipo de la primera operación se conecta a completar misión.
- Las demás entradas de campaña son catálogo/estado, no niveles jugables.
- El botón de misiones permanece deshabilitado; se evitó permitir victorias simuladas.
- El menú principal despliega el combate prototipo, no una misión escogida del mapa.

### Jaegers
- El catálogo web contiene tres unidades: Gipsy, Striker y Cherno.
- Los desbloqueos se basan en la cantidad de misiones completadas.
- El modelo placeholder comparte geometría; el cambio de color no crea una silueta ni una animación distinta.
- No existe roster amplio, hangar de modelos final, piezas, mantenimiento integral ni habilidades específicas conectadas.

### Recompensas y progreso
- El prototipo tiene recursos, XP y recompensas por misión.
- Antes de esta actualización, el resultado de misión no comunicaba cantidades detalladas ni los hitos desbloqueados.
- Se agregó una tabla de recompensas calculada por misión, rango derivado de XP, hitos de desbloqueo (Striker tras misión 2, Cherno tras misión 4 y final de campaña en 12) y estado de campaña.
- La campaña debe validarse en navegador: ganar misión, verificar recursos/XP, revisar Hangar, recargar y comprobar progreso; intentar completar la misma misión otra vez y confirmar que no vuelve a pagar.
- No se anuncia que misiones 2–12 sean jugables: todavía no lo son.

## Prioridades de cierre

### P0 — Una vertical slice real
1. Iniciar con una misión que tenga objetivo visible y estado claro.
2. Poder pausar/reiniciar y terminar el encuentro.
3. Mostrar una pantalla de resultados que incluya recompensa, XP, objetivos y desbloqueos.
4. Guardar y recargar el progreso sin duplicar recompensas.
5. Permitir que el resultado de la misión desbloquee el siguiente contenido realmente construido.

### P1 — Progresión que se sienta
1. Completar una segunda misión con una condición de objetivo diferente.
2. Implementar pantalla de hangar que refleje unidades desbloqueadas y seleccionadas.
3. Hacer que una mejora o desbloqueo afecte una función verificable de la demo.
4. Añadir rango, medallas y registro de operaciones.
5. Separar los escenarios del código y sus datos configurables.

### P2 — Contenido y presentación
1. Modelos/animaciones originales y escenarios con identidad.
2. Más amenazas originales y estados de IA.
3. Base con construcciones visuales y cambios por mejora.
4. Audio, cámara, efectos, accesibilidad y controles móviles.
5. Exportaciones reales, pruebas de dispositivo y, después, servicios online.

## Reglas para evitar progreso falso

- No mostrar “completado” si el objetivo no se verificó.
- Una recompensa debe concederse una sola vez por operación.
- No desbloquear misión por una cifra de save incoherente; el acceso se deriva de completados consecutivos.
- No anunciar multiplayer, cuentas Google, nube o APK listo mientras no se validen con pruebas reales.
- Los sistemas de la versión Godot y la demo Vite deben tener estado separado hasta que se integren explícitamente.

## Referencias de diseño consultadas

- **Pacific Rim: Breach Wars** — colección/progresión de Jaegers, Shatterdome, mejoras, misiones, objetivos y recompensas: https://pacificrim.fandom.com/wiki/Pacific_Rim:_Breach_Wars
- **Pacific Rim: Jaeger Combat Simulator** — misiones con objetivos diferentes, protección de infraestructura y supervivencia: https://pacificrim.fandom.com/wiki/Pacific_Rim:_Jaeger_Combat_Simulator
- **Pacific Rim (videojuego)** — campaña y progresión de unidades mediante recompensas: https://en.wikipedia.org/wiki/Pacific_Rim_(video_game)
- **Kaiju Run, case study** — HUD de lectura clara, progreso visible, objetivos y ciclo de juego: https://tfeeney-design.com/kaiju.html

Adaptar principios y loops; no copiar modelos, mapas, interfaz, música, textos ni assets.

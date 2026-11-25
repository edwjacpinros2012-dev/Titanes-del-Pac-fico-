# QA — Fase 2 vertical slice

## Antes de probar
- Abrir el proyecto desde la carpeta que contiene `project.godot`.
- Usar una versión Godot 4 compatible con la configuración del proyecto.
- Esperar a que termine la importación de recursos.
- Revisar la pestaña Output y corregir primero errores de parseo o recursos faltantes.

## Pruebas funcionales

| ID | Prueba | Resultado esperado |
|---|---|---|
| P2-01 | Arranque | La escena principal inicia sin error y crea el Titán. |
| P2-02 | Cámara | La cámara sigue al Titán suavemente. |
| P2-03 | HUD | Metal, energía y cristal se muestran con valores coherentes. |
| P2-04 | Operación | El panel de misión muestra objetivo y estado del Titán. |
| P2-05 | Recompensa | El recurso energía de una amenaza aparece como energía en el HUD, no como una cuarta categoría. |
| P2-06 | Derrota | Al quedar incapacitado, aparece el botón de reintento. |
| P2-07 | Reintento | Se restaura integridad y reaparecen las amenazas sin recompensa gratuita. |
| P2-08 | Victoria | Al cumplir el objetivo, se marca la misión completada y se entrega la recompensa final una sola vez. |
| P2-09 | Persistencia | Tras cerrar y abrir, la misión completada no vuelve a entregar su recompensa final. |
| P2-10 | Escenario | Océano, franja costera y edificios se ven desde la cámara de juego. |
| P2-11 | Controles táctiles | Movimiento, acción principal, acción especial y defensa responden. |
| P2-12 | Guardado | No aparecen errores al guardar ni al cargar el perfil. |

## Validación técnica pendiente

- [ ] Godot importa el proyecto en modo editor sin errores.
- [ ] Godot ejecuta la escena principal en modo headless.
- [ ] GDScript no presenta errores de parseo.
- [ ] Las escenas referenciadas existen y cargan.
- [ ] Las señales se conectan una sola vez.
- [ ] El perfil local conserva los campos existentes.
- [ ] Se revisan versiones antiguas de guardado.
- [ ] Prueba manual de teclado y mando.
- [ ] Prueba manual de pantalla táctil.
- [ ] Prueba de rendimiento en equipo de capacidad modesta.

## No declarar aprobado

No marcar esta fase como aprobada por el mero hecho de que los archivos estén en GitHub. Hace falta ejecutar la lista anterior y conservar el resultado de CI o de la prueba local.


## Verificación de esta revisión (2026-11-25)
- [x] Gipsy es la única unidad disponible al crear una partida nueva; Striker y Cherno dependen de hitos de campaña.
- [x] La evolución Mark se almacena por identificador de Jaeger en el guardado local del navegador; al seleccionar otra unidad se recupera su Mark individual.
- [x] El valor heredado `jaegerMark` se migra como Mark del Jaeger seleccionado para conservar partidas anteriores.
- [x] TypeScript check y build de producción: GitHub Actions run 45519487175, éxito.
- [x] Build y type-check del workflow principal: run 45519486872, éxito.
- [ ] Godot: run 45519486918 detectó un identificador de misión ausente y un literal de README; ambos se corrigieron. La nueva ejecución run 45519654891 está en curso; no se declara aprobada hasta que termine.
- [ ] Prueba manual de recarga/cambio de escena en navegador real.
- [ ] El PDF binario original todavía no está versionado; consultar `REFERENCIA_PDF_ORIGINAL.md`.
- [ ] Modelos GLB finales, texturas PBR, rigs, animaciones, ciudad/hangar de calidad final y efectos completos.
- [ ] Deployment Vercel con el SHA más reciente y merge a main.

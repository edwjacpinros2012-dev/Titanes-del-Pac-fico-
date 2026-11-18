# Estado real y plan maestro de sistemas

Fecha de revisión: 2026-11-18. Basado en README, PR #10 y la arquitectura visible. Este documento es un diagnóstico de archivos/arquitectura, no certifica que el juego haya sido ejecutado.

## Estado por bloques

### Base implementada en prototipo (integración y pruebas pendientes)
- Escena 3D, movimiento, cámara, recogida de recursos.
- Recursos, inventario, fabricación y evolución inicial.
- Base con diez instalaciones, requisitos, costes y producción pasiva.
- Energía, investigación, clima y ciclo día/noche.
- Expediciones, puntos de interés, descubrimientos.
- Mercado ficticio con créditos, contratos y recompensas.
- Helicópteros de reconocimiento/recolección y eventos.
- Registro de criaturas/ecología y encuentros con resultados, reparación/recuperación.
- Campaña Mark I–V, alianzas demo y población NPC.
- Mission loop Base → despliegue → operación → informe → base.
- Perfil local/identidad offline, ajustes y esquema de nube/OAuth no activos (PR #10).

### Completar antes de considerar la base sólida (P0)
1. **Arranque limpio:** importar proyecto, corregir parser/recursos, iniciar escena principal y cerrar sin errores.
2. **Save/load:** probar perfil nuevo, guardado automático/manual, corrupto, copia de respaldo, migración, restauración de todas las variables y reinicio.
3. **Loop vertical jugable:** tutorial guiado → reunir → fabricar → instalar → expedición → descubrimiento → informe → recompensa → desbloqueo → siguiente misión.
4. **UI de juego:** inventario, recetas, mapa/regiones, misiones, base, tecnología, descubrimientos, contratos, pausa, ajustes; todos los botones deben actuar y mostrar errores/feedback.
5. **Controles:** teclado/mando, táctil, cámara, remapeo básico, interfaz escalable y safe areas.
6. **QA automatizado:** test por manager, auditoría de integración, smoke run, pruebas de save/load y balance; CI Godot debe finalizar verde.
7. **Contenido mínimo:** tutorial completo, 3 regiones, 10 instalaciones con UI/uso claro, 12 criaturas registradas, 20 misiones, 20 recetas y 30 descubrimientos (objetivos iniciales, no afirmación de que ya existan).
8. **Arte/audio:** sustituir primitivos por assets originales; animaciones, feedback, ambientación, música y efectos; LOD y optimización móvil.

### Implementado en rama de trabajo: restauración regional (validación pendiente)
- `RegionRestorationManager` con progreso de 0–100 por región, categorías de exploración/ecología/infraestructura/investigación, cuatro hitos y guardado validado.
- Conectado a recogida, mejoras de base, investigación, observación de criaturas, reconocimiento y estabilización de brechas; indicador en HUD.
- Test dedicado y auditoría CI añadidos. Aún falta ejecutar Godot para confirmar parser y runtime.

### P1: ampliar los sistemas
- Árbol de tecnología con ramas (exploración, base, energía, análisis, movilidad, logística) y prerequisitos claros.
- Mapa de regiones, rutas, clima regional, puntos de interés persistentes y eventos rotativos.
- Expediciones por etapas con riesgos ambientales, objetivos alternativos y decisiones; retorno opcional antes de quedar sin suministros.
- Recursos por región y estaciones de recolección; respawn y balance.
- Fabricación con recetas, estaciones, cola, desbloqueos y gestión de inventario.
- NPC: roles, rutinas, necesidades simples, tareas asignadas, diálogo contextual, reputación y rescate.
- Base: construcción por módulos, espacio/energía, mantenimiento, producción, almacenamiento, mejoras visuales.
- Contratos: cadena de encargos, recompensas, reputación, objetivos verificables y vencimiento opcional.
- Ecología: observaciones, patrones, hábitats, huellas, investigación, descubrimientos raros; bestiario.
- Campaña: capítulos, eventos narrativos, tutoriales, cinematics sencillas, objetivos y consecuencias persistentes.
- Eventos: condiciones dinámicas, alertas, evacuación, asistencia, rescate, logística y recuperación regional.
- Accesibilidad: tamaño de texto, subtítulos, contraste, sensibilidad, vibración opcional, reducción de movimiento.
- Telemetría local de QA sin enviar datos; analítica remota opt-in y apagada por defecto.

### P2: distribución y servicios
- PC exportación y pruebas de rendimiento.
- Android: controles táctiles, escalado, memoria, batería, perfiles de dispositivo, APK/AAB y pruebas reales.
- Web: comprobar limitaciones de exportación y memoria; solo publicar si el rendimiento es aceptable.
- Backend: autenticación real, verificación en servidor, nube, sincronización conflict-safe, moderación y privacidad; no desplegar hasta configurar/validar.
- Comunidad: chat apagado por defecto; moderación, reportes, bloqueo, consentimiento y protección de menores antes de habilitar.
- Pruebas de accesibilidad, seguridad de datos, políticas de tienda, contenido, licencias y marca.

## Referencias de diseño investigadas y adaptación original

- **Subnautica:** descubrimiento → planos → herramientas/vehículos → zonas más profundas. Adaptación: registrar pistas y materiales nuevos abre capacidades que permiten visitar regiones antes inaccesibles; no copiar contenido ni mapas.
- **The Planet Crafter:** progreso ambiental visible ligado a máquinas, energía y desbloqueos. Adaptación: estabilización regional con indicadores de energía, clima, biodiversidad y reconstrucción; la región cambia visualmente al completar hitos.
- **Pacific Drive:** expediciones acotadas, preparación en refugio/base, riesgo variable, vuelta segura y mejora entre salidas. Adaptación: misiones por zonas/rutas, preparación de suministros, condiciones ambientales cambiantes y resumen de regreso. No copiar assets, narrativa ni sistemas propietarios.
- **Principio de producción:** un pequeño equipo debe reutilizar módulos y crear variación por datos/semillas, en lugar de exigir un mundo enorme de una sola pieza.

## Próximo orden de implementación
1. Validación Godot/CI y auditoría de saves.
2. Unificar HUD y menú de sistemas; impedir solapamientos de paneles.
3. Tutorial con objetivos/feedback y misión completa de inicio a recompensa.
4. Sistema de expedición por etapas con variaciones ambientales y retorno.
5. Mapa regional + registro de descubrimientos + desbloqueos visibles.
6. NPC con roles y tareas; base conectada a producción y logística.
7. Revisión de balance y pruebas de regresión.

## Gate de aceptación
Cada sistema debe tener: archivo/manager, UI accesible, entrada/salida conectada, persistencia, validación de datos, feedback de usuario, test, documentación y evidencia de ejecución. Si falta uno, el sistema sigue “parcial”.

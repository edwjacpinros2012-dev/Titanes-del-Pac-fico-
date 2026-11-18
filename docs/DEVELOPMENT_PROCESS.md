# Proceso de desarrollo, QA y cierre

## Regla de trabajo
No se marca una función como terminada por tener un script o documento. Se requiere código integrado, una prueba que pase, flujo visible desde el juego y validación manual en una plataforma objetivo.

## Pipeline de cada cambio
1. Plan: registrar objetivo, archivos/sistemas afectados, dependencias, riesgos y criterios de aceptación.
2. Implementación: cambios pequeños; evitar mezclar varios sistemas sin pruebas.
3. Validación estática: comprobar rutas, escena principal, recursos y referencias.
4. CI: importar Godot 4.3 headless; correr sanity checks; ejecutar pruebas de lógica; iniciar escena brevemente.
5. Revisión: leer logs, registrar fallos y no contar CI fallida como aprobación.
6. Integración: actualizar documentación/estado; asegurar save/load, UI y señales.
7. Prueba manual: teclado, touch/mando según alcance; iniciar, pausar, jugar, guardar/cargar, cerrar y abrir.
8. Release gate: exportar artefacto real, instalarlo, verificar rendimiento, controles y errores.
9. Reporte: commit, pruebas ejecutadas, resultados, límites y porcentaje recalculado.

## Gates
- Gate A — Repositorio: rutas/escena principal/README/workflow presentes.
- Gate B — Godot import: cero errores fatales de parseo/import.
- Gate C — Lógica: tests automatizados pasan; regresión de guardado incluida.
- Gate D — Smoke: escena principal inicia sin crash.
- Gate E — Manual: recorrido funcional completo confirmado por persona.
- Gate F — Plataforma: export real y pruebas hardware/browser.
No saltar Gate E/F al declarar una plataforma o sistema listo.

## Cadencia
- Cada commit: CI y revisión de diff.
- Cada sistema nuevo: test positivo, negativo, persistencia si corresponde y caso de error.
- Cada semana: revisión de deuda técnica, dependencias, referencias de diseño, bugs P0/P1, riesgos de guardado y plataformas.
- Cada hito: prueba vertical slice, recalcular progreso por evidencia.

## Matriz mínima para módulos
- Entrada válida funciona.
- Entrada inválida/no saldo/no prerequisito no altera estado.
- No duplica recompensa, señal, desbloqueo ni transacción.
- Estado persiste y restaura cuando corresponde.
- UI presenta coste, resultado y error.
- Controles compatibles con dispositivos declarados.
- Offline no requiere backend si el modo offline debe funcionar.
- Logs claros; nunca incluir credenciales privadas.

## Pruebas automatizadas actuales
- tests/test_core_logic.gd: estado inicial, recursos, costes, señales, desbloqueo idempotente y guardado/perfil.
- tests/repo_sanity.py: archivos/rutas esenciales y pasos CI esperados.
- .github/workflows/godot-validation.yml: import, sanity, core tests y smoke run.

## Bloqueadores de release
No publicar ni llamar APK listo mientras no se verifique exportación con plantillas/SDK, instalación y arranque en hardware real, controles touch, rendimiento, restauración de perfil, privacidad, propiedad intelectual y revisión de publicación.

## Métrica
El porcentaje se calcula con áreas ponderadas. Código/documentación sin prueba aporta avance parcial; CI aprobada aporta evidencia de import/lógica; manual y hardware completan jugabilidad y plataforma. Reportar gates aprobados y pendientes.

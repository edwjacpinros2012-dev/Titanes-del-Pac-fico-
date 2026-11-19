# Titanes del Pacífico

Juego 3D de exploración, supervivencia, recolección, fabricación, construcción y guerra de robots gigantes contra monstruos colosales, desarrollado con Godot 4. El nombre es provisional y debe pasar una revisión de marcas y originalidad antes de publicarse.

## Abrir el proyecto
1. Instala Godot 4.
2. Descarga o clona este repositorio.
3. En Godot, pulsa **Importar** y selecciona `project.godot`.
4. Ejecuta con F6/F5.

## Sistemas y contenido preparados
- Escena 3D inicial con movimiento, cámara y recolección básica.
- Recursos, inventario, fabricación, mejoras de base y evolución.
- Gestión lógica de diez instalaciones de base con desbloqueos, requisitos, costes y producción pasiva; sin arte final todavía.
- Titán Alfa y controlador con arte provisional de primitivas.
- Construcción, energía, investigación, clima y ciclo día/noche.
- Expediciones, puntos de interés y descubrimientos.
- Mercado interno con créditos ficticios, materiales, compra/venta y existencias limitadas.
- Contratos, recompensas de juego y reconocimiento con helicópteros.
- Ecosistema inicial y catálogo de doce Kaijus originales: los monstruos son amenazas enemigas, nunca mascotas ni compañeros.
- Encuentros con victoria, éxito parcial, retirada y derrota, con reparación y recuperación.
- Campaña y progresión inicial de Jaegers Mark I–V.
- Alianzas locales de demostración.
- Esquema inicial Supabase para perfiles, alianzas, chat moderado, bloqueos y denuncias.
- Base de datos adicional para guardado en nube, vinculación de identidad Google Play Games y progreso regional, con escrituras reservadas al servidor.

## Economía y distribución
- El juego se prepara como **gratuito para descargar**.
- No habrá compras dentro de la aplicación, microtransacciones, suscripciones, anuncios ni Google Play Billing.
- El mercado ficticio dentro del mundo usa créditos obtenidos jugando; no procesa dinero real.
- Consulta `docs/ANDROID_FREE_RELEASE.md` para el proceso de Google Play.
- Consulta `data/platform/google_play_release.json` para el estado de preparación. Los valores marcados como provisionales no están listos para publicación.

## Plataformas objetivo
- PC: teclado y mando.
- Android y tabletas: controles táctiles y orientación horizontal.
- Navegadores: objetivo Web mediante exportación Godot.
- La compatibilidad real de cada exportación sigue pendiente de pruebas en dispositivos y navegadores.

## Controles principales
- **WASD / flechas / stick izquierdo:** moverse.
- **Pantalla táctil:** cruceta virtual y botones de acción.
- **E:** recoger recurso cercano.
- **B:** mejorar el Centro de mando.
- **V:** seleccionar instalación de base.
- **N:** mejorar la instalación seleccionada.
- **T:** evolucionar el titán.
- **F:** sincronizar pilotos.
- **R:** estabilizar una brecha.
- **H:** enviar helicópteros.
- **C:** abrir/cerrar mercado interno; con el mercado abierto, 1–3 compra y 4–6 vende con créditos ficticios.
- **J:** iniciar/resolver encuentro Kaiju; tecla de retirada según configuración del prototipo.

## Loop inicial integrado (prototipo)
- Misión inicial de recolección de metal con progreso y recompensa de energía/investigación.
- Al completarla se desbloquea Islas Quebradas.
- Expedición: reúne cristal y recibe una recompensa, con cancelación.
- Eventos regionales temporales que dan un recurso extra al recoger el tipo indicado.
- El estado de misión, expedición, región y evento se guarda en el perfil local.
- Pruebas automáticas añadidas para este loop; revisar GitHub Actions antes de asumir que la última revisión está aprobada.

## Estructura
- `assets/`: modelos, texturas, audio e interfaz.
- `scenes/`: escenas Godot.
- `scripts/`: lógica modular.
- `data/`: contenido configurable.
- `backend/supabase/migrations/`: esquemas SQL iniciales; deben revisarse y aplicarse manualmente en un proyecto propio.
- `docs/`: diseño, investigación, publicación y estado.
- `web/`: página informativa; no es todavía una exportación jugable del juego.

## Cuentas, comunidad y seguridad
El registro de piloto local funciona en este dispositivo: permite crear/usar un nombre de piloto, genera un ID local, valida el nombre, migra el perfil y mantiene una copia de recuperación. No requiere correo ni contraseña. El inicio con Google, la sincronización en nube y las alianzas online todavía no están conectadas a un servicio real. Supabase Auth y el esquema SQL son una base de arquitectura, no un backend desplegado. El chat global permanece desactivado hasta tener moderación, reportes, bloqueos, controles de privacidad y revisión operativa.

Las credenciales privadas y claves de servicio nunca deben guardarse en el cliente Godot ni en GitHub. Las escrituras del progreso en nube y la vinculación de Google Play Games deben validarse desde servidor.

## Proceso de desarrollo

Consulta docs/DEVELOPMENT_PROCESS.md para el pipeline, gates de QA, pruebas mínimas, cadencia de revisión y criterios de lanzamiento.

## Validación automática
Se añadió `.github/workflows/godot-validation.yml` para que GitHub Actions intente importar el proyecto y ejecutar brevemente la escena con Godot 4.3 en cada cambio. El estado real de la ejecución se consulta en la pestaña Actions del repositorio.

## Estado real
No se ha verificado la compilación de todos los scripts en una ejecución local de Godot. Los modelos, rig y animaciones finales, biomas completos, IA avanzada, multijugador, exportación Android y conexión real a backend siguen pendientes. No se debe considerar un módulo terminado solo porque exista su archivo.

## Publicación
Google Play requiere una cuenta de desarrollador y revisión de la aplicación. El creador menor de 18 años necesita que un padre, madre o tutor adulto gestione la cuenta y los acuerdos. La publicación pública completa tiene una tasa única de registro de desarrollador según las condiciones oficiales vigentes; que el juego sea gratuito no elimina esa tasa. Google, no el equipo del juego, decide la aprobación.

Documentación:
- `docs/ANDROID_FREE_RELEASE.md`
- `docs/ORIGINALITY_AND_IP.md`
- `docs/ABC_MASTER_AUDIT.md` — auditoría completa A–Z, estado real y prioridades de cierre.
- `docs/ROADMAP.md`
- `docs/CONTENT_STATUS.md`
- `docs/SYSTEMS_REFERENCE_RESEARCH_EXPANSION.md` — nueva investigación de sistemas, referencias y propuestas de expansión.
- `docs/SYSTEMS_RESEARCH_AND_ARCHITECTURE.md
- `docs/DIAGNOSTICO_COMUNICACION_QA_REFERENCIAS.md` — matriz de comunicación entre sistemas, riesgos, pruebas P0, criterios de integración y referencias adicionales.
- `docs/DIAGNOSTICO_REAL_2026-11-18.md` — diagnóstico técnico con correcciones, resultados CI y bloqueos verificados.
- `docs/SECOND_PHASE_GAP_AUDIT_2026-11-18.md` — auditoría de segunda fase con brechas de integración, módulos no conectados, prioridades P0/P1/P2 y plan de vertical slice.

## Exportar e instalar

- Android APK: `scripts/build_android.ps1`
- Android/Web/Windows/Linux: `scripts/build_all.ps1`
- Instalar APK en un Android conectado por ADB: `scripts/install_android.ps1`

Lee `docs/ANDROID_BUILD.md`, `docs/PLATFORM_TARGETS.md` y `docs/QA_TEST_MATRIX.md` antes de exportar. La configuración prepara los destinos, pero las exportaciones requieren plantillas y SDK locales y pruebas en dispositivos reales.

## Preparar Windows sin tener Godot instalado

- [Guía de primeros pasos](docs/PRIMEROS_PASOS_SIN_GODOT.md)
- [Script de preparación automática para Windows](tools/preparar_proyecto_windows.ps1)

El script descarga el proyecto en Documentos sin sobrescribir una carpeta existente. Godot debe descargarse desde el sitio oficial; el script no instala software ni requiere permisos de administrador.

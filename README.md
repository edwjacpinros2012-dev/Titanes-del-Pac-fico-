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

## Controles principales
- **WASD / flechas:** moverse.
- **E:** recoger recurso cercano.
- **B:** mejorar la base.
- **T:** evolucionar el titán.
- **F:** sincronizar pilotos.
- **R:** estabilizar una brecha.
- **H:** enviar helicópteros.
- **C:** abrir/cerrar mercado interno; con el mercado abierto, 1–3 compra y 4–6 vende con créditos ficticios.
- **J:** iniciar/resolver encuentro Kaiju; tecla de retirada según configuración del prototipo.

## Estructura
- `assets/`: modelos, texturas, audio e interfaz.
- `scenes/`: escenas Godot.
- `scripts/`: lógica modular.
- `data/`: contenido configurable.
- `backend/supabase/migrations/`: esquemas SQL iniciales; deben revisarse y aplicarse manualmente en un proyecto propio.
- `docs/`: diseño, investigación, publicación y estado.
- `web/`: página informativa; no es todavía una exportación jugable del juego.

## Cuentas, comunidad y seguridad
La autenticación y las alianzas online todavía no están conectadas a un servicio real. Supabase Auth y el esquema SQL son una base de arquitectura, no un backend desplegado. El chat global permanece desactivado hasta tener moderación, reportes, bloqueos, controles de privacidad y revisión operativa.

Las credenciales privadas y claves de servicio nunca deben guardarse en el cliente Godot ni en GitHub. Las escrituras del progreso en nube y la vinculación de Google Play Games deben validarse desde servidor.

## Estado real
No se ha verificado la compilación de todos los scripts en una ejecución local de Godot. Los modelos, rig y animaciones finales, biomas completos, IA avanzada, multijugador, exportación Android y conexión real a backend siguen pendientes. No se debe considerar un módulo terminado solo porque exista su archivo.

## Publicación
Google Play requiere una cuenta de desarrollador y revisión de la aplicación. El creador menor de 18 años necesita que un padre, madre o tutor adulto gestione la cuenta y los acuerdos. La publicación pública completa tiene una tasa única de registro de desarrollador según las condiciones oficiales vigentes; que el juego sea gratuito no elimina esa tasa. Google, no el equipo del juego, decide la aprobación.

Documentación:
- `docs/ANDROID_FREE_RELEASE.md`
- `docs/ORIGINALITY_AND_IP.md`
- `docs/ROADMAP.md`
- `docs/CONTENT_STATUS.md`

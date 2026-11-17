# Ruta de desarrollo

## Objetivo
Juego 3D original de guerra de robots gigantes contra monstruos colosales. El jugador empieza como recluta con un Mark I y una base pequeña, explora, investiga, construye y progresa mientras las amenazas presionan regiones. Motor: Godot 4.

## Hitos
- [x] Repositorio y prototipo inicial.
- [x] Arquitectura modular y datos configurables.
- [x] Controlador y escena visual provisional del Titán Alfa.
- [x] Lógica inicial de inventario, guardado, recetas y fabricación.
- [x] Lógica inicial de energía, construcción, clima, expediciones y descubrimientos.
- [x] Mercado interno con créditos ficticios, contratos y recompensas de juego.
- [x] Reconocimiento aéreo con helicópteros y regreso a base.
- [x] Ecosistema inicial y catálogo de doce Kaijus enemigos originales.
- [x] Encuentros con victoria, retirada, derrota y recuperación.
- [x] Diseño de campaña progresiva Mark I–V.
- [x] Diseño de alianzas, roles e interacción cooperativa.
- [x] Esquema SQL inicial para perfiles, alianzas, chat, bloqueos y denuncias.
- [x] Migración base para guardado en nube, progreso regional y vínculo de identidad Google Play Games (sin escritura directa desde el cliente).
- [x] Política de producto: descarga gratuita, sin compras dentro de la aplicación, suscripciones, anuncios ni Billing.
- [x] Guía de publicación gratuita y lista de verificación de Google Play.
- [x] Guía de originalidad y revisión de propiedad intelectual.
- [ ] Corregir e integrar todos los sistemas en la escena principal y HUD.
- [x] Añadir gestión lógica de diez instalaciones de base, requisitos, costes y producción pasiva local (pendiente de prueba en Godot).
- [ ] Integrar capacidad de almacén, energía, reparación y efectos reales de cada instalación.
- [ ] Unificar guardado local de todos los sistemas y probar restauración.
- [ ] Producir modelos 3D finales, rig y animaciones.
- [ ] Crear biomas jugables completos e IA avanzada.
- [ ] Configurar backend real, Auth, funciones de servidor y políticas RLS.
- [ ] Implementar guardado en nube validado por servidor.
- [ ] Implementar enlace Google Play Games Services y probarlo en Android.
- [ ] Implementar alianzas online con validación de permisos en servidor.
- [ ] Mantener chat desactivado hasta contar con moderación y controles de privacidad probados.
- [x] Añadir capa inicial de entrada para teclado, mando y controles táctiles.
- [x] Preparar ajustes generales de escalado, orientación horizontal y renderer compatible.
- [x] Añadir flujo de GitHub Actions para importar y ejecutar el proyecto en modo headless con Godot 4.3.
- [ ] Ajustar cada panel del HUD a móvil/tableta y validar resoluciones.
- [ ] Exportar e instalar Android en dispositivos reales.
- [ ] Exportar y probar Web, Windows, Linux y macOS.
- [ ] Preparar política de privacidad, ficha, clasificación y formularios de Play Console.
- [ ] Completar pruebas cerradas y solicitar acceso a producción.
- [ ] Enviar a revisión de Google y esperar su decisión.

## Economía
La moneda y el mercado son exclusivamente sistemas ficticios de juego. No se implementarán compras con dinero real, microtransacciones, suscripciones, anuncios ni Google Play Billing.

## Reglas de producción
Un sistema solo se marca como terminado cuando está integrado, probado manualmente en Godot y documentado. Un esquema SQL no equivale a un backend desplegado; un archivo de configuración no equivale a una integración Android; una solicitud de publicación no equivale a aprobación.

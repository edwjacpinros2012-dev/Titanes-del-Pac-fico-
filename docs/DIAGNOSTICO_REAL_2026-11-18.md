# Diagnóstico técnico real — 18 de noviembre de 2026

## Alcance
Se revisó el árbol actual de GitHub (scripts, escenas, datos, configuración, documentación, pruebas, SQL y workflow CI). Este diagnóstico se basa en archivos y resultados de CI; no reemplaza la ejecución en una PC Windows ni pruebas en hardware Android.

## Correcciones realizadas
- Guardado local: corregido el parseo/restauración de regiones desbloqueadas en el arreglo tipado de Godot.
- Separación de persistencia: la partida y el perfil se guardan en archivos diferentes para que el perfil no sobrescriba el guardado del juego.
- Validación de datos: la carga valida diccionarios, tipos básicos, cantidades negativas y regiones; los snapshots parciales conservan valores por defecto del estado.
- Inventario: costes negativos se rechazan para evitar crear recursos al retirar un coste negativo.
- Supabase: las migraciones ahora tienen prefijos únicos y ordenados: 0001, 0002, 0003, 0004. Antes había prefijos 0002 y 0003 duplicados.
- Pruebas: se ampliaron las pruebas de lógica de guardado, inventario y mercado, incluyendo transacciones inválidas y el caso de guardar perfil sin destruir la partida.

## Resultados verificados
- CI en commit `8db50535`: 20 comprobaciones de repositorio aprobadas, 40 pruebas de lógica aprobadas y smoke run de escena principal terminó con código 0.
- CI en commit `28597fb1`: 40 pruebas de lógica aprobadas (0 fallidas), importación, sanity y smoke run aprobados.
- Validación estática realizada desde GitHub: 18 archivos JSON analizados, 0 errores de parseo.
- Migraciones SQL: versiones `0001`, `0002`, `0003`, `0004` comprobadas como únicas.
- CI en commit `eeb2c758` añade 3 pruebas para snapshots parciales y limpieza de nodos de prueba; el resultado final de esa ejecución está pendiente al redactar este documento.

## Advertencia del smoke test headless
El smoke run de Godot 4.3 devuelve código 0 y no reporta errores de script, pero el renderer dummy/headless emite numerosos mensajes `mesh_get_surface_count` con parámetro nulo. Esto impide usar el smoke run como evidencia de calidad visual. La prueba visual requiere abrir el proyecto en Godot en Windows con renderer real.

## Vercel
El sitio informativo `web/index.html` está desplegado en Vercel. El deployment correspondiente al commit `eeb2c758` aparece `READY`. El sitio web no es una exportación jugable del juego; no se ha desplegado el juego Godot como web.

## Estado por área
- Base Godot, escenas y scripts: existentes; importación headless aprobada.
- Guardado y economía local: corregidos algunos defectos y probados por CI.
- NPC, criaturas, campaña, base, exploración y encuentros: código presente; no todos los flujos tienen cobertura de pruebas.
- Combate: los encuentros aún usan resolución lógica/táctica; no es un sistema completo de combate 3D animado.
- Arte final, rigs, animaciones, biomas completos y navegación avanzada: pendientes.
- Backend Supabase: esquema y migraciones preparadas, pero proyecto real no configurado ni migraciones aplicadas.
- Android: exportación APK y prueba en dispositivo real no verificadas.
- Windows: no se ha confirmado instalación local de Godot ni recorrido manual del juego.

## Próximas prioridades
1. Completar CI de las 3 pruebas adicionales y resolver cualquier regresión.
2. Instalar Godot 4.3 en Windows, importar y ejecutar la escena con renderer real.
3. Probar el loop jugable: mover → recoger → comerciar/mejorar → encuentro → recompensa → guardar → reabrir.
4. Revisión de UI/controles táctiles en teléfono y tableta.
5. Exportación Android y prueba física antes de afirmar que existe una APK instalable.
6. Mejorar combate 3D, IA/navegación, animación, arte y contenido.

## Porcentaje
No se calcula un porcentaje global de desarrollo del juego: no hay criterios completos de lanzamiento cubiertos y las pruebas manuales/hardware siguen pendientes. Los porcentajes de CI solo describen los checks automatizados ejecutados, no el desarrollo total.

# Investigación técnica adicional: navegación, escenas y persistencia

Fecha: 17 de noviembre de 2026. Referencias fijadas a Godot 4.3 para coincidir con la versión del proyecto.

## Navegación de NPC y Abisales
Referencia oficial: https://docs.godotengine.org/es/4.3/tutorials/navigation/navigation_using_navigationagents.html

- NavigationAgent3D calcula rutas y ofrece el siguiente punto; el nodo padre sigue siendo responsable de mover al personaje.
- La consulta de siguiente punto debe ejecutarse en el ciclo de física mientras la navegación no haya terminado.
- No actualizar target_position en cada frame sin necesidad: comparar el destino y actualizar solo cuando haya cambiado lo suficiente.
- NPC y criaturas necesitan NavigationRegion3D/NavigationMesh válidos antes de esperar pathfinding.
- La evasión de agentes es complementaria: no sustituye la navegación ni el diseño de colisiones.

Aplicación: primera prueba con un NPC y un Abisal en una zona pequeña, después ampliar a grupos. Evitar activar navegación de toda la población cuando está fuera de cámara.

## Rendimiento de navegación
Referencia oficial: https://docs.godotengine.org/en/4.3/tutorials/navigation/navigation_optimizing_performance.html

- Evitar mallas complejas como fuente de horneado; usar colisiones sencillas.
- No volver a consultar rutas cada frame.
- Distribuir las actualizaciones de agentes en grupos para evitar picos.
- Mantener la malla de navegación con polígonos razonables y comprobar rutas inalcanzables.

Aplicación: simulación por distancia. Los NPC lejanos usan horarios/estados abstractos; los cercanos activan navegación y animación.

## Organización de escenas
Referencia oficial: https://docs.godotengine.org/es/4.3/tutorials/best_practices/scene_organization.html

- Main es el punto de entrada y coordina el flujo general.
- Las subescenas deben poder instanciarse sin depender de rutas rígidas al árbol de otra escena.
- Separar actores, mundo, interfaz y servicios según sus dependencias reales.
- Usar señales y contratos de datos para comunicar sistemas.

Aplicación: Main debe ir perdiendo lógica interna a favor de coordinadores pequeños, sin hacer una refactorización masiva que rompa el prototipo.

## Datos configurables
Referencia oficial: https://docs.godotengine.org/en/4.3/tutorials/scripting/resources.html

Los Resources son contenedores de datos serializables y editables en el Inspector. Conviene migrar definiciones estables de unidades, edificios, objetos, regiones y misiones a Resources tipados cuando el catálogo JSON inicial se estabilice.

Aplicación: JSON sirve para catálogos iniciales y revisión en Git; Resources tipados sirven cuando el contenido requiera edición directa desde Godot y referencias entre recursos.

## Guardado
Referencia oficial: https://docs.godotengine.org/es/4.3/tutorials/io/saving_games.html

- Identificar explícitamente qué objetos son persistentes y qué campos se guardan.
- Serializar identificadores y valores, no instancias de nodos.
- JSON es legible y práctico para perfiles sencillos, pero tiene tipos limitados y mayor tamaño.
- Los datos complejos pueden requerir serialización binaria o codificadores propios.
- Versionar el esquema y probar recuperación/migración.

Aplicación: la nueva escritura temporal y copia de seguridad reduce el riesgo de reemplazo incompleto, pero no sustituye el inventario de campos persistentes, migraciones y pruebas de cierre/reinicio.

## Secuencia de implementación recomendada
1. Probar navegación en una escena de laboratorio aislada.
2. Añadir un NavigationAgent3D al primer NPC de base, con destinos actualizados por cambios de horario.
3. Añadir navegación al primer Abisal solo dentro de la misión activa.
4. Crear pruebas de guardado para contratos, helicópteros, brechas, región, daño y posición.
5. Extraer datos de unidades y edificios a recursos tipados cuando las definiciones se estabilicen.
6. Integrar la primera misión vertical antes de ampliar el número de biomas.

## Límite
La documentación explica capacidades del motor; no demuestra que el proyecto ya tenga navegación, IA final o guardado completo. Esas funciones deben implementarse y validarse en Godot 4.3.

# Informe técnico de estado del proyecto

Fecha: 17 de noviembre de 2026

## Resumen ejecutivo
El repositorio contiene un prototipo funcional en construcción de Godot 4.3. Ya existen numerosos sistemas de progresión y gestión, pero la experiencia de combate todavía no es un juego de acción 3D completo: el resultado del encuentro se calcula mediante potencia comparada. El mayor riesgo es seguir agregando subsistemas sin cerrar un bucle jugable completo.

## Sistemas presentes
- Proyecto Godot 4.3, escena principal 3D y renderer Compatibility.
- Autoloads GlobalState y SaveSystem.
- Centinela Alfa provisional, cámara, terreno y recolección.
- Recursos, créditos ficticios, comercio, contratos y expediciones.
- Diez instalaciones lógicas de base y producción local.
- Árbol de nueve tecnologías con tres ramas.
- Helicópteros de reconocimiento y criaturas ambientales.
- Catálogo de Abisales y encuentros con victoria, éxito parcial, retirada y derrota.
- Campaña Mark I–V por niveles.
- Alianzas de demostración locales y cliente comunitario inicial.
- Controles de teclado, mando y táctiles.
- Guardado local JSON, autosalvado y presets Android/Web/Windows/Linux.
- Presión de guerra persistente en la primera línea costera.

## Actualización técnica incorporada
- El informe previo a la batalla ahora muestra potencia estimada del Centinela, amenaza del Abisal, diferencia y clasificación de preparación.
- Cada resultado de batalla registra potencia, amenaza, diferencia y evaluación.
- El perfil local guarda/restaura el Abisal activo, número de encuentros y último informe de batalla.
- Los encuentros activos no se reanudan automáticamente después de cargar: se restablecen como amenaza detectada para evitar estados de combate a medias.

## Brechas principales
1. Combate 3D real: movimiento de combate, ataques, defensa, esquiva, colisiones, vida y estados de daño.
2. IA enemiga: patrones, percepción, navegación y comportamiento.
3. Daño por componentes y reparación con consecuencias.
4. Mapa regional con control, suministro, presión y reconquista.
5. Construcción física y visual de edificios.
6. Pantallas completas de hangar, tecnología, mapa, misión y resultados.
7. Guardado integral: verificar inventario, posición, criaturas, contratos, helicópteros, región y temporizadores.
8. Multijugador: el estado actual no equivale a un servidor online listo.
9. Arte, animación, audio y optimización final.
10. Exportaciones y pruebas en hardware real.

## Validación
La ejecución automática de GitHub Actions del commit de actualización de hoja de ruta terminó con éxito (Godot 4.3 headless: importación y arranque breve). Esto comprueba sintaxis/importación y arranque básico, no sustituye pruebas de combate, guardado en dispositivo ni exportación APK.

## Prioridades
P0: robustecer guardado y reportes.
P1: crear combate 3D jugable.
P2: IA y daño por componentes.
P3: hangar y reparaciones.
P4: guerra regional de varias zonas.
P5: base visual y campaña.
P6: backend online, moderación y publicación, después de cerrar modo individual.

# Cimientos del juego: sistemas de base y progresión

Esta entrega prioriza sistemas y reglas; no añade modelos, texturas, edificios 3D finales ni animaciones.

## Centro de mando e instalaciones

El nuevo `BaseDevelopmentManager` administra diez instalaciones con niveles, costes, requisitos y desbloqueos:

1. Centro de mando: determina el nivel de base.
2. Hangar de Centinelas.
3. Núcleo energético: genera energía de juego cada minuto.
4. Refinería: genera metal de juego cada minuto; se desbloquea con base nivel 2.
5. Laboratorio: requiere hangar nivel 2.
6. Almacén central.
7. Torre de reconocimiento: requiere laboratorio y base nivel 3.
8. Puerto aéreo: requiere hangar nivel 2 y base nivel 3.
9. Centro de alianzas: requiere torre de reconocimiento nivel 2 y base nivel 4.
10. Taller de reparación: requiere hangar nivel 1.

Las mejoras consumen metal, energía y cristal del inventario local. No usan dinero real ni compras dentro de la aplicación. La producción se aplica al inventario local cada 60 segundos. El arte y la colocación espacial de estas instalaciones quedan para la fase visual posterior.

## Controles del prototipo

- B: mejorar el Centro de mando.
- V: seleccionar la siguiente instalación desbloqueada.
- N: intentar mejorar la instalación seleccionada.
- F5: guardar el perfil.

El sistema guarda niveles de instalaciones, selección y ciclo de producción en el perfil local. Los perfiles anteriores se migran conservando el nivel de base conocido.

## Próximos pilares de programación

- Integrar costes de mantenimiento y reparación del Centinela con el Taller de reparación.
- Conectar capacidad del Almacén y consumo energético con las instalaciones.
- Sustituir la resolución automática de encuentros por combate jugable con estados, enfriamientos, daño y retirada.
- Hacer que presión territorial y actividad enemiga avancen con el tiempo y reaccionen a victorias/derrotas.
- Integrar contratos y recompensas en un director de misiones único.
- Añadir pruebas automatizadas y validar todo en Godot 4.3+ antes de marcar estos módulos como terminados.

## Estado de verificación

Los archivos se han añadido al repositorio, pero esta sesión no dispone de Godot para importar, ejecutar o validar el proyecto. La integración debe probarse en el editor antes de considerarse terminada.

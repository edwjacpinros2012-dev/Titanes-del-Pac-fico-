# Investigación de NPC y vida de la base

## Referencias de diseño estudiadas

Estas referencias se usan para estudiar patrones de diseño, no para copiar personajes, arte, diálogos, mapas ni código:

- **No Man's Sky – Frontiers:** asentamientos con población, productividad, felicidad, costes de mantenimiento, alertas, decisiones de gestión y habitantes que recorren el lugar según rutinas. Fuente oficial: https://www.nomanssky.com/frontiers-update/
- **No Man's Sky – Beacon 5.7:** personalidades de colonos, habilidades de especialistas, decisiones de ciudadanos, expediciones y resultados que afectan la comunidad. Fuente oficial: https://www.nomanssky.com/beacon-update/
- **Stardew Valley / Majora's Mask:** los horarios ligados al reloj del mundo hacen que los habitantes tengan lugares y actividades diferentes a lo largo del día. Referencia de mecánicas: https://compendium.tallmove.com/systems/npc-schedules
- **Kenshi:** el mundo puede generar situaciones por conflictos entre facciones y agendas de sus grupos, en vez de depender exclusivamente de encargos estáticos. Fuente del desarrollador: https://lofigames.com/about/faq/
- **Shadow of War / XCOM 2: War of the Chosen:** memoria de agentes, rivalidades, consecuencias y escalada de amenazas como ideas para un futuro sistema de rivales persistentes. Resumen de mecánicas: https://compendium.tallmove.com/systems/domain/inhabitants

## Diseño propio: personal del Pacto de Defensa

La primera versión incorpora ocho personajes originales en la base:

1. Mara Velez — ingeniera jefe
2. Ivo Soria — jefe de reconocimiento
3. Lina Arce — científica
4. Tarek Mena — intendente
5. Sena Cruz — comandante de defensa
6. Yara Solis — médica de campaña
7. Ken Vidal — piloto de apoyo
8. Eva Paredes — representante civil

Cada uno tiene una profesión, diálogo inicial, aspecto de color distinto y una ruta corta de patrulla. Sus posiciones cambian por turnos de simulación. Son personajes de demostración con rutinas sencillas; todavía no tienen navegación inteligente ni animación avanzada.

## Interacción y solicitudes

- Acércate a un NPC y pulsa **Z** o el botón táctil **Z**.
- Hablar con un NPC puede activar una solicitud de la comunidad.
- Solo hay una solicitud activa a la vez; hay objetivos de recolección, reconocimiento, estabilización de brechas, comercio, defensa, reparación y observación.
- Completa el objetivo y vuelve a hablar con el mismo personaje para cobrar.
- Las recompensas se integran con los recursos y créditos existentes.
- Las solicitudes, el ánimo comunitario, la confianza y la alerta se guardan en el perfil.

## Comunidad reactiva

- Las victorias aumentan el ánimo y reducen la alerta.
- Los éxitos parciales mejoran ligeramente el ánimo.
- Las retiradas y derrotas elevan la preocupación y la alerta.
- Mejorar instalaciones aporta una pequeña mejora al ánimo.
- Completar solicitudes aumenta la confianza y el ánimo.

## Próximas ampliaciones recomendadas

1. Árboles de diálogo con elecciones y consecuencias.
2. Rutinas completas: turnos, descanso, comedor, talleres, enfermería y refugios.
3. Especialistas asignables a instalaciones para mejorar producción, reparación, investigación y reconocimiento.
4. NPC con rasgos y habilidades, historial, relaciones y recuerdos de decisiones.
5. Evacuaciones y necesidades civiles cuando un frente se pierde.
6. Misiones de escolta, rescate, reconstrucción, investigación y diplomacia.
7. Patrullas de aliados y pilotos de apoyo con roles diferenciados.
8. Sistema de rivales recurrentes con historial de encuentros, sin copiar sistemas protegidos de otras franquicias.

## Límites técnicos de esta versión

El movimiento actual es un desplazamiento sencillo entre puntos de ruta; no es navegación por obstáculos. Los diálogos son textos cortos, no conversaciones ramificadas. Los NPC no tienen voces, animaciones completas, comportamiento social emergente ni sincronización multijugador. Es una primera capa funcional que debe probarse con Godot 4.3 y ajustarse para móvil.

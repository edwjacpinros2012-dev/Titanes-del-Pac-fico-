# Titanes del Pacífico — Visión maestra del juego

**Estado del documento:** visión y requisitos de diseño.  
**Importante:** este documento registra lo que queremos construir; no afirma que los sistemas estén implementados. Cada sistema debe verificarse en el juego y en el código antes de marcarlo como terminado.

## 1. Visión general

Titanes del Pacífico será un juego de estrategia, gestión, construcción, supervivencia y combate. El jugador participa en la defensa de la humanidad frente a las amenazas kaiju, administra instalaciones y recursos, desarrolla titanes desde el Mark I, protege ciudades y habitantes, establece alianzas y toma decisiones cuyas consecuencias pueden incluir victorias o derrotas.

El juego no debe reducirse a una sucesión de combates. La preparación, la logística, la economía, la investigación, la población, las defensas, las alianzas y las decisiones estratégicas deben influir en el resultado de la guerra.

## 2. Titantes / programa Jaeger

- Comenzar la progresión con titanes de generación Mark I.
- Investigar, fabricar y desbloquear generaciones posteriores.
- Diferenciar titanes por funciones, atributos, capacidades y equipamiento.
- Mejorar armadura, estructura, movilidad, energía, sensores y sistemas de combate.
- Equipar y cambiar componentes y armamento.
- Gestionar mantenimiento, reparación, daños y disponibilidad de cada titán.
- Mostrar progreso, costes, requisitos y consecuencias de cada mejora.

## 3. Habitantes, NPC y vida civil

- Ciudades con habitantes y NPC, no escenarios vacíos.
- Ingenieros, científicos, pilotos, soldados, médicos, trabajadores y equipos de rescate.
- NPC con tareas, rutinas y funciones relacionadas con la ciudad o la base.
- Reacciones ante alarmas, ataques, evacuaciones y reconstrucción.
- Refugios, rutas de evacuación y protección de civiles.
- La seguridad y el bienestar de la población deben tener consecuencias en el estado de las regiones y en las decisiones del jugador.

## 4. Ciudades y territorios

- Varias ciudades y regiones con características propias.
- Zonas residenciales, puertos, industrias, instalaciones militares e infraestructura.
- Daños a edificios e infraestructura durante ataques.
- Evacuación, rescate, reparación y reconstrucción.
- Estado de seguridad, población, infraestructura y actividad económica por región.
- Los ataques y las decisiones de defensa pueden cambiar el estado de una ciudad.

## 5. Bases y construcción

- Bases y hangares donde alojar, reparar y preparar titanes.
- Construcción y ampliación de hangares, talleres, laboratorios, centros de mando y almacenes.
- Instalación y mejora de radares, sensores, muros, torres y otras defensas ficticias del juego.
- Gestión de energía, suministros, capacidad, personal y mantenimiento.
- Ataques a bases y necesidad de repararlas y protegerlas.
- La ubicación, preparación y nivel de las instalaciones deben influir en la defensa.

## 6. Economía, recursos y tienda

- Economía persistente con créditos y distintos materiales/recursos.
- Recompensas por misiones y operaciones, con costes de fabricación, mantenimiento, reparación e investigación.
- Tienda o mercado para adquirir componentes, equipamiento y artículos disponibles.
- Mostrar precios, requisitos, inventario y saldo antes de confirmar compras.
- Evitar compras duplicadas, saldos negativos y cobros repetidos.
- Las decisiones económicas deben implicar prioridades y sacrificios: invertir en titanes, ciudades, defensas o investigación.
- Guardar de forma fiable las transacciones y el progreso del jugador.

## 7. Investigación y mejoras

- Árboles o líneas de investigación para titanes, armas, sensores, defensas, medicina, infraestructura y tecnología.
- Requisitos de recursos, tiempo de investigación o condiciones de campaña, si se adoptan.
- Mejoras con efectos comprensibles y equilibrados.
- Centros de investigación y personal científico como parte de la gestión de la base.
- Tecnologías compartidas o desbloqueos obtenidos mediante cooperación entre aliados.

## 8. Combate y sistema de batalla

- Combate terrestre y marítimo según las misiones.
- Movimiento, ataques, defensa, habilidades y equipamiento de titanes.
- Diferentes kaijus con capacidades y comportamientos distintos.
- IA enemiga que reaccione al contexto y a las acciones del jugador.
- Salud, daños, estados, reparación y consecuencias posteriores a cada batalla.
- Armas, habilidades, efectos e interfaz que comuniquen claramente lo que ocurre.
- El resultado no debe depender únicamente del poder numérico: estrategia, preparación, terreno, información, suministros, estado del titán, composición del equipo, apoyo aliado y protección de civiles también deben importar.

## 9. Derrotas, riesgos y consecuencias

**No todas las batallas se pueden ganar.** La victoria no está garantizada aunque el jugador tenga un titán poderoso.

- Las misiones pueden terminar en victoria, derrota, retirada o cumplimiento parcial de objetivos.
- Una mala preparación, falta de suministros, daños previos, decisiones tácticas o falta de apoyo pueden provocar una derrota.
- Los enemigos deben representar amenazas reales y no ser siempre derrotados automáticamente.
- Perder puede causar daños al titán, gastos de reparación, pérdida o daño de instalaciones, retroceso territorial, evacuaciones o cambios en la confianza de los aliados.
- Las consecuencias deben ser claras, coherentes y equilibradas; evitar castigos arbitrarios que bloqueen permanentemente la partida.
- Puede haber rescate, recuperación, reconstrucción y nuevas oportunidades para recuperar territorio.
- Los objetivos secundarios y la protección de habitantes pueden importar incluso si no se derrota al kaiju.
- La dificultad y las consecuencias deben permitir aprender de los errores y volver a organizar la defensa.

## 10. Alianzas internacionales y diplomacia

- Países, regiones y organizaciones de defensa con intereses y capacidades propias.
- Relaciones, reputación, confianza y acuerdos entre aliados.
- Solicitudes de ayuda y operaciones conjuntas.
- Cooperación en recursos, investigación, tecnología, instalaciones y defensa.
- Refuerzos y despliegue de titanes aliados cuando las reglas de la campaña lo permitan.
- Decisiones que fortalezcan o debiliten relaciones diplomáticas.
- Las alianzas no deben ser decoración: deben afectar las opciones estratégicas y la capacidad de responder a amenazas.

## 11. Chat global y comunicación

- Un chat global para que los jugadores puedan comunicarse en el mundo compartido, si el juego incluye multijugador/conectividad en línea.
- Canales previstos: global, alianza/equipo y, si hace falta, mensajes del sistema.
- Identidad visible del jugador y mensajes legibles.
- Herramientas de seguridad: silenciar, bloquear, denunciar y moderación contra spam y abuso.
- No mostrar información privada de los jugadores.
- Si el juego todavía no tiene servidores o multijugador, diseñar primero la interfaz y la arquitectura como sistema futuro; no presentar un chat local como chat global en línea.

## 12. Campaña, misiones y mundo dinámico

- Campaña con historia, objetivos principales y secundarios.
- Misiones de defensa, escolta, rescate, reconocimiento, recuperación y combate.
- Amenazas en distintas regiones y eventos que puedan ocurrir simultáneamente.
- Solicitudes de ayuda de ciudades y aliados.
- Consecuencias persistentes de las decisiones y resultados de misiones.
- Progresión que conecte la gestión de la base con las operaciones de campo.

## 13. Guardado, perfil y progresión

- Guardar recursos, inventario, compras, mejoras, titanes, edificios, misiones, relaciones y estado del mundo.
- Guardar los resultados y consecuencias de las batallas.
- Evitar duplicar recompensas o compras al repetir una operación o cargar una partida.
- Recuperación segura ante datos dañados y pruebas de regresión.
- La información del jugador debe mantenerse consistente entre sesiones.

## 14. Audio, presentación y accesibilidad

- Modelos 3D propios para titanes, kaijus, NPC, edificios y escenarios.
- Animaciones, cámaras, efectos visuales, iluminación y entornos legibles.
- Interfaz clara para hangar, economía, tienda, investigación, diplomacia, chat y combate.
- Música, ambiente y efectos de sonido.
- Controles configurables y opciones de accesibilidad razonables.

## 15. Multijugador y funciones en línea

- Determinar qué funciones serán individuales y cuáles compartidas en línea.
- Si hay multijugador, definir servidores, sincronización, persistencia y reglas contra trampas.
- Alianzas y chat global en línea requieren infraestructura de red; no se consideran implementados por existir una interfaz.
- Planificar primero una arquitectura segura y escalable antes de prometer funciones en línea.

## 16. Criterios de seguimiento

Cada característica debe tener uno de estos estados en futuras auditorías:

- **No iniciado:** no existe implementación verificable.
- **En diseño:** requisitos definidos, sin implementación funcional.
- **En desarrollo:** hay código o contenido parcial.
- **Implementado:** existe en el proyecto, pero falta validar todos los casos.
- **Probado:** se verificó en Godot con pruebas reproducibles.
- **Completo:** probado y conectado con los demás sistemas previstos.

No marcar una característica como terminada solo porque exista un archivo, una escena de muestra, un botón o una descripción. Verificar su comportamiento real y su persistencia cuando corresponda.

## 17. Principio central

La experiencia debe representar la defensa y supervivencia de la humanidad. El jugador no solo controla un Jaeger: administra recursos limitados, desarrolla tecnología, cuida a la población, construye y protege bases, coopera con aliados y acepta que algunas batallas se pueden perder. Las decisiones estratégicas y sus consecuencias son parte esencial del juego.

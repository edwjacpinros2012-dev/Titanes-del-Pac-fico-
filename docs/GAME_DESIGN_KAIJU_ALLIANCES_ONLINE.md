# Titanes del Pacífico — Diseño de Kaijus, guerra y comunidad online

## Identidad central
La criatura es siempre un **Kaiju enemigo**: un monstruo colosal que emerge de brechas oceánicas, amenaza asentamientos y obliga a la humanidad a desplegar Jaegers. No es mascota, montura, compañero ni unidad controlable. La fantasía principal es pilotar Jaegers y defender a la humanidad frente a monstruos gigantes.

Inspiraciones generales, sin copiar personajes, nombres, arte, mapas ni contenido protegido:
- Pacific Rim: escala Jaeger/Kaiju, pilotos sincronizados y brechas.
- Transformers: Earth Wars: gestión de escuadrones, bases, facciones y progreso estratégico.
- Subnautica: exploración oceánica, biomas, recursos y descubrimiento.
- No Man's Sky: expediciones, economías y regiones.
- Grounded: ecosistemas y criaturas con hábitats distintos.

## Bucle principal
1. Recibir alerta de brecha o amenaza regional.
2. Preparar Jaeger, pilotos, módulos y suministros.
3. Explorar o desplegarse en una zona.
4. Defender, evacuar, investigar, contener o repeler al Kaiju.
5. Resolver el resultado: victoria, retirada, derrota parcial o pérdida de objetivo.
6. Recuperar recursos, reparar daños y mejorar la base.
7. Investigar nuevas generaciones Mark y preparar la siguiente amenaza.

Las victorias no están garantizadas. Una derrota puede provocar daños, pérdida de suministros, interrupción de instalaciones o presión sobre un territorio. Debe existir recuperación jugable; no borrar permanentemente el progreso principal por una derrota aislada.

## Inicio de campaña
- Cuenta nueva: piloto recluta.
- Primer Jaeger: Mark I básico, estadísticas modestas y módulos limitados.
- Base inicial: hangar pequeño, centro de mando, generador y taller.
- Primer enemigo: Kaiju de amenaza baja presentado en una misión tutorial.
- La dificultad escala por capítulos, regiones desbloqueadas, preparación del jugador y nivel de amenaza mundial; no solo por inflar la salud enemiga.
- Mark II, III y posteriores se desbloquean mediante investigación, componentes, planos y objetivos de campaña.

## Kaijus: catálogo enemigo
Todas las especies del catálogo existente se tratan como fauna hostil/neutral y amenazas Kaiju, no como aliados. El roster `data/kaiju/kaiju_roster.json` define función, hábitat, nivel de amenaza y señales previas al encuentro.

Arquetipos: explorador, acorazado, abisal, Alfa y colosal. Cada Kaiju tiene patrones de aparición, resistencia, movilidad, atributos de juego abstractos y recompensas de investigación. Los datos desbloquean mejoras de Jaeger y preparación de encuentros.

## Jaegers y escuadrones
- El jugador pilota un Jaeger activo.
- Puede desbloquear y mantener varios Jaegers en hangares.
- Escuadrones de apoyo se gestionan desde un mapa táctico simplificado.
- Cada Jaeger tiene generación Mark, clase, chasis, módulos, integridad, energía y ranuras de mejora.
- Los pilotos tienen sincronía, experiencia y especializaciones ficticias.
- Los módulos se consiguen por fabricación, investigación, contratos y exploración.

## Base y economía
Instalaciones: hangar, taller, laboratorio Kaiju, centro de pilotos, refinería, generador, almacén, radar oceánico, puerto de reconocimiento y centro de alianzas. Cada edificio tiene niveles, costes, energía y requisitos tecnológicos.

Recursos: metal, energía, cristal, componentes, datos de investigación y créditos. El mercado tiene existencias y precios variables. El comercio entre jugadores/alianzas debe validarse en servidor, nunca con valores decididos por el cliente.

## Mundo y guerra persistente
- Mapa global por sectores oceánicos, islas, costas y ciudades ficticias.
- Cada sector tiene amenaza, estabilidad, recursos, instalaciones y control.
- Eventos: brechas, migraciones Kaiju, evacuaciones, tormentas y jefes regionales.
- El mundo puede avanzar desconectado, pero las pérdidas offline deben tener límites y avisos; nunca destruir toda la base sin oportunidad razonable de respuesta.
- Las campañas entre alianzas son objetivos y puntuaciones cooperativas.

## Alianzas de jugadores
Cada jugador puede crear una alianza, buscar alianzas públicas, solicitar unirse, aceptar invitaciones, salir y participar en objetivos cooperativos.

Roles: líder, oficial y miembro. Permisos:
- Líder: administrar alianza, ascender oficiales, aceptar solicitudes y transferir liderazgo.
- Oficial: aceptar solicitudes, organizar eventos y gestionar anuncios.
- Miembro: participar en misiones, contribuir recursos y votar propuestas.

Funciones: nombre, etiqueta, emblema original, descripción, miembros, registro de actividad, almacén cooperativo con límites, objetivos compartidos y clasificación. Toda transferencia debe confirmarse en servidor y quedar registrada.

## Cuentas y perfiles
Flujo: registro seguro, verificación, creación de nombre público único, inicio/cierre de sesión, recuperación de acceso y guardado validado por servidor. La autenticación se delega a un proveedor como Supabase Auth. No almacenar contraseñas propias ni secretos en Godot. No pedir dirección, teléfono ni datos reales para jugar.

## Chat global y seguridad
- Sin mensajes privados entre desconocidos en la primera versión.
- Texto solamente; sin voz en el lanzamiento inicial.
- Chat global desactivado por defecto hasta tener moderación y controles probados.
- Mensajes cortos, límites de frecuencia y filtros contra spam, acoso, datos personales, enlaces y contenido inadecuado.
- Canales por idioma y avisos oficiales separados.
- Silenciar, bloquear y denunciar accesibles desde mensajes y perfiles.
- Revisión de denuncias, sanciones temporales y apelación.
- Los bloqueados no pueden contactar ni mencionar a quien los bloqueó.
- No mostrar correo, identificadores de autenticación ni datos privados.
- Para una comunidad con menores, priorizar mensajes predefinidos y canales moderados; no habilitar chat libre sin moderación y controles de privacidad probados.

## Arquitectura online recomendada
- Godot 4: cliente 3D e interfaz.
- Supabase Auth: registro e inicio de sesión.
- PostgreSQL + Row Level Security: perfiles, alianzas, membresías, chat, bloqueos y denuncias.
- Supabase Realtime: presencia y actualización de canales con autorización por canal.
- Funciones de servidor: moderación, invitaciones, transacciones, recompensas, sanciones y validación.
- Servidor autoritativo para combates y progreso competitivo: el cliente envía intenciones; el servidor calcula resultados y recompensas.

El esquema inicial está en `backend/supabase/migrations/0001_community_schema.sql`. Es una base de datos inicial, no un servicio desplegado. Requiere crear un proyecto backend, aplicar migraciones, configurar funciones y conectar el cliente con claves públicas. Nunca incluir claves secretas de servidor en Godot ni en el repositorio.

## Etapas online
1. Esquema y diseño.
2. Configurar Auth, verificación y RLS.
3. Integrar registro/inicio/cierre de sesión.
4. Integrar perfiles y guardado en nube.
5. Integrar creación/búsqueda/solicitud de alianzas.
6. Integrar chat limitado con moderación, bloqueo y denuncias.
7. Servicios autoritativos para campañas, comercio y recompensas.
8. Pruebas de seguridad, privacidad, abuso, reconexión y carga.

## Lo que NO está terminado
El proyecto sigue siendo un prototipo local de Godot. No hay todavía cuentas reales, chat conectado, alianzas online, servidores persistentes ni multijugador probado. El SQL y esta especificación preparan la arquitectura; no simulan una conexión real. La integración requiere un backend creado por el propietario y pruebas locales.

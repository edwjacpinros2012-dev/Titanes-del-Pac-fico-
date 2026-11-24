# Arquitectura de servidores y chat global

## Estado verificado
- El panel actual de Alianza es una demostración local; el nombre se conserva solo en memoria de la página.
- No se encontró una migración Supabase ni un proyecto backend configurado en la rama de trabajo consultada.
- No hay autenticación online, base de datos desplegada, chat global real, matchmaking, salas ni servidor autoritativo de partidas verificados.
- Vercel sirve la web; por sí solo no convierte el juego en multijugador ni mantiene sesiones de juego autoritativas.
- El cliente no debe declarar usuarios conectados si no recibe presencia real del servicio.

## Arquitectura propuesta
1. **Identidad:** Supabase Auth con sesión segura; perfiles públicos separados de credenciales.
2. **Datos persistentes:** PostgreSQL para perfiles, alianzas, membresías, mensajes, bloqueos, reportes y progreso sincronizado.
3. **Chat:** Supabase Realtime para entregar mensajes y presencia por canales autorizados.
4. **Reglas de seguridad:** RLS en todas las tablas; usuarios solo pueden leer canales permitidos, crear mensajes como ellos mismos y bloquear/reportar cuentas.
5. **Funciones servidor:** Edge Functions para creación/gestión de alianzas, validación de invitaciones, límites anti-spam y moderación.
6. **Partidas online futuras:** servidor autoritativo separado del chat. El cliente nunca decide resultados, recursos o recompensas de partidas multijugador.
7. **Hosting:** Vercel mantiene el frontend; Supabase aloja Auth/Postgres/Realtime/Functions. Un servidor de partidas dedicado se añade solo cuando el prototipo y el presupuesto lo justifiquen.

## Modelo de datos inicial
- `profiles`: id Auth, nombre visible, avatar permitido, fecha de creación y estado de seguridad.
- `alliances`: id, nombre, creador, descripción, región y fecha.
- `alliance_members`: alianza, usuario, rol y fecha de ingreso.
- `chat_messages`: id, canal, autor, texto limitado, fecha y estado de moderación.
- `user_blocks`: usuario que bloquea y usuario bloqueado.
- `message_reports`: reportante, mensaje/usuario, motivo y estado de revisión.
- `moderation_actions`: acción, alcance, motivo, moderador y auditoría.
- `game_profiles`: progreso en nube validado por funciones de servidor; nunca aceptar saldo/recompensas arbitrarios del navegador.

## Seguridad y bienestar (requisito de lanzamiento)
- Chat global inicialmente desactivado hasta probar autenticación, RLS, reportes, bloqueo, límites de frecuencia y herramientas de moderación.
- No permitir mensajes privados entre desconocidos en el primer lanzamiento.
- Longitud máxima, filtros anti-spam, enfriamiento de envío y protección frente a enlaces abusivos.
- Reportar y bloquear accesibles desde cada mensaje; flujo de revisión y registro de decisiones.
- Minimizar datos personales; no pedir ubicación, teléfono, escuela ni datos sensibles en el perfil.
- Reglas claras de comunidad y un responsable adulto/operativo para revisar reportes.
- No publicar claves service-role en Vite, navegador, GitHub ni variables `VITE_*`. Solo la clave pública anon puede estar en el cliente, siempre protegida por RLS.

## Secuencia de implementación
1. Conectar el proyecto Supabase correcto y confirmar quién administra el proyecto.
2. Crear y revisar migraciones SQL; habilitar RLS y políticas con pruebas negativas.
3. Configurar Auth y perfiles mínimos.
4. Crear Edge Functions para alianzas, membresías, reportes y moderación.
5. Conectar Realtime a un canal global y canales de alianza con autorización.
6. Crear UI de chat con estados: desconectado, conectando, conectado, enviando, error, bloqueado y moderación.
7. Probar dos cuentas de prueba y verificar que no se puedan leer/escribir canales ajenos.
8. Habilitar chat gradualmente solo tras revisión de seguridad y moderación.
9. Diseñar el servidor autoritativo de partidas como proyecto independiente; no mezclarlo con el chat.

## Bloqueo actual
La conexión de Supabase todavía no está autorizada desde esta conversación. Se ha ofrecido conectar el servicio; hasta que la conexión se confirme no se pueden crear tablas ni desplegar funciones en una cuenta real. No se crean servidores ficticios ni se inventan URL, claves o jugadores.

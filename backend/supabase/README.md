# Backend online — preparación

Este directorio contiene el esquema inicial para una futura versión online. **No hay backend conectado todavía.**

## Componentes previstos
- Supabase Auth para registro, inicio de sesión, verificación y recuperación.
- PostgreSQL con Row Level Security para perfiles y alianzas.
- Realtime para canales autorizados.
- Funciones de servidor para crear alianzas, aprobar solicitudes, moderar mensajes, gestionar reportes y validar recompensas.

## Preparación
1. Crear un proyecto Supabase propio.
2. Revisar la documentación oficial de Auth, RLS y Realtime.
3. Aplicar `migrations/0001_community_schema.sql` en un entorno de prueba.
4. Revisar y probar todas las políticas con dos cuentas de prueba y roles distintos.
5. Crear funciones de servidor para altas/bajas de alianzas, invitaciones y moderación.
6. Configurar límites de frecuencia, filtros, bloqueo, denuncias, sanciones y apelación.
7. Conectar Godot usando únicamente la URL del proyecto y la clave pública de cliente.
8. Mantener la clave `service_role` y cualquier secreto exclusivamente en el servidor. Nunca subirlos al repositorio ni incluirlos en el cliente.

## Reglas antes de abrir el chat
- `global_chat_enabled` comienza en `false`.
- El cliente no puede activar su propio permiso de chat.
- Los mensajes se insertan como `pending`; solo un proceso de moderación de confianza puede publicarlos.
- No habilitar mensajes privados ni voz en la primera versión.
- Probar bloquear, denunciar, sancionar y apelar antes de abrir canales a jugadores.
- Mantener el chat desactivado si no hay moderación operativa y revisión de reportes.

## Estado
El SQL es un punto de partida que debe pasar revisión y pruebas de seguridad. Todavía no incluye las funciones de servidor ni la conexión desde Godot. No introduzcas credenciales reales en archivos del repositorio ni las compartas en conversaciones.

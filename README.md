# Titanes del Pacífico

Videojuego web 3D en desarrollo con **Vite, TypeScript, Phaser y Three.js**. El repositorio contiene un prototipo jugable y sistemas locales en evolución; no es un proyecto Godot.

## Ejecutar en desarrollo
1. Instala Node.js 22 o una versión compatible.
2. Clona el repositorio.
3. Ejecuta `npm install`.
4. Ejecuta `npm run dev`.
5. Abre la URL local que muestre Vite.

## Compilar
- `npm run typecheck`: comprobación TypeScript.
- `npm run build`: TypeScript + compilación Vite.
- `npm run preview`: vista previa local de la compilación.

## Sistemas presentes en el prototipo
- Escena 3D en Three.js con Jaeger y Kaiju procedurales.
- Menú de despliegue, combate local y HUD provisional.
- Tres Jaegers de catálogo con roles y estadísticas.
- Catálogo de cinco categorías Kaiju; no todos son enemigos activos.
- Base, recursos, mejoras, instalaciones y defensa urbana con guardado local.
- Campaña inicial: solo la misión 1 está conectada al combate jugable.
- Tienda, tecnologías y progreso local.
- Panel de alianza demostrativo, sin multijugador online.

## Estado online
No hay actualmente un chat global operativo, autenticación conectada, matchmaking ni servidor autoritativo de partidas verificados. Vercel aloja el frontend, no la lógica multijugador. La arquitectura prevista para chat y servicios online está en `docs/ONLINE_SERVERS_AND_GLOBAL_CHAT.md`.

## Estado visual
Los Jaegers, Kaijus y entorno usan geometría procedural/provisional. No deben describirse como modelos GLB finales ni como animaciones profesionales. La dirección artística y el contrato de producción están en `docs/VISUAL_PRODUCTION_MASTER_PLAN.md`.

## Próximos hitos
1. Completar el loop jugable y las misiones restantes.
2. Sustituir/progresar los modelos procedurales por GLB/GLTF optimizados, rigs, animaciones y materiales PBR.
3. Conectar Auth, base de datos, Realtime y funciones de servidor para el chat/alianzas.
4. Implementar servidor autoritativo de partidas si el diseño multijugador lo requiere.
5. Probar en navegadores/dispositivos y verificar despliegue de producción.

## Seguridad
No subir claves privadas, service-role keys, contraseñas ni tokens al repositorio. Nunca usar variables `VITE_*` para secretos. Para servicios online aplicar RLS y validar operaciones sensibles en servidor.

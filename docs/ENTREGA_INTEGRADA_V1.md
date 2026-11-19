# Entrega integrada v1 — Pacific Rim: Titanes

## Qué incluye esta entrega
Esta rama reúne la base Godot existente, la renovación visual v1 y el cierre del registro local de piloto.

### Registro y perfil
- Perfil local por dispositivo con ID propio.
- Nombre de piloto validado (3–20 caracteres).
- Crear/volver a entrar con el mismo nombre en el dispositivo.
- Migración de esquema a versión 3.
- Escritura temporal y copia de recuperación.
- Recuperación desde backup cuando el JSON principal no se puede leer.
- Pantalla de piloto y ajustes adaptada al ancho de pantalla.
- El botón de Google informa que el proveedor aún no está conectado; no simula autenticación.

### Mundo y presentación
- Isla costera, mar, pista iluminada, cielo procedural e iluminación.
- Base modular con hangar, torres, radares, antenas y plataformas.
- Titán Alfa con piezas de armadura y núcleo luminoso.
- Kaiju Brineback provisional visible en el escenario.
- HUD más compacto que la versión anterior.

### Sistemas de juego que ya están presentes en código
- Recursos, recolección, inventario y fabricación.
- Base, instalaciones, producción y mejoras.
- Investigación y evolución.
- NPC, población y solicitudes.
- Expediciones, misiones, contratos y eventos regionales.
- Mercado de créditos ficticios.
- Encuentros Kaiju resueltos por simulación estadística.
- Daño y reparación simplificados.
- Campaña y progresión inicial.
- Alianzas locales de demostración.
- Guardado local de progreso y ajustes.

## Estado real y porcentaje
No existe una métrica automática que convierta cantidad de scripts en porcentaje de juego terminado. Para evitar inflar el avance:

- **Aproximadamente 25% de producto final validado:** estimación conservadora de lo que ya cumple criterios de experiencia jugable y validación real, no porcentaje de líneas de código.
- **Sistemas de prototipo:** varios módulos existen y están conectados parcialmente, pero requieren pruebas de extremo a extremo.
- **Combate 3D real:** pendiente; el encuentro actual es una resolución estadística.
- **Google OAuth y nube:** no conectados.
- **Multijugador real:** no implementado.
- **Modelos y animaciones profesionales:** pendientes; la geometría de esta rama es provisional.
- **APK instalable verificada:** no generada en esta entrega.
- **Prueba en Android físico:** pendiente.

## Criterios de aceptación antes de llamar completo
1. Importar el proyecto en la versión de Godot indicada por project.godot.
2. Ejecutar workflow Godot en GitHub Actions y resolver cualquier error.
3. Abrir escena principal y confirmar entorno, base, Titán y Kaiju.
4. Crear perfil local, cerrar el juego, volver a abrir y confirmar que se conserva.
5. Forzar una copia de recuperación en prueba y comprobar restauración.
6. Probar movimiento, recolección, mejoras, misiones, encuentros y reparación.
7. Probar controles y legibilidad en un Android real.
8. Exportar APK con plantillas y SDK compatibles, instalar y volver a probar.

## Límites de autenticación
El perfil local no es una cuenta online: no tiene recuperación remota ni sincronización entre dispositivos. Google Sign-In requiere OAuth configurado, un proveedor compatible, backend que valide tokens y pruebas de seguridad. No guardar contraseñas, secretos de servidor ni claves privadas en el cliente.

## Cómo abrir
1. Descargar el ZIP de la rama feat/complete-registration-and-game-foundation-v1.
2. Extraerlo en una carpeta nueva.
3. En Godot, seleccionar Importar y elegir project.godot.
4. Ejecutar el proyecto.
5. Abrir Piloto / Ajustes y crear el perfil local.

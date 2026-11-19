# Flujo de trabajo desde un teléfono Android

## Objetivo

Usar el teléfono para abrir, ejecutar y revisar el proyecto Godot. El teléfono no sustituye una validación de exportación en hardware ni garantiza que todas las tareas de edición sean cómodas.

## Preparación

1. Instala **Godot Engine Editor** para Android desde la fuente oficial de Godot.
2. Descarga el repositorio como ZIP desde GitHub:
   https://github.com/edwjacpinros2012-dev/Titanes-del-Pac-fico-/archive/refs/heads/main.zip
3. Extrae el ZIP en una carpeta accesible del almacenamiento del teléfono.
4. Abre Godot Editor, concede acceso a la carpeta del proyecto e importa el archivo `project.godot`.
5. Espera a que termine la importación de recursos y shaders. La primera apertura puede tardar.
6. Ejecuta la escena principal desde el editor.

## Controles táctiles ya preparados

El proyecto contiene `scripts/platform/platform_input.gd`, que genera controles en pantalla cuando detecta un dispositivo táctil:
- Cruceta para mover el Titán.
- Botones de acción para recoger, combatir, retirarse, evolucionar, reparar, investigar, abrir el mercado y gestionar expediciones.

Si no aparecen, revisa que la escena principal instancie el nodo `PlatformInput` y que sus acciones estén conectadas al controlador principal. No se debe dar por validado el control táctil hasta probar cada botón dentro del juego.

## Qué revisar en el teléfono

- La escena principal abre sin errores.
- El Titán aparece y se mueve con la cruceta.
- Los botones de acción no se pisan con los bordes o el HUD.
- El texto se lee en pantalla pequeña y en orientación horizontal.
- Recoger recursos actualiza inventario y misión.
- Guardar, cerrar y volver a abrir conserva el progreso.
- No hay cierres inesperados ni calentamiento excesivo durante una sesión corta.

## Límites importantes

- La edición de GDScript en una pantalla táctil es posible, pero un teclado físico Bluetooth facilita mucho el trabajo.
- No se debe asumir que una exportación APK desde el propio teléfono está lista. Para distribuir una APK/AAB hay que configurar plantillas de exportación, Android SDK/JDK y firma; después instalar y probar el artefacto resultante.
- Nunca guardes contraseñas, claves privadas, keystores ni secretos en el repositorio.
- El backend, el inicio de sesión real y el multijugador no quedan habilitados por importar el proyecto.

## Validación

La validación automatizada se ejecuta en GitHub Actions después de enviar cambios. La prueba manual en el teléfono sigue siendo necesaria para confirmar controles, resolución, rendimiento y guardado.

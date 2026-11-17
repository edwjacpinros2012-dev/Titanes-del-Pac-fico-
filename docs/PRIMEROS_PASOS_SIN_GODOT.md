# Primeros pasos: preparar el proyecto sin tener Godot instalado

**Objetivo:** dejar el proyecto listo en Windows y abrirlo cuando Godot esté instalado.  
**Versión de editor fijada para este repositorio:** Godot 4.3 estable, edición Standard (no .NET).  
**Sistema:** Windows 10/11 de 64 bits recomendado.

## 1. Qué necesitas ahora

- Una computadora Windows.
- Conexión a Internet para descargar el editor y el proyecto.
- Espacio libre. Reserva al menos 2 GB para el editor, el proyecto, caché y plantillas; más espacio será necesario si luego preparas Android.
- No necesitas Android Studio ni Java para abrir y probar inicialmente el juego en Windows.
- No ejecutes scripts como administrador.

Godot es portable: en Windows se descarga un ZIP, se extrae y se ejecuta; no necesita un instalador tradicional.

## 2. Descargar Godot correcto

1. Abre el archivo oficial de Godot 4.3: https://godotengine.org/download/archive/4.3-stable/
2. En Windows, elige **Windows x86_64 – Standard**. No elijas .NET porque el proyecto está escrito en GDScript.
3. Descarga también **Export templates – Standard** solo cuando vayamos a exportar. Para abrir el proyecto por primera vez no hace falta instalarlas.
4. Extrae el ZIP del editor, por ejemplo, en `C:\Godot43\`.
5. Ejecuta el archivo `Godot_v4.3-stable_win64.exe` (el nombre puede variar ligeramente).
6. No uses versiones beta ni una versión distinta para la primera validación. El repositorio y su CI están configurados para Godot 4.3.

Descargas oficiales y documentación:
- Archivo oficial 4.3: https://godotengine.org/download/archive/4.3-stable/
- Requisitos del editor 4.3: https://docs.godotengine.org/en/4.3/about/system_requirements.html
- Exportación Android 4.3: https://docs.godotengine.org/en/4.3/tutorials/export/exporting_for_android.html

## 3. Obtener el proyecto

### Método sencillo (sin Git)
1. Abre el repositorio: https://github.com/edwjacpinros2012-dev/Titanes-del-Pac-fico-
2. Pulsa **Code → Download ZIP**.
3. Extrae la carpeta en Documentos, con un nombre sencillo, por ejemplo:
   `C:\Users\TU_USUARIO\Documents\titanes-del-pacifico\`
4. Dentro de esa carpeta debe estar `project.godot`. Si está dentro de una subcarpeta, abre esa subcarpeta en Godot.

### Método con Git
Si Git ya está instalado, abre PowerShell y ejecuta:

```powershell
cd "$env:USERPROFILE\Documents"
git clone https://github.com/edwjacpinros2012-dev/Titanes-del-Pac-fico-.git titan es-del-pacifico
```

Si PowerShell informa que Git no existe, utiliza el método Download ZIP. No necesitas instalar Git para empezar.

## 4. Abrir el proyecto

1. Abre Godot 4.3.
2. En el Project Manager, pulsa **Import**.
3. Selecciona el archivo `project.godot` dentro de la carpeta del juego.
4. Espera a que termine la importación de recursos.
5. Selecciona el proyecto y pulsa **Run (F6/F5 según la vista)** o el botón Play del editor.
6. Si aparece un error, toma una captura donde se vea el mensaje completo y compártela. No borres archivos para intentar arreglarlo sin revisar el error.

## 5. Script de preparación incluido

En `tools/preparar_proyecto_windows.ps1` hay un asistente que:
- comprueba si Git está disponible;
- obtiene el repositorio en Documentos sin sobrescribir una carpeta existente;
- si encuentra un clon Git existente, intenta actualizarlo;
- busca Godot 4.3 en PATH y en ubicaciones habituales;
- si Godot no está instalado, deja el proyecto descargado y te indica cómo abrirlo después;
- si lo encuentra, ofrece abrir el proyecto.

Para ejecutarlo, abre PowerShell normal (no administrador), navega a la carpeta donde descargaste el ZIP y ejecuta:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\preparar_proyecto_windows.ps1
```

Si descargaste el ZIP y no puedes ejecutar el script, no pasa nada: sigue los pasos manuales de las secciones 2–4.

## 6. Qué NO instalar todavía

No instales aún Android Studio, SDK, NDK, Java ni plugins de Google Play. Primero necesitamos:
1. abrir el proyecto en Godot 4.3;
2. importar recursos sin errores;
3. ejecutar la escena principal;
4. resolver errores visibles;
5. comprobar controles, guardado y rendimiento en PC.

Cuando el juego base esté validado, prepararemos el entorno Android. La guía oficial 4.3 requiere configurar OpenJDK 17, Android SDK y las plantillas de exportación coincidentes con Godot 4.3. No se debe mezclar una plantilla de otra versión.

## 7. Qué haremos en la primera sesión con Godot

- Importar el proyecto.
- Ejecutar la escena principal.
- Revisar la pestaña Output y Debugger.
- Comprobar movimiento, cámara, HUD e interacción.
- Probar recolección y guardado/carga.
- Registrar cada error y corregirlo antes de exportar.
- Después iniciar la primera misión vertical con combate 3D real.

## 8. Seguridad y copias

- No compartas contraseñas, tokens, claves privadas ni archivos de firma.
- No subas `.env`, keystores ni credenciales al repositorio.
- Conserva una copia del proyecto antes de actualizarlo manualmente.
- No descargues ejecutables de páginas no oficiales.
- No ejecutes PowerShell como administrador para este procedimiento.

## Estado actual

Este documento y el script preparan el entorno. **No instalan Godot en tu computadora**, porque no tengo acceso directo a tu PC. Tampoco crean una APK. La instalación y primera ejecución quedan pendientes hasta que descargues el editor y abras el proyecto.

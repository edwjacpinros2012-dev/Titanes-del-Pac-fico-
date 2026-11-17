# Destinos de compilación y dispositivos

| Destino | Dispositivos | Salida prevista | Estado |
|---|---|---|---|
| Android | Teléfonos y tabletas Android ARM | APK de depuración | Preset y scripts preparados; exportación real pendiente |
| Web | Navegadores con WebAssembly y WebGL 2.0 | `build/web/index.html` | Preset preparado; prueba de navegador pendiente |
| Windows | PC Windows 64 bits | EXE | Preset preparado; prueba real pendiente |
| Linux | PC Linux 64 bits | Ejecutable x86_64 | Preset preparado; prueba real pendiente |
| macOS | Mac | App específica | Requiere preset y prueba en Mac |
| iOS/iPadOS | iPhone y iPad | Proyecto Xcode / app iOS | Requiere macOS, Xcode, firma y pruebas Apple |

Un APK no se instala en Windows, macOS, iOS ni en un navegador. Cada plataforma necesita su propia exportación.

## Comandos en Windows PowerShell

Desde la carpeta del proyecto:

```powershell
.\scripts\build_android.ps1
.\scripts\build_all.ps1
.\scripts\install_android.ps1
```

`build_all.ps1` intenta exportar Android, Web, Windows y Linux. Puedes elegir destinos:

```powershell
.\scripts\build_all.ps1 -Targets @("Web", "Windows Desktop")
```

`install_android.ps1` instala el APK existente en un dispositivo Android conectado y autorizado mediante ADB. No genera el APK por sí solo.

## Requisitos Android del proyecto Godot 4.3

- Godot 4.3 y sus plantillas de exportación coincidentes.
- OpenJDK 17.
- Android SDK configurado en los ajustes del editor.
- Android SDK Platform-Tools, Build-Tools y Platform según la guía oficial de Godot 4.3.
- Dispositivo Android compatible para pruebas.

La guía oficial de Godot 4.3 detalla versiones del SDK y rutas que deben configurarse. Consulta:
https://docs.godotengine.org/es/4.3/tutorials/export/exporting_for_android.html

## Navegadores

La exportación Web de Godot 4.3 necesita WebAssembly y WebGL 2.0. El proyecto utiliza GL Compatibility. Debe probarse servido desde un servidor web; no se considera validado solo por generar archivos.
https://docs.godotengine.org/en/4.3/tutorials/export/exporting_for_web.html

## Instalación y firma

El script de instalación está pensado para pruebas locales. Para publicar se requiere una compilación de release firmada. Las claves privadas y contraseñas deben permanecer fuera de GitHub, y la firma final debe gestionarla el adulto responsable. Google Play puede requerir AAB en vez del APK de prueba.

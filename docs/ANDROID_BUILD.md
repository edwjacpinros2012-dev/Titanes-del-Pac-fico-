# Preparar y exportar APK Android

## Objetivo

El preset **Android** genera un APK de depuración compatible con dispositivos Android ARM de 32 y 64 bits:
- `armeabi-v7a` (Android ARM de 32 bits, si el dispositivo aún lo admite).
- `arm64-v8a` (arquitectura habitual en teléfonos y tabletas actuales).

La orientación inicial es horizontal. El proyecto usa renderizador Compatibility para ampliar la compatibilidad con hardware móvil.

## Requisitos

1. Instala Godot 4.3 o posterior y sus plantillas de exportación de la misma versión.
2. Instala Android SDK y OpenJDK siguiendo la documentación oficial de exportación Android de Godot.
3. Configura las rutas de Android SDK/JDK en Editor > Editor Settings > Export > Android.
4. Abre el proyecto y confirma que aparece el preset Android en Project > Export.
5. En Windows PowerShell, desde la carpeta del proyecto, ejecuta:

```powershell
.\scripts\build_android.ps1
```

También puedes exportar manualmente:

```powershell
New-Item -ItemType Directory -Force build\android
godot --headless --path . --export-debug "Android" build\android\TitanesDelPacifico-debug.apk
```

El APK de depuración sirve para pruebas locales. No es el paquete firmado de publicación.

## Publicación segura

Para una versión de distribución se necesita un keystore de release, firma protegida y un identificador de paquete definitivo. No guardes keystores, contraseñas, tokens ni claves privadas en GitHub ni dentro del proyecto. La firma de publicación debe configurarla el adulto responsable en su equipo seguro.

Google Play suele requerir AAB para publicar aplicaciones nuevas; el APK se conserva para pruebas e instalación directa. No se configura facturación, compras integradas ni anuncios: la economía del juego sigue usando únicamente créditos ficticios.

## Límites reales

- Este APK es solo para Android: teléfonos, tabletas y otros dispositivos Android compatibles.
- Windows, Linux, macOS y navegador requieren exportaciones independientes.
- iPhone/iPad requieren exportación iOS y herramientas de Apple en macOS; un APK no se instala en iOS.
- La presencia del preset no demuestra que el APK ya se haya generado. La primera exportación requiere instalar y configurar SDK, JDK y plantillas.
- Antes de publicar hay que probar controles táctiles, proporciones de pantalla, memoria, temperatura, rendimiento, guardado y reanudación en dispositivos físicos de distintas capacidades.

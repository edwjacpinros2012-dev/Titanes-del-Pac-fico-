# Compatibilidad multiplataforma (base de proyecto)

## Plataformas objetivo

El proyecto se prepara para Windows, Linux y macOS con teclado y mando; Android y tabletas con pantalla táctil; y navegadores mediante exportación Web. iOS es una exportación independiente que requiere macOS y herramientas de Apple.

Esto define objetivos de compatibilidad, no significa que existan exportaciones o pruebas aprobadas para cada plataforma.

## Controles

- Teclado: WASD/flechas y acciones existentes.
- Mando: stick izquierdo para movimiento; botones frontales para recoger, evolucionar, iniciar combate y retirarse.
- Pantalla táctil: cruceta virtual y botones de acción creados por `PlatformInput`.

El panel de cuenta online se oculta en pantallas táctiles mientras la interfaz online no esté terminada. No se presenta como funcional sin backend.

## Ajustes

Se conserva Godot 4 y GL Compatibility para ampliar compatibilidad con dispositivos modestos y navegadores. En Android se usa orientación horizontal. La calidad visual final, sombras, resolución y límites de rendimiento se ajustarán después de medir dispositivos reales.

## Exportación Android

El repositorio incluye `export_presets.cfg` con un preset Android para ARMv7 y ARM64, y `scripts/build_android.ps1` para preparar un APK de depuración en Windows. Consulta `docs/ANDROID_BUILD.md` para instalar plantillas, configurar SDK/JDK y exportar.

No se incluyen claves de publicación, keystores, SDKs ni credenciales. El APK de depuración no equivale a un AAB firmado y listo para Google Play.

## Validación

La importación y ejecución breve de la escena principal pasan en GitHub Actions con Godot 4.3. Eso valida la estructura básica del proyecto, pero no sustituye las pruebas en teléfonos/tabletas reales ni confirma una exportación Android.

Pendiente: probar diferentes resoluciones y densidades, táctil simultáneo, mandos Bluetooth, suspensión/reanudación, guardado, rendimiento y consumo térmico en hardware real. Windows/Linux/macOS/Web/iOS necesitan sus propios presets y pruebas.

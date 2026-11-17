# Compatibilidad multiplataforma (base de proyecto)

## Plataformas objetivo

El proyecto se prepara para Windows, Linux y macOS con teclado y mando; Android y tabletas con pantalla táctil; y navegadores mediante exportación Web.

Esto define objetivos de compatibilidad, no significa que existan exportaciones o pruebas aprobadas para cada plataforma.

## Controles

- Teclado: WASD/flechas y acciones existentes.
- Mando: stick izquierdo para movimiento; botones frontales para recoger, evolucionar, iniciar combate y retirarse.
- Pantalla táctil: cruceta virtual y botones de acción creados por `PlatformInput`.

El panel de cuenta online se oculta en pantallas táctiles mientras la interfaz online no esté terminada. No se presenta como funcional sin backend.

## Ajustes

Se conserva Godot 4 y GL Compatibility para ampliar compatibilidad con dispositivos modestos y navegadores. En Android se usa orientación horizontal. La calidad visual final, sombras, resolución y límites de rendimiento se ajustarán después de medir dispositivos reales.

## Exportación

No se incluyen claves, keystores, SDKs ni identificadores inventados. Antes de exportar:
1. Instalar las plantillas de exportación de la misma versión de Godot.
2. Configurar Android SDK/JDK y un identificador de paquete definitivo.
3. Configurar firma de release en un equipo del adulto responsable.
4. Crear presets desde Project > Export para Windows/Linux/macOS, Android y Web.
5. Exportar builds de prueba y revisarlas en dispositivo/navegador real.

## Validación pendiente

No se ha ejecutado Godot en el entorno que actualizó estos archivos. Debe abrirse el proyecto con Godot 4.3 o posterior, ejecutar la escena principal, revisar errores de importación y probar teclado, mando, táctil, guardado y rendimiento. No se debe afirmar compatibilidad verificada hasta completar estas pruebas.

# Visual overhaul v1 — estado honesto

Esta rama mejora la escena Godot que se veía demasiado vacía en la captura de Android.

## Implementado en código
- Sustitución del suelo plano por una isla costera con mar profundo, plataforma de operaciones y pista iluminada.
- Cielo procedural con horizonte azul, iluminación direccional, sombras y brillo moderado.
- Base modular con hangar, puerta iluminada, torres, radares, plataforma de despliegue, antenas, depósito y centro energético.
- Detalles costeros, rocas y vegetación de bajo coste geométrico.
- Titán Alfa con silueta modular mejorada: placas de pecho, hombros, antebrazos, núcleo luminoso, visor y propulsores.
- Primer modelo original provisional de Kaiju Brineback, visible como punto de referencia en la costa.
- HUD superior más compacto para reducir el espacio que tapa el mundo.

## No afirmar todavía
- Los modelos siguen siendo geometría procedural/primitiva; no son modelos profesionales esculpidos ni assets PBR finales.
- No hay rig de esqueleto, animaciones de marcha/combate, VFX de combate ni audio final en esta entrega.
- El Kaiju Brineback de esta escena es una figura de exhibición; todavía no está conectado a la IA o al sistema de encuentros.
- No se ha ejecutado Godot en un dispositivo Android desde esta rama. La importación, parser, render y rendimiento deben confirmarse con CI y pruebas reales.

## Criterio de aceptación
1. Godot importa la escena sin errores.
2. La escena principal abre sin errores de script.
3. El entorno, la base, el Titán y el Kaiju aparecen en pantalla.
4. El HUD y los controles táctiles no bloquean el área principal en orientación horizontal.
5. Se valida en Android real antes de exportar APK.

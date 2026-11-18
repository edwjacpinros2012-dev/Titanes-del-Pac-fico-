# Base multiplataforma: Web → Android APK

Estado de referencia: 2026-11-18. Rama de preparación: `feat/web-to-android-foundation`.

## Objetivo

Mantener una única base de juego web (Vite + TypeScript + Phaser 3 + Three.js) y empaquetarla posteriormente para Android con Capacitor. No duplicar la lógica del juego ni modificar el proyecto Godot durante esta fase.

## Diagnóstico verificado

- El repositorio ya contiene una aplicación Vite en la raíz.
- `package.json` declara Phaser 3.90 y Three.js 0.181.
- `index.html` carga `/src/main.ts` y contiene el contenedor `#game-root`.
- `src/main.ts` contiene un prototipo jugable: escena 3D de Three.js, ciclo de juego Phaser, HUD y controles de teclado/táctiles iniciales.
- El despliegue de producción de Vercel consultado figura como READY y está enlazado al repositorio y a `main`.
- El proyecto Vercel consultado tiene SSO Protection habilitado para los despliegues que no sean dominios personalizados. Debe revisarse antes de anunciar acceso público.
- El README indica que `web/` es una página informativa, pero la aplicación jugable actual está en la raíz. Evitar configurar Vercel para publicar `web/` por error.
- La existencia de un despliegue READY no sustituye pruebas funcionales en navegadores y móviles.

## Arquitectura objetivo

```text
Vite + TypeScript
├── Phaser 3: escenas, input, HUD, estados y loop de juego
├── Three.js: mundo 3D, cámara, modelos, luces y render
├── src/platform/: adaptadores web / Android
├── src/game/: sistemas y reglas independientes de plataforma
├── public/: iconos, manifest y recursos públicos
└── Capacitor (fase posterior)
    └── Android Studio → APK de prueba → AAB de publicación
```

Regla de diseño: la lógica de combate, progreso, inventario y misiones no debe depender de APIs exclusivas del navegador. El almacenamiento, vibración, estado de red y navegación deben pasar por adaptadores de plataforma.

## Configuración Vercel

- Framework: Vite.
- Root Directory: raíz del repositorio.
- Build Command: `npm run build`.
- Output Directory: `dist`.
- Install Command: `npm install` (o el gestor que corresponda al lockfile definitivo).
- Rama de producción: `main`.
- Mantener variables secretas únicamente en Vercel; nunca incluir claves privadas en el bundle web.
- Revisar SSO Protection y probar el dominio público desde una sesión sin autenticar antes de anunciarlo.
- Mantener previews para ramas de trabajo y producción solo desde la rama estable.

## Preparación Android con Capacitor (no activada todavía)

Cuando el prototipo web supere QA:
1. Añadir versiones compatibles de `@capacitor/core`, `@capacitor/cli` y `@capacitor/android`.
2. Configurar `webDir: "dist"` y un identificador Android definitivo, único y bajo control del propietario.
3. Ejecutar el build web antes de sincronizar Capacitor.
4. Añadir la plataforma Android y abrir el proyecto en Android Studio.
5. Probar en dispositivos reales: orientación horizontal, safe areas, suspensión/reanudación, rendimiento WebGL, pérdida de red, almacenamiento y controles táctiles.
6. Generar APK debug para pruebas internas. Para distribución Google Play, preparar AAB firmado y completar los requisitos vigentes de la tienda.

No se debe añadir Capacitor ni generar APK hasta validar el juego web y decidir el identificador de aplicación. El APK no es una conversión automática de la web: es un contenedor Android que incluye la compilación web y los puentes nativos autorizados.

## QA obligatorio antes de Android

- `npm run typecheck`
- `npm run build`
- Verificar que Vercel publica `dist` desde la raíz.
- Abrir el juego en Chrome/Firefox de escritorio y Chrome Android.
- Verificar carga de Three.js, resize, orientación, FPS estable y ausencia de errores de consola.
- Verificar controles táctiles sin bloquear el desplazamiento accidental ni dejar botones pegados.
- Verificar que el juego puede pausar y reanudar al cambiar de pestaña o volver de segundo plano.
- Probar sesiones sin login; no simular OAuth real hasta configurar un proveedor y backend.
- No declarar registro Google, nube o multijugador como funcionales hasta conectar y probar los servicios reales.

## Límites y decisiones pendientes

- Confirmar que el dominio de producción es accesible públicamente y corregir SSO si el propietario lo autoriza.
- Completar pruebas de combate, daño, victoria/derrota y controles; el prototipo actual no demuestra por sí solo todos esos sistemas.
- Definir proveedor de identidad y backend antes de implementar cuentas reales.
- Crear arte optimizado y medir memoria/rendimiento en Android de gama media.
- Revisar nombre, marcas, licencias y derechos de los recursos antes de publicar.
- La publicación y la cuenta de desarrollador deben ser gestionadas por un adulto responsable si el titular es menor de edad.

## Protección del proyecto Godot

Esta rama y este documento son preparación de la ruta web/Android. No cambiar, mover ni borrar `project.godot`, escenas, scripts ni exportaciones Godot.

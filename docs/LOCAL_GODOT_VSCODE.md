# Flujo local — Godot 4.3 + Visual Studio Code

Este repositorio se desarrolla y valida localmente. Vercel y Blender no forman parte del flujo requerido.

## Requisitos

- Godot **4.3** (edición estándar, no hace falta Blender).
- Visual Studio Code.
- Extensión recomendada: **Godot Tools** (`geequlim.godot-tools`).
- Git para actualizar la rama y revisar cambios.

## Descargar y abrir

1. Descarga el ZIP de la rama `phase-2-vertical-slice` desde:
   https://github.com/edwjacpinros2012-dev/Titanes-del-Pac-fico-/archive/refs/heads/phase-2-vertical-slice.zip
2. Extrae el ZIP en una carpeta local.
3. En Godot 4.3, usa **Importar** y selecciona el `project.godot` que está en la raíz extraída.
4. En VS Code, abre **la misma carpeta raíz** (la que contiene `project.godot`, `scenes/`, `scripts/` y `tests/`).
5. Espera a que Godot termine de importar los recursos antes de ejecutar.

## Ejecutar

- En Godot: abre `project.godot` y pulsa **F6** para la escena actual o **F5** para ejecutar la escena principal definida en el proyecto.
- La escena principal configurada es `res://scenes/main.tscn`.
- En VS Code: instala Godot Tools y usa Terminal → Run Task:
  - **Godot: importar y validar proyecto**
  - **Godot: ejecutar pruebas de lógica**
  - **Godot: ejecutar escena principal**

Las tareas de VS Code esperan que el ejecutable se llame `godot` y esté en el PATH. Si Windows no lo reconoce, añade la carpeta de Godot 4.3 al PATH o cambia el campo `command` de `.vscode/tasks.json` por la ruta completa a `Godot_v4.3-stable_win64.exe`.

## Pruebas por terminal

Desde la raíz del repositorio:

```powershell
godot --headless --path . --editor --quit
godot --headless --path . --script res://tests/test_core_logic.gd
godot --path .
```

El segundo comando debe terminar con código 0 y mostrar `CORE TESTS: N passed, 0 failed`. El tercero abre la experiencia interactiva; comprueba además la pestaña Output del editor.

## Guardado local

El guardado usa archivos JSON dentro de la carpeta de usuario de Godot (`user://`), no dentro de la carpeta del repositorio. Para una prueba limpia, respalda antes los archivos de guardado; no borres una partida que quieras conservar. El guardado principal usa esquema v2 y admite lectura de esquema v1.

## Alcance y honestidad de validación

- Las pruebas automatizadas cubren lógica central, snapshots y round-trip de guardado. No sustituyen una prueba manual completa de todos los sistemas en la escena.
- Verificar manualmente controles, cambio/reinicio de escena, evolución y selección de Jaegers, recompensas, edificios, sectores, HUD, rendimiento y recuperación tras cerrar/abrir.
- La dirección artística oficial es `docs/DIRECCION_ARTISTICA_MAESTRA.md`, basada en el PDF de 19 páginas documentado en `docs/REFERENCIA_PDF_ORIGINAL.md`.
- La geometría y varios efectos siguen siendo provisionales; no describir el prototipo como arte 3D final.

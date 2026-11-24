# Arquitectura del control del mundo — TITANES DEL PACÍFICO

## Objetivo

El juego debe sentirse como un mundo persistente administrado por sistemas conectados. La interfaz solo presenta y solicita acciones; no es la autoridad que decide premios, recursos o resultados.

## Arquitectura por capas

```text
src/
  core/                 contratos, reloj, eventos y validación
  game-systems.ts       guardado local y transacciones de la partida
  world/                estado de ciudad, población y eventos
  economy/              producción, inventario, comercio y contratos
  factions/             alianzas, miembros, rangos y reputación
  npcs/                 perfiles, rutinas, diálogo y solicitudes
  missions/             director táctico y resultados
  ui/                   paneles y HUD; nunca decide recompensas
  main.ts               composición de Phaser + Three.js
data/
  buildings/            definiciones de instalaciones
  economy/              recetas, tasas y tablas de balance
  characters/           perfiles de Jaegers y NPC
  kaiju/                arquetipos y comportamiento
  missions/              objetivos y parámetros
assets/
  characters/           modelos, texturas, rigs y animaciones
  environments/         hangares, ciudades y biomas
  buildings/             módulos de base
  ui/                    iconos, marcos y mapas
backend/supabase/
  migrations/            SQL versionado
  functions/             operaciones seguras del servidor
docs/                    decisiones, pruebas y dirección de arte
```

La estructura anterior es el destino modular. No se deben crear carpetas vacías ni mover módulos existentes hasta que cada movimiento tenga una integración y una prueba.

## Autoridad y flujo de una acción

1. La UI envía una intención tipada (por ejemplo, solicitar contrato).
2. El sistema valida identidad, requisitos, cantidades y límites.
3. La transacción calcula coste y recompensa sobre una copia del estado.
4. Se persiste el estado completo o no se aplica ningún cambio.
5. Se emite un evento de dominio para actualizar HUD, NPC y paneles.
6. El registro de auditoría permite explicar qué cambió y por qué.

En modo local, el guardado del navegador es útil para prototipos, pero no es resistente a manipulación. En online, el servidor debe ser la autoridad para moneda, inventario, comercio, alianzas, resultados y recompensas.

## Sistemas de mundo

### Ciudad y población
- Integridad de distrito, nivel de alerta, evacuación y capacidad de refugios.
- Población civil representada por grupos y estados: rutina, alerta, evacuando, refugiada y retorno.
- Daño y recuperación de infraestructura expresados en valores de juego, sin recrear daño real.
- Los eventos cambian la demanda de servicios y las misiones disponibles.

### Base PPDC
- Instalaciones: mando, hangar, reactor, taller, almacén, defensa, medicina y evacuación.
- Cada edificio declara nivel, coste, tiempo de mejora, producción, consumo, capacidad y requisitos.
- La producción se acumula con límites y nunca puede reclamar dos veces el mismo intervalo.
- Si el almacén está lleno, se muestra el excedente perdido o bloqueado de forma explícita.

### Economía
- Catálogo de recursos: aleación, energía y datos de inteligencia.
- Precios definidos en datos versionados, no dispersos en botones.
- Libro de movimientos con idempotency key en backend para evitar dobles cobros.
- Comercio entre jugadores solo cuando exista servidor, límites, historial y protección anti-abuso.
- Recompensas vinculadas al resultado verificado de una misión y reclamables una sola vez.

### NPC y reputación
- Cada especialista posee ID estable, rol, ubicación, horario, reputación, diálogo y contratos.
- Rutinas por estados y ventanas de tiempo; las acciones se pausan si la base está en alerta.
- Reputación desbloquea opciones, nunca concede recursos por sí sola.
- Los contratos definen requisitos, coste, recompensa, caducidad y política de repetición.

### Alianzas
- Entidad de alianza, miembros, rangos, invitaciones, contribuciones y registro de actividad.
- Roles mínimos: líder, oficial y miembro.
- Almacén compartido y operaciones requieren permisos de servidor y límites por miembro.
- Un nombre guardado localmente no se presenta como alianza online.

### Director del mundo
- Evalúa alerta costera, integridad de ciudad, población, recursos, instalaciones y actividad del jugador.
- Selecciona eventos dentro de un catálogo permitido: mantenimiento, suministro, alerta, rescate, investigación y defensa.
- Mantiene límites de frecuencia y evita repetir eventos recientes.
- No altera directamente el guardado: propone una transición validada por el sistema de reglas.

## Contratos de datos y seguridad

- Todos los IDs son estables; los nombres visibles pueden traducirse.
- Validar números enteros, rangos, propiedad y capacidad en cada operación.
- No confiar en valores enviados desde el cliente.
- En Supabase: Auth, RLS por propietario/miembro, funciones transaccionales para operaciones críticas y logs sin secretos.
- Nunca incluir service-role keys, tokens o claves privadas en el cliente ni en variables `VITE_*`.
- Chat, mercado global y alianzas online permanecen desactivados hasta que Auth, RLS, moderación y pruebas multiusuario estén verificados.

## Orden de implementación

1. Consolidar un único contrato de guardado y migraciones probadas.
2. Separar economía, contratos y NPC de los paneles.
3. Conectar producción de edificios y límite de almacén al ciclo del juego.
4. Añadir eventos del mundo y estados de ciudad.
5. Construir alianzas y libro de comercio en backend.
6. Integrar cuentas, guardado remoto y chat moderado.
7. Añadir pruebas unitarias, integración, regresión y prueba manual de cada flujo.

## Definition of Done

Un sistema solo se marca integrado cuando tiene: flujo jugable desde UI, validaciones de límites, éxito y fallo, persistencia/restauración, protección contra doble ejecución, mensajes comprensibles y prueba automatizada o manual registrada.

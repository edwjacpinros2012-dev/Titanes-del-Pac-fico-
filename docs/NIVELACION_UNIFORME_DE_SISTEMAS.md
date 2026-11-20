# Nivelación de sistemas — estándar común de desarrollo

## Objetivo
Evitar módulos aislados, botones sin función, porcentaje inflado y sistemas desconectados. Todos los sistemas deben pasar por las mismas etapas; el nivel se limita al menor gate sin cumplir.

## Gates uniformes (aplican a todos los sistemas)
1. **G0 — Inventariado:** alcance, dependencias y responsable técnico definidos.
2. **G1 — Base:** datos/estado, validación, funciones principales, interfaces definidas.
3. **G2 — Funcional:** flujo feliz y errores implementados; sin acciones simuladas que se confundan con reales.
4. **G3 — Integrado:** conectado al ciclo principal; otros sistemas pueden leer su estado.
5. **G4 — Persistente:** guardado, carga, migración, recuperación y duplicación controlada.
6. **G5 — Verificado:** build/typecheck, pruebas unitarias, prueba manual y QA de plataforma.
7. **G6 — Presentable:** interfaz clara, feedback, accesibilidad básica y arte temporal identificado.
8. **G7 — Producción:** assets finales, rendimiento, seguridad, telemetría sin datos sensibles y release probado.

No se asigna un porcentaje a un módulo sin evidencia. Su nivel publicado es el último gate aprobado.

## Catálogo de sistemas (target de nivelación)

| ID | Sistema | G0 | G1 | G2 | G3 | G4 | G5 | G6 | G7 | P0 para nivelar |
|---|---|---|---|---|---|---|---|---|---|
| SYS-01 | Movimiento/cámara/controles | [x] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | Movimiento reproducible, límites, input móvil/PC y pausa |
| SYS-02 | Combate | [x] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | Health, ataque, cooldown, feedback, victoria/derrota/reinicio |
| SYS-03 | Jaegers | [x] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | Datos roster, selección validada, estadísticas aplicadas al gameplay |
| SYS-04 | Kaijus/IA | [x] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | Estados, target, ataque, daño, muerte, escalado |
| SYS-05 | Misiones/campaña | [x] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | Estado y objetivos verificables, misión jugable, unlock/replay |
| SYS-06 | Recompensas/XP/rango | [x] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | Reward table, pago idempotente, XP/rango/historial |
| SYS-07 | Desbloqueos | [x] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | Requisitos, estado visible y contenido desbloqueado real |
| SYS-08 | Base/instalaciones | [x] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | Coste, nivel, función real, límite y feedback visual |
| SYS-09 | Economía/recursos | [x] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | Ledger consistente, costes/recompensas, balance, anti-duplicado |
| SYS-10 | Inventario/tienda | [x] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | Comprar, consumir, equipar, límites y persistencia |
| SYS-11 | Fabricación | [x] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | Recetas, requisitos, consumo y entrega |
| SYS-12 | Reparación/mejoras | [x] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | Estado del Jaeger, coste, efectos medibles |
| SYS-13 | Exploración/regiones | [x] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | POI, descubrir, requisitos y contenido |
| SYS-14 | Rescate/NPC | [x] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | NPC/objetivo real, estado, recompensa, sin botones demo |
| SYS-15 | Eventos/contratos | [x] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | Definición, activación, objetivos, expiración y payout |
| SYS-16 | Alianzas/comunidad | [x] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | Solo local claramente marcado o backend funcional/moderación |
| SYS-17 | Guardado | [x] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | Versiones, backup, restore, datos corruptos y test |
| SYS-18 | Cuenta/online | [x] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | Auth real, servidor, permisos, offline y errores |
| SYS-19 | Audio/UX | [x] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | feedback, settings, mute, accesibilidad |
| SYS-20 | Android/Web/PC | [x] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | builds reproducibles, input, performance, test dispositivo |

**[x] en G0 significa inventario inicial; no implica que sistema esté terminado.** Los gates G1–G7 se mantienen vacíos hasta verificarlo.

## Orden de nivelación (no abrir nuevos sistemas hasta estabilizar P0)
1. SYS-01 + SYS-02 + SYS-03 + SYS-04: combate controlado, Jaeger/Kaiju y gameplay.
2. SYS-05 + SYS-06 + SYS-07: misión, victoria verificada, pago único, unlock real.
3. SYS-08 + SYS-09 + SYS-10 + SYS-11 + SYS-12: loop de base y economía.
4. SYS-13 + SYS-14 + SYS-15: mundo, rescate y eventos.
5. SYS-17 + SYS-18: persistencia y online seguro.
6. SYS-19 + SYS-20: experiencia de usuario y plataformas.

## Definition of Done común
Un sistema no se marca terminado hasta que:
- Tiene estado/datos y valida entradas.
- El flujo principal y al menos un error están implementados.
- Está conectado al juego; no es un panel independiente.
- Guarda/carga si su progreso debe persistir.
- El usuario recibe feedback de éxito/fallo.
- Se cubre por pruebas y build.
- Los placeholders se etiquetan claramente.

## Criterio de entrega
Para cada grupo nivelado, publicar commit, resultado de build/tests, lista de funciones que ya se pueden usar y lista corta de limitaciones. No llamar “completo” a una arquitectura, un panel o un catálogo.

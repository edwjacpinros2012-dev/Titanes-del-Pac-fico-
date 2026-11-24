# Director táctico y generación procedural de niveles

## Qué existe en el código
`src/mission-director.ts` contiene un director táctico local que genera un perfil reproducible para cada una de las 12 misiones:
- Selecciona un arquetipo Kaiju por operación.
- Ajusta integridad, cadencia de ataque y presión sobre la ciudad.
- Tiene en cuenta el progreso de campaña, el Jaeger elegido, las mejoras y los fallos anteriores.
- Calcula un grupo civil variable para cada despliegue.
- Genera una semilla que compone una distribución urbana procedural reproducible.
- Mantiene límites explícitos para que la dificultad no se dispare.

`src/main.ts` aplica el perfil al combate, mueve al Kaiju para perseguir al Jaeger o presionar la zona urbana y genera edificios/obstáculos con la semilla de la misión. La evacuación utiliza el número de civiles definido por el director.

## Qué significa “IA” en esta fase
Es una IA de juego basada en reglas y generación procedural determinista. No es todavía un modelo de lenguaje ni un agente remoto que escriba misiones arbitrarias. Su trabajo es dirigir la dificultad y construir variantes jugables dentro de límites definidos.

## Límites actuales
- Las 12 misiones de campaña tienen plantillas y objetivos definidos.
- La geometría urbana cambia mediante composición procedural, pero comparte el mismo escenario base.
- No existen todavía mapas artísticos únicos por misión, editor de niveles, navegación avanzada de Kaiju, sistema de cobertura/obstáculos con pathfinding ni agentes que colaboren.
- Los modelos y animaciones siguen siendo procedurales/provisionales.

## Siguiente fase para IA generativa
Para que un modelo externo cree nuevas misiones, guiones y reglas se necesita:
1. Backend seguro en Vercel o Supabase Edge Functions.
2. Un proveedor/modelo configurado mediante Vercel AI Gateway y credenciales guardadas como variables de servidor.
3. Salida estructurada validada contra un esquema de misión.
4. Simulador de pruebas que compruebe que el nivel se puede completar, que los objetivos y recompensas son válidos y que no rompe el guardado.
5. Aprobación de diseño antes de publicar una misión generada.
6. Nunca permitir que el modelo escriba directamente recursos, XP o resultados de jugadores.

La IA debe proponer contenido; el motor de juego y el servidor validan y controlan las reglas.

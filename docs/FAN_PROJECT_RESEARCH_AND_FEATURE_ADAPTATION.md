# Fan-project research & feature adaptation (2026-11-20)

## Public references reviewed
- Jaeger Project (ReyhanGTZ, itch.io): Unity prototype for PC/Android with movement, light/heavy attack, guard and skills. Treat as control-flow reference, not code/assets to import.
- Pacific Defense (tiny games, itch.io): side defense loop, touch input, difficulty progression and endless mode; reference for mission structure and escalating challenge.
- Project Orion (clee, itch.io): VR demo with hangar hub, coastal level, basic systems/AI and custom models/shaders; reference for hub-to-deployment separation.
- Pacific Rim: Breach Wars (historical game reference): roster progression, base/hangar, missions, daily goals and events; reference for long-term meta-loop.
- Jaeger Designer (historical reference): customization identity and visual wear; adapt as original cosmetics and modular parts.

## Adaptation
1. Base buildings and costs live in data/strategy/base_buildings.json.
2. Strategy helper is pure logic in scripts/systems/strategy_economy.gd; it handles affordability, costs, rewards, caps and offline production (8-hour cap).
3. Mission rewards must use unique claim IDs to prevent duplicate payouts.
4. Hangar catalogue should use classes, stats, unlocks and upgrade progression; all values remain balance placeholders.
5. Cosmetics should be original and modular: name, paint, wear, silhouette add-ons.
6. Keyboard/controller/touch must map to the same action set.
7. QA should cover save/load, spending, upgrades, duplicate rewards, storage caps and time calculations with simulated clocks.
8. Online progress and purchases must be server-authoritative; never trust client balances.

## Do not copy whole projects
The referenced games are not merged. Build new implementation from broad genre patterns. Before using third-party code, models, textures or sound, verify license, attribution requirements and compatibility. Avoid redistributing copyrighted franchise assets.

## Priority
- P0: save/load migration, safe economy and caps.
- P0: vertical slice: upgrade one building, produce/claim, deploy one unit, complete a mission, claim once.
- P1: unit selection, modular parts and research tree.
- P1: interactive base scene with building selection.
- P2: alliances, events and content expansion.

## Sources
- Jaeger Project: https://reyhangtz.itch.io/jaeger-project
- Pacific Defense: https://tiny-games345.itch.io/pacificdefense
- Project Orion: https://clee.itch.io/project-orion
- Breach Wars (historical): https://pacificrim.fandom.com/wiki/Pacific_Rim:_Breach_Wars
- Jaeger Designer (historical): https://pacificrim.fandom.com/wiki/Jaeger_Designer

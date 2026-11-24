# AI World Runtime — Titanes del Pacífico

## Current implementation

The browser game has two distinct control layers:

1. **Local tactical director** — deterministic TypeScript that works without a network connection. It adapts mission pressure to campaign progress, previous failures, Jaeger readiness and base defense.
2. **World-event director** — deterministic event selection for each mission. It adds a district, weather condition, event briefing and countermeasure, then applies bounded modifiers to city pressure, Kaiju damage and civilian evacuation load.

The world-event implementation lives in `src/world-director.ts` and is consumed by `src/mission-director.ts`. It is gameplay logic, not a remote language model.

## Authority model

The game simulation remains authoritative for all state changes:

- Validate every mission blueprint before spawning its actors.
- Clamp threat, damage, city pressure, civilian counts, rewards and resource balances.
- Never allow a text model to write XP, inventory, player saves or mission results directly.
- Use deterministic seeds for reproducible mission generation and bug reports.
- Record the event ID and seed with each completed mission so a result can be replayed.

A future generative model may propose narrative, objectives, district dressing and event combinations. The server must validate its structured output against an allowlist before the game engine can use it. If generation fails or the player is offline, the local director remains the fallback.

## Backend responsibilities

The prepared SQL foundation is in `supabase/schema.sql`. It has **not** been applied to a live Supabase project.

| Service | Responsibility |
| --- | --- |
| Supabase Auth | Player identity and sessions |
| PostgreSQL | Profiles, saves, inventory, alliances, mission results, event schedule and resource ledger |
| Supabase Realtime | Deliver approved global/alliance messages and world-event updates |
| Supabase Edge Functions | Validate trades, purchases, contracts, mission rewards, alliance membership and chat posts |
| Vercel | Host the web client and secure server-side AI endpoints |
| Higgsfield | Create visual concepts and cinematic references; approved 3D assets must still be exported, optimized and integrated into Three.js |

## Required Edge Function contracts

These are implementation targets, not deployed functions:

- `save-player`: authenticate the caller, validate the save schema and enforce a revision check.
- `complete-mission`: accept a mission result proposal, validate the active mission and compute rewards server-side.
- `trade-resources`: validate an allowlisted exchange, balance, capacity and idempotency key in one database transaction.
- `complete-contract`: enforce one-time contract completion and calculate rewards server-side.
- `create-alliance` / `join-alliance`: validate membership limits, invitations and role changes.
- `post-global-message`: authenticate, trim and validate content, enforce rate limits, block/report controls and moderation before persistence.
- `generate-mission`: ask the model for a strict JSON proposal, validate every field and return only a bounded blueprint. Never accept resource or reward amounts from the model.
- `schedule-world-event`: authorize trusted operators and validate event duration, status and payload.

## Chat and player safety

- No fake player count, fabricated users or sample messages presented as live activity.
- No client-side service-role key or model provider key.
- RLS is enabled for every table in the prepared schema.
- Sensitive writes are reserved for authenticated server-side functions.
- Add message length limits, rate limits, moderation, report/block tools and audit logs before enabling public chat.
- Keep player data private and expose only the minimum profile fields needed by other players.

## Visual production handoff

Higgsfield still needs a Basic-or-higher plan for the attempted image-generation action in the connected workspace. The connector did not submit a generation. When visual generation is available, produce original concept sheets for:

1. Gipsy-class hero silhouette and material callouts.
2. Striker-class and Cherno-class visual variants.
3. One original Kaiju per threat category.
4. PPDC hangar exterior/interior and modular facilities.
5. Coastal city districts, evacuation corridors and weather states.

Concept images and cinematic videos are references, not real-time game assets. Convert approved designs into optimized GLB/GLTF meshes, PBR textures, rigs, animation clips and LODs before integrating them into Three.js.

## Definition of done

- A mission event changes visible briefing and bounded gameplay parameters.
- The same seed recreates the same event and district.
- Offline gameplay still works when remote AI is unavailable.
- Server-side transactions prevent duplicate rewards and resource exploits.
- Chat and alliances are backed by real authenticated users.
- Build/type-check passes and a preview deployment is verified before calling the feature complete.

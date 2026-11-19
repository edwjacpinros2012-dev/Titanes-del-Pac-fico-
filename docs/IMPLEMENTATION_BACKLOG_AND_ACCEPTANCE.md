# Implementation backlog and integration acceptance — November 2026

This file is an execution checklist. A module is only complete after it is reachable in the game, has a visible feedback path, persists the relevant state, and has a test or manual verification recorded.

## P0 — Complete the playable loop
- [ ] Move around the world with keyboard and touch; camera follow and touch camera drag.
- [ ] Interact with resource nodes and confirm resource deltas in HUD.
- [ ] Launch a mission from a clear UI flow, with objectives and a mission state machine.
- [ ] Replace encounter power comparison as the sole combat resolution with an interactive combat loop (time-based actions, enemy telegraphs, player response, hit feedback, health/energy, defeat/recovery, result screen).
- [ ] Connect combat rewards and damage to profile/inventory/repair systems.
- [ ] Save, quit, reopen and verify the loop's state.

## P0 — Integration and state integrity
- [ ] Add a central state owner or typed contracts; no UI should be authoritative for credits/items.
- [ ] Integrate MissionTracker, ExpeditionManager, WorldEventManager, RegionManager, SurvivalStats and CraftingManager into the main scene; show entry points and HUD feedback.
- [ ] Add export/import state to every module that must persist.
- [ ] Make purchases, crafting, contract rewards and mission claims transactional (validate all inputs, then commit; no partial deductions).
- [ ] Add duplicate-claim/idempotency guards.
- [ ] Add save-slot recovery, backup, version migration and round-trip tests.
- [ ] Validate resource names, nonnegative quantities, player identifiers and region IDs at boundaries.

## P1 — UX and content
- [ ] Replace the monolithic, scrolling HUD with context panels and accessible navigation.
- [ ] Make every keyboard action available on touch/controller or provide a visible alternative.
- [ ] Add responsive layout, aspect-ratio handling, safe areas, scale settings and readable text.
- [ ] Build distinct playable biomes/regions, landmarks, obstacles and terrain variation.
- [ ] NPC context interactions, dialogue branches, roles and persistent schedules.
- [ ] Kaiju behavior states: idle, detect, approach, attack, recover, retreat; boss phases and telegraphs.
- [ ] Add tutorial, objectives, pause/options, audio and feedback.

## P1 — Online services (remain disabled until secure)
- [ ] Configure a real Supabase project, apply migrations and inspect RLS policies.
- [ ] Implement server-side authorization and validation; never trust client credits or inventory.
- [ ] Implement Google identity through a supported provider flow and validate tokens server-side.
- [ ] Cloud save conflict/version handling.
- [ ] Online alliance endpoints with permission checks and abuse limits.
- [ ] Chat remains off until moderation, reporting, blocking, privacy and parental-safety review are complete.

## P2 — Delivery
- [ ] Godot import and visual run on desktop.
- [ ] Export and smoke-test Web build.
- [ ] Publish the actual playable Web export, not the information landing page.
- [ ] Android export with SDK/JDK/templates, signing, installation and device test.
- [ ] Performance, crash, input, save, network and accessibility checks.
- [ ] Privacy disclosure and release/legal review.

## Existing persistence found during follow-up review
- `scripts/main.gd` already calls `SaveSystem.save_profile()` and `SaveSystem.load_profile()` and persists several manager snapshots. Avoid introducing a second profile store. Follow-up work is to audit the existing `SaveSystem`, add the missing module state round-trips, and harden backup/atomic replacement.

## Acceptance evidence
Record test date, device/platform, build/commit, steps, expected vs actual, and screenshots/logs for manual checks. CI headless is useful but does not certify visual quality or Android readiness.

# Contratos de integración entre sistemas

Los sistemas deben intercambiar datos estables, no referencias a nodos de escena.

## IDs
Usar IDs estables en snake_case. Los nombres visibles pueden traducirse; los IDs solo cambian mediante migración.

## Recurso
Campos: id, display_name, stack_limit, rarity, source_regions, icon_id. Todas las transacciones deben pasar por un servicio de inventario central.

## Unidad
Campos: unit_id, class_id, generation, stats, modules, condition, pilot_profile. El nivel no sustituye generación, configuración, estado ni sincronización de pilotos.

## Amenaza
Campos: enemy_id, species_id, role, region_id, threat_tier, behavior_profile, telegraph_profile, reward_table. El director informa el riesgo antes de operar y nunca escala solo por nivel del jugador.

## Misión
Campos: mission_id, region_id, objectives, threat_context, required_items, reward, failure_consequences, retreat_allowed. Estados: locked, available, active, completed, failed, abandoned.

## Región
Campos: region_id, unlock_requirements, biome_id, resource_table, hazards, regional_pressure, control_state, points_of_interest. La presión altera eventos, pero nunca elimina todas las rutas de recuperación.

## Instalación
Campos: facility_id, level, build_state, requirements, upkeep, production, assigned_staff, health. Producción limitada por almacén y mantenimiento; debe ser determinista al guardar/cargar.

## NPC
Campos: npc_id, role, schedule_id, traits, skills, relationship, active_request, memory_flags. Las relaciones se almacenan por NPC; una cifra global no sustituye relaciones individuales.

## Evento
Formato: event_id, event_type, source_id, game_timestamp, payload, schema_version. No serializar referencias a nodos Godot.

## Perfil persistente
Secciones: profile_meta, player_progress, centinel_loadout, inventory, base_facilities, research, campaign, missions, world_regions, npc_relations, helicopter_operations, rift_states, discovery_log, settings.

## Resultado de operación
Campos: outcome, objectives_completed, damage_by_subsystem, resources_spent, rewards, regional_pressure_delta, unlocked_content. Estados: victory, partial, retreat, defeat. Un coordinador aplica los cambios a misión, inventario, daño, región, campaña y NPC.

## Aceptación
Un sistema está integrado solo si usa IDs acordados, expone eventos sin acoplamiento rígido, tiene interfaz/controles, guarda y restaura sus cambios, posee pruebas de éxito/fallo/borde y puede simplificarse en hardware modesto.

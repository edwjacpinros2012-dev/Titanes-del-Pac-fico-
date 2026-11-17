extends Node
class_name TitanAbilityController

signal ability_used(ability_id: String)
signal ability_unavailable(reason: String)

var cooldowns: Dictionary = {}

func _process(delta: float) -> void:
	for ability_id in cooldowns.keys():
		cooldowns[ability_id] = maxf(0.0, float(cooldowns[ability_id]) - delta)

func try_use(ability: TitanAbility, current_stage: int) -> bool:
	if ability == null:
		ability_unavailable.emit("Habilidad no configurada.")
		return false
	if current_stage < ability.required_evolution_stage:
		ability_unavailable.emit("Necesitas una evolución superior.")
		return false
	if float(cooldowns.get(ability.ability_id, 0.0)) > 0.0:
		ability_unavailable.emit("La habilidad todavía se está recargando.")
		return false
	cooldowns[ability.ability_id] = ability.cooldown_seconds
	ability_used.emit(ability.ability_id)
	return true

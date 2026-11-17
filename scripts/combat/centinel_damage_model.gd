extends Node
class_name CentinelDamageModel

signal condition_changed(summary: String)

const SYSTEM_MAX := 100
var systems := {
	"chassis": 100,
	"mobility": 100,
	"sensors": 100,
	"reactor": 100
}

func apply_battle_result(outcome: String, threat: int, tactic: String, enemy_role: String) -> Dictionary:
	var base_damage := 0
	match outcome:
		"victory":
			base_damage = 4 + threat
		"partial_success":
			base_damage = 9 + threat * 2
		"retreat":
			base_damage = 5 + threat
		"defeat":
			base_damage = 16 + threat * 3
		_:
			return {}
	if tactic == "guard":
		base_damage = maxi(2, roundi(float(base_damage) * 0.8))
	var weights := {"chassis": 40, "mobility": 25, "sensors": 15, "reactor": 20}
	match enemy_role:
		"armored", "siege":
			weights["chassis"] += 15
			weights["mobility"] -= 10
		"swift", "ambusher", "stalker":
			weights["sensors"] += 15
			weights["chassis"] -= 10
		"disruptor", "alpha":
			weights["reactor"] += 15
			weights["chassis"] -= 10
	var applied := {}
	var remaining := base_damage
	for system_id in ["chassis", "mobility", "sensors"]:
		var amount := roundi(float(base_damage) * float(weights[system_id]) / 100.0)
		amount = mini(amount, int(systems[system_id]))
		systems[system_id] = maxi(0, int(systems[system_id]) - amount)
		applied[system_id] = amount
		remaining -= amount
	var reactor_damage := mini(maxi(0, remaining), int(systems["reactor"]))
	systems["reactor"] = maxi(0, int(systems["reactor"]) - reactor_damage)
	applied["reactor"] = reactor_damage
	condition_changed.emit(get_status_text())
	return applied

func repair_with_resources(resources: Dictionary) -> int:
	var metal := int(resources.get("metal", 0))
	var energy := int(resources.get("energia", 0))
	var repair_points := mini(metal, energy)
	if repair_points <= 0:
		return 0
	var repaired := 0
	for system_id in ["chassis", "mobility", "sensors", "reactor"]:
		var missing := SYSTEM_MAX - int(systems[system_id])
		var amount := mini(missing, repair_points - repaired)
		if amount <= 0:
			continue
		systems[system_id] = mini(SYSTEM_MAX, int(systems[system_id]) + amount)
		repaired += amount
		if repaired >= repair_points:
			break
	if repaired > 0:
		resources["metal"] = metal - repaired
		resources["energia"] = energy - repaired
		condition_changed.emit(get_status_text())
	return repaired

func get_mobility_multiplier() -> float:
	return clampf(0.55 + float(systems["mobility"]) / 100.0 * 0.45, 0.55, 1.0)

func get_power_penalty() -> int:
	var average := 0.0
	for value in systems.values():
		average += float(value)
	average /= float(systems.size())
	return clampi(roundi((100.0 - average) / 20.0), 0, 5)

func get_status_text() -> String:
	return "ESTADO DEL CENTINELA | Chasis %d%% | Movilidad %d%% | Sensores %d%% | Reactor %d%%" % [
		systems["chassis"], systems["mobility"], systems["sensors"], systems["reactor"]
	]

func export_state() -> Dictionary:
	return {"version": 1, "systems": systems.duplicate(true)}

func import_state(data: Dictionary) -> void:
	var saved: Variant = data.get("systems", {})
	if saved is Dictionary:
		for system_id in systems.keys():
			systems[system_id] = clampi(int(saved.get(system_id, SYSTEM_MAX)), 0, SYSTEM_MAX)
	condition_changed.emit(get_status_text())

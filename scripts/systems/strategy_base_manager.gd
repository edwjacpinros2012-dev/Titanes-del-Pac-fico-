extends RefCounted
class_name StrategyBaseManager

signal building_upgraded(building_id: String, new_level: int)
signal economy_changed(resources: Dictionary)

const CATALOG_PATH := "res://data/strategy/base_buildings.json"
const Economy = preload("res://scripts/systems/strategy_economy.gd")
var catalog: Dictionary = {}
var resources: Dictionary = {"alloy": 0, "energy": 0, "intel": 0, "parts": 0}
var levels: Dictionary = {"command": 1, "hangar": 1, "reactor": 1, "warehouse": 1}
var caps: Dictionary = {}
var last_production_claim_unix := 0

func _init() -> void:
	load_catalog()

func load_catalog() -> bool:
	if not FileAccess.file_exists(CATALOG_PATH):
		push_error("Base catalog missing: " + CATALOG_PATH)
		return false
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(CATALOG_PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Base catalog JSON is invalid.")
		return false
	catalog = parsed
	caps = Economy.storage_caps(catalog.get("resource_caps_base", {}), levels, catalog.get("buildings", []))
	resources = Economy.clamp_resources(resources, caps)
	return true

func building_data(building_id: String) -> Dictionary:
	for entry in catalog.get("buildings", []):
		if str(entry.get("id", "")) == building_id:
			return entry
	return {}

func upgrade_building(building_id: String) -> Dictionary:
	var building := building_data(building_id)
	if building.is_empty():
		return {"ok": false, "reason": "unknown_building"}
	var current := int(levels.get(building_id, 0))
	var max_level := int(building.get("max_level", 1))
	if current >= max_level:
		return {"ok": false, "reason": "max_level"}
	var required_command := int(building.get("unlock_level", 1))
	if int(levels.get("command", 1)) < required_command:
		return {"ok": false, "reason": "command_level_required"}
	var cost: Dictionary = building.get("cost_per_level", {})
	var payment := Economy.apply_cost(resources, cost, caps)
	if not payment.get("ok", false):
		return {"ok": false, "reason": "insufficient_resources", "cost": cost}
	resources = payment.resources
	levels[building_id] = current + 1
	caps = Economy.storage_caps(catalog.get("resource_caps_base", {}), levels, catalog.get("buildings", []))
	resources = Economy.clamp_resources(resources, caps)
	building_upgraded.emit(building_id, int(levels[building_id]))
	economy_changed.emit(resources.duplicate(true))
	return {"ok": true, "level": int(levels[building_id]), "resources": resources.duplicate(true), "caps": caps.duplicate(true)}

func add_resources(reward: Dictionary) -> Dictionary:
	resources = Economy.apply_reward(resources, reward, caps)
	economy_changed.emit(resources.duplicate(true))
	return resources.duplicate(true)

func production_rates() -> Dictionary:
	var result: Dictionary = {}
	for building in catalog.get("buildings", []):
		var level := int(levels.get(str(building.get("id", "")), 0))
		var rates: Dictionary = building.get("production", {})
		for resource in rates.keys():
			result[resource] = int(result.get(resource, 0)) + int(rates[resource]) * level
	return result

func claim_offline_production(now_unix: int = -1) -> Dictionary:
	var now := now_unix if now_unix >= 0 else int(Time.get_unix_time_from_system())
	if last_production_claim_unix <= 0:
		last_production_claim_unix = now
		return {"ok": false, "reason": "first_claim_sets_clock", "reward": {}}
	var elapsed := maxi(0, now - last_production_claim_unix)
	var calculation := Economy.calculate_offline_production(production_rates(), float(elapsed))
	var reward: Dictionary = calculation.reward
	var before := resources.duplicate(true)
	resources = Economy.apply_reward(resources, reward, caps)
	var gained: Dictionary = {}
	for key in reward.keys():
		gained[key] = int(resources.get(key, 0)) - int(before.get(key, 0))
	last_production_claim_unix = now
	economy_changed.emit(resources.duplicate(true))
	return {"ok": true, "elapsed_hours": calculation.elapsed_hours, "reward": gained, "resources": resources.duplicate(true)}

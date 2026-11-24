extends Node
class_name GameState

signal resources_changed
signal progression_changed

var resources: Dictionary = {"metal": 0, "energia": 0, "cristal": 0}
var base_level: int = 1
var titan_level: int = 1
var unlocked_regions: Array[String] = ["aurora_coast"]
var completed_missions: Array[String] = []

func add_resource(resource_id: String, amount: int) -> void:
	if amount <= 0:
		return
	resources[resource_id] = int(resources.get(resource_id, 0)) + amount
	resources_changed.emit()

func can_afford(cost: Dictionary) -> bool:
	for key in cost:
		if int(cost[key]) < 0:
			return false
		if int(resources.get(key, 0)) < int(cost[key]):
			return false
	return true

func spend(cost: Dictionary) -> bool:
	if not can_afford(cost):
		return false
	for key in cost:
		resources[key] = int(resources.get(key, 0)) - int(cost[key])
	resources_changed.emit()
	return true

func unlock_region(region_id: String) -> void:
	if region_id not in unlocked_regions:
		unlocked_regions.append(region_id)
		progression_changed.emit()

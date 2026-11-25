extends Node
class_name GameState

signal resources_changed
signal progression_changed

const JAEGER_IDS: Array[String] = ["gipsy", "striker", "cherno"]
const JAEGER_UNLOCK_MILESTONES := {"gipsy": 0, "striker": 2, "cherno": 4}
var resources: Dictionary = {"metal": 0, "energia": 0, "cristal": 0}
var base_level: int = 1
var titan_level: int = 1
var unlocked_regions: Array[String] = ["aurora_coast"]
var completed_missions: Array[String] = []
var selected_jaeger: String = "gipsy"
var unlocked_jaegers: Array[String] = ["gipsy"]
var jaeger_marks: Dictionary = {"gipsy": 1, "striker": 1, "cherno": 1}

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
	if not region_id.is_empty() and region_id not in unlocked_regions:
		unlocked_regions.append(region_id)
		progression_changed.emit()

func unlock_jaeger(jaeger_id: String) -> bool:
	if jaeger_id not in JAEGER_IDS:
		return false
	if jaeger_id in unlocked_jaegers:
		return true
	var required_missions := int(JAEGER_UNLOCK_MILESTONES.get(jaeger_id, 999))
	if completed_missions.size() < required_missions:
		return false
	unlocked_jaegers.append(jaeger_id)
	progression_changed.emit()
	return true

func select_jaeger(jaeger_id: String) -> bool:
	if jaeger_id not in JAEGER_IDS or jaeger_id not in unlocked_jaegers:
		return false
	if selected_jaeger == jaeger_id:
		return true
	selected_jaeger = jaeger_id
	progression_changed.emit()
	return true

func evolve_selected_jaeger() -> bool:
	var current_mark := clampi(int(jaeger_marks.get(selected_jaeger, 1)), 1, 10)
	if current_mark >= 10:
		return false
	var cost := {"metal": 180 + current_mark * 120, "energia": 100 + current_mark * 80}
	if not spend(cost):
		return false
	jaeger_marks[selected_jaeger] = current_mark + 1
	progression_changed.emit()
	return true

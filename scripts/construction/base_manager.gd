extends Node3D
class_name BaseManager
signal building_added(building_id: String)
signal base_level_changed(level: int)
@export var starting_level := 1
var level := 1
var buildings: Array[Node3D] = []
func _ready() -> void:
	level = starting_level
func register_building(building: Node3D, building_id: String) -> void:
	if building == null: return
	if building not in buildings: buildings.append(building)
	building_added.emit(building_id)
func upgrade_base(cost: Dictionary, inventory: Inventory) -> bool:
	if inventory == null or not inventory.remove_items(cost): return false
	level += 1
	base_level_changed.emit(level)
	return true

extends StaticBody3D
class_name BaseBuilding

@export var building_id: String = "command_hub"
@export var display_name: String = "Centro de mando"
@export var health: float = 500.0
@export var level: int = 1

func upgrade(cost: Dictionary, inventory: Inventory) -> bool:
	if inventory == null or not inventory.remove_items(cost):
		return false
	level += 1
	health += 100.0
	return true

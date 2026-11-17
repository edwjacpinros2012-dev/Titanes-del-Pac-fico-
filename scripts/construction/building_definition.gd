extends Resource
class_name BuildingDefinition
@export var building_id: String = "small_generator"
@export var display_name: String = "Generador pequeño"
@export var scene: PackedScene
@export var cost: Dictionary = {"metal": 12, "energy": 4}
@export var required_base_level: int = 1
@export var description: String = "Produce energía para la base."

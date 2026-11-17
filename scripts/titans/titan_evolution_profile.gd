extends Resource
class_name TitanEvolutionProfile

@export var stage_id: String = "awakening"
@export var display_name: String = "Despertar"
@export_multiline var description: String = "La primera resonancia del Titán Alfa."
@export var required_level: int = 1
@export var cost: Dictionary = {"metal": 10, "energy": 8}
@export var health_multiplier: float = 1.15
@export var speed_multiplier: float = 1.05
@export var armor_bonus: float = 2.0

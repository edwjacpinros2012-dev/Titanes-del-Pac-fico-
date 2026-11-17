extends Resource
class_name CreatureDefinition
@export var creature_id: String = "coast_scavenger"
@export var display_name: String = "Carroñero costero"
@export_enum("neutral", "defensive", "hostile") var temperament: String = "neutral"
@export var health: float = 35.0
@export var movement_speed: float = 3.0
@export var detection_range: float = 9.0
@export var drops: Dictionary = {"metal": 1}

extends Resource
class_name TitanStats

@export var titan_id: String = "titan_alpha"
@export var display_name: String = "Titán Alfa"
@export_range(1, 100, 1) var level: int = 1
@export var health: float = 100.0
@export var move_speed: float = 7.0
@export var armor: float = 5.0
@export var evolution_stage: int = 0
@export var abilities: Array[String] = ["pulse_scan"]

func apply_level_up() -> void:
	level += 1
	health += 20.0
	armor += 2.0
	move_speed += 0.25

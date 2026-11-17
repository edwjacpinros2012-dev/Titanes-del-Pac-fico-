extends Resource
class_name TitanAbility

@export var ability_id: String = "pulse_scan"
@export var display_name: String = "Pulso de exploración"
@export_multiline var description: String = "Revela recursos y puntos de interés cercanos."
@export var cooldown_seconds: float = 12.0
@export var range_meters: float = 18.0
@export var required_evolution_stage: int = 0

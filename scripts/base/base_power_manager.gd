extends Node
class_name BasePowerManager

signal power_updated(generation: float, consumption: float, stored: float)
signal power_shortage

@export var max_storage: float = 100.0
@export var starting_storage: float = 35.0
var generation_per_second := 0.0
var consumption_per_second := 0.0
var stored_energy := 35.0

func _ready() -> void:
	stored_energy = clampf(starting_storage, 0.0, max_storage)

func _process(delta: float) -> void:
	var balance := generation_per_second - consumption_per_second
	stored_energy = clampf(stored_energy + balance * delta, 0.0, max_storage)
	if balance < 0.0 and stored_energy <= 0.0:
		power_shortage.emit()
	power_updated.emit(generation_per_second, consumption_per_second, stored_energy)

func register_generator(output: float) -> void:
	generation_per_second += maxf(0.0, output)

func unregister_generator(output: float) -> void:
	generation_per_second = maxf(0.0, generation_per_second - maxf(0.0, output))

func register_consumer(demand: float) -> void:
	consumption_per_second += maxf(0.0, demand)

func unregister_consumer(demand: float) -> void:
	consumption_per_second = maxf(0.0, consumption_per_second - maxf(0.0, demand))

func has_power() -> bool:
	return stored_energy > 0.0 or generation_per_second > consumption_per_second

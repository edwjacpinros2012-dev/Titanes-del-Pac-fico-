extends BaseBuilding
class_name GeneratorBuilding

@export var energy_output: float = 1.5
var power_manager: BasePowerManager

func connect_power_manager(manager: BasePowerManager) -> void:
	if power_manager == manager:
		return
	if power_manager:
		power_manager.unregister_generator(energy_output)
	power_manager = manager
	if power_manager:
		power_manager.register_generator(energy_output)

func _exit_tree() -> void:
	if is_instance_valid(power_manager):
		power_manager.unregister_generator(energy_output)

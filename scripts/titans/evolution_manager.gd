extends Node
class_name EvolutionManager

signal evolution_unlocked(stage: int)
signal evolution_failed(reason: String)

@export var evolution_costs: Array[Dictionary] = [
	{"metal": 10, "energy": 8},
	{"metal": 25, "energy": 20, "crystal": 10},
	{"metal": 50, "energy": 40, "crystal": 30}
]

func evolve(stats: TitanStats, inventory: Inventory) -> bool:
	if stats == null or inventory == null:
		evolution_failed.emit("Faltan datos del titán o inventario.")
		return false
	var next_index := stats.evolution_stage
	if next_index >= evolution_costs.size():
		evolution_failed.emit("El titán ya alcanzó la última evolución disponible.")
		return false
	var cost: Dictionary = evolution_costs[next_index]
	if not inventory.remove_items(cost):
		evolution_failed.emit("No tienes suficientes recursos.")
		return false
	stats.evolution_stage += 1
	stats.apply_level_up()
	evolution_unlocked.emit(stats.evolution_stage)
	return true

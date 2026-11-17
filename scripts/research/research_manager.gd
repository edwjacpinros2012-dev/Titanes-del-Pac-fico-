extends Node
class_name ResearchManager
signal technology_unlocked(technology_id: String)
signal research_failed(reason: String)
var unlocked: Array[String] = []
func unlock(technology_id: String, cost: Dictionary, inventory: Inventory, prerequisites: Array[String] = []) -> bool:
	if technology_id in unlocked:
		research_failed.emit("La tecnología ya está desbloqueada.")
		return false
	for requirement in prerequisites:
		if requirement not in unlocked:
			research_failed.emit("Falta investigar: " + requirement)
			return false
	if not inventory.remove_items(cost):
		research_failed.emit("Recursos insuficientes.")
		return false
	unlocked.append(technology_id)
	technology_unlocked.emit(technology_id)
	return true

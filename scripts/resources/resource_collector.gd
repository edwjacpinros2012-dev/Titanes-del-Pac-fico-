extends Node
class_name ResourceCollector
signal resource_collected(resource_id: String, amount: int)
@export var interaction_range: float = 3.0
func collect_nearest(collector: Node3D, inventory: Inventory) -> bool:
	if collector == null or inventory == null: return false
	var nearest: ResourceNode
	var nearest_distance := interaction_range
	for candidate in get_tree().get_nodes_in_group("resource_nodes"):
		if not candidate is ResourceNode: continue
		var distance: float = collector.global_position.distance_to(candidate.global_position)
		if distance <= nearest_distance:
			nearest = candidate
			nearest_distance = distance
	if nearest == null: return false
	var result: Dictionary = await nearest.collect()
	if result.is_empty(): return false
	var resource_id := str(result.get("id", ""))
	var amount := int(result.get("amount", 0))
	inventory.add_item(resource_id, amount)
	resource_collected.emit(resource_id, amount)
	return true


extends RefCounted
class_name Inventory

signal changed

var items: Dictionary = {}

func add_item(item_id: String, amount: int) -> void:
	if item_id.strip_edges().is_empty() or amount <= 0:
		return
	items[item_id] = int(items.get(item_id, 0)) + amount
	changed.emit()

func has_items(cost: Dictionary) -> bool:
	for item_id in cost:
		var required := int(cost[item_id])
		if str(item_id).strip_edges().is_empty() or required < 0:
			return false
		if int(items.get(item_id, 0)) < required:
			return false
	return true

func remove_items(cost: Dictionary) -> bool:
	if not has_items(cost):
		return false
	for item_id in cost:
		items[item_id] = int(items.get(item_id, 0)) - int(cost[item_id])
	changed.emit()
	return true

extends RefCounted
class_name Inventory

signal changed

var items: Dictionary = {}

func add_item(item_id: String, amount: int) -> void:
	if amount <= 0:
		return
	items[item_id] = int(items.get(item_id, 0)) + amount
	changed.emit()

func has_items(cost: Dictionary) -> bool:
	for item_id in cost:
		if int(items.get(item_id, 0)) < int(cost[item_id]):
			return false
	return true

func remove_items(cost: Dictionary) -> bool:
	if not has_items(cost):
		return false
	for item_id in cost:
		items[item_id] = int(items[item_id]) - int(cost[item_id])
	changed.emit()
	return true

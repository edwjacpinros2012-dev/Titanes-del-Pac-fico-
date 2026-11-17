extends StaticBody3D
class_name ResourceNode

@export var resource_id: String = "metal"
@export_range(1, 100, 1) var amount: int = 2
@export var respawn_seconds: float = 0.0

signal collected(resource_id: String, amount: int)

var available := true

func collect() -> Dictionary:
	if not available:
		return {}
	available = false
	collected.emit(resource_id, amount)
	if respawn_seconds > 0.0:
		await get_tree().create_timer(respawn_seconds).timeout
		available = true
		visible = true
		set_collision_layer_value(1, true)
	else:
		queue_free()
	return {"id": resource_id, "amount": amount}

func _ready() -> void:
	add_to_group("resource_nodes")

extends Node3D
class_name BuildingPlacer
signal placement_confirmed(building_id: String)
signal placement_cancelled
@export var grid_size: float = 2.0
var selected_definition: BuildingDefinition
var preview: Node3D
var placement_enabled := false
func begin_placement(definition: BuildingDefinition, preview_scene: PackedScene) -> void:
	cancel_placement()
	selected_definition = definition
	if preview_scene:
		preview = preview_scene.instantiate()
		add_child(preview)
	placement_enabled = true
func update_preview(world_position: Vector3) -> void:
	if placement_enabled and preview:
		preview.global_position = _snap(world_position)
func confirm_placement(parent_node: Node3D, inventory: Inventory, world_position: Vector3) -> bool:
	if not placement_enabled or selected_definition == null or selected_definition.scene == null: return false
	if not inventory.remove_items(selected_definition.cost): return false
	var building := selected_definition.scene.instantiate() as Node3D
	if building == null: return false
	parent_node.add_child(building)
	building.global_position = _snap(world_position)
	var placed_id := selected_definition.building_id
	cancel_placement()
	placement_confirmed.emit(placed_id)
	return true
func _snap(position: Vector3) -> Vector3:
	return Vector3(round(position.x / grid_size) * grid_size, position.y, round(position.z / grid_size) * grid_size)
func cancel_placement() -> void:
	placement_enabled = false
	selected_definition = null
	if is_instance_valid(preview): preview.queue_free()
	preview = null
	placement_cancelled.emit()

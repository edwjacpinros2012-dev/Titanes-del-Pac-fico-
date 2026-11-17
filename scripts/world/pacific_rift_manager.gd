extends Node
class_name PacificRiftManager

signal rift_progress_changed(progress: float, rift_index: int)
signal rift_stabilized(rift_index: int, reward: Dictionary)

@export var interaction_radius: float = 7.0
@export var stabilization_seconds: float = 4.0

var rift_positions: Array[Vector3] = [
	Vector3(-24.0, 0.0, -18.0),
	Vector3(28.0, 0.0, 16.0),
	Vector3(-34.0, 0.0, 30.0)
]
var completed: Array[bool] = [false, false, false]
var current_progress: float = 0.0
var active_rift_index: int = -1
var markers: Array[MeshInstance3D] = []

func _ready() -> void:
	_create_markers()

func _process(delta: float) -> void:
	var player := get_parent().get_node_or_null("TitanAlfa") as Node3D
	if player == null:
		return

	active_rift_index = _find_nearest_rift(player.global_position)
	if active_rift_index == -1:
		current_progress = maxf(0.0, current_progress - delta * 0.5)
		return

	if Input.is_action_pressed("stabilize_rift"):
		current_progress = minf(1.0, current_progress + delta / stabilization_seconds)
		rift_progress_changed.emit(current_progress, active_rift_index)
		if current_progress >= 1.0:
			_complete_rift(active_rift_index)
	else:
		current_progress = maxf(0.0, current_progress - delta * 0.35)
		rift_progress_changed.emit(current_progress, active_rift_index)

func _find_nearest_rift(position: Vector3) -> int:
	var best_index := -1
	var best_distance := interaction_radius
	for i in range(rift_positions.size()):
		if completed[i]:
			continue
		var distance := position.distance_to(rift_positions[i])
		if distance <= best_distance:
			best_distance = distance
			best_index = i
	return best_index

func _complete_rift(index: int) -> void:
	completed[index] = true
	current_progress = 0.0
	if index < markers.size() and is_instance_valid(markers[index]):
		markers[index].material_override = _make_material(Color(0.18, 0.85, 0.55), false)
	var reward := {"metal": 5, "energia": 3, "cristal": 2}
	rift_stabilized.emit(index, reward)
	active_rift_index = -1

func get_objective_text() -> String:
	var all_completed := true
	for is_done in completed:
		if not is_done:
			all_completed = false
			break
	if all_completed:
		return "BRECHAS ESTABILIZADAS: sector seguro"
	if active_rift_index >= 0:
		return "MANTÉN R PARA ESTABILIZAR: %d%%" % roundi(current_progress * 100.0)
	var remaining := 0
	for done in completed:
		if not done:
			remaining += 1
	return "BUSCA UNA BRECHA OCEÁNICA (%d pendientes)" % remaining

func _create_markers() -> void:
	for position in rift_positions:
		var marker := MeshInstance3D.new()
		var ring := TorusMesh.new()
		ring.inner_radius = 1.4
		ring.outer_radius = 2.0
		marker.mesh = ring
		marker.position = position + Vector3.UP * 0.15
		marker.material_override = _make_material(Color(0.15, 0.75, 1.0), true)
		add_child(marker)
		markers.append(marker)

func _make_material(color: Color, glow: bool) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	if glow:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = 2.0
	return material

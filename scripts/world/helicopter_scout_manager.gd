extends Node3D
class_name HelicopterScoutManager

signal scouting_completed(reward: Dictionary, scan_center: Vector3)
signal scouting_started

@export var flight_duration: float = 12.0
@export var orbit_radius: float = 13.0

var is_active: bool = false
var is_returning: bool = false
var elapsed: float = 0.0
var target_center: Vector3 = Vector3.ZERO
var helicopters: Array[Node3D] = []
var rotors: Array[MeshInstance3D] = []

func _ready() -> void:
	_create_helicopters()
	_set_helicopters_visible(false)

func _process(delta: float) -> void:
	if not is_active:
		return
	elapsed += delta
	for index in range(helicopters.size()):
		if is_returning:
			var home_position := Vector3(float(index) * 3.0, 4.0, -8.0)
			helicopters[index].global_position = helicopters[index].global_position.move_toward(home_position, delta * 8.0)
		else:
			var angle := elapsed * 0.8 + float(index) * PI
			var offset := Vector3(cos(angle) * orbit_radius, 10.0 + sin(elapsed * 1.8), sin(angle) * orbit_radius)
			var destination := target_center + offset
			helicopters[index].global_position = helicopters[index].global_position.lerp(destination, clampf(delta * 2.5, 0.0, 1.0))
			helicopters[index].rotation.y = -angle
		rotors[index].rotate_y(delta * 18.0)
	if not is_returning and elapsed >= flight_duration:
		is_returning = true
	if is_returning:
		var all_helicopters_home := true
		for index in range(helicopters.size()):
			var home_position := Vector3(float(index) * 3.0, 4.0, -8.0)
			if helicopters[index].global_position.distance_to(home_position) >= 1.5:
				all_helicopters_home = false
		if all_helicopters_home:
			is_active = false
			is_returning = false
			_set_helicopters_visible(false)
			scouting_completed.emit({"metal": 3, "energia": 1, "research_data": 3}, target_center)

func dispatch_scout(center: Vector3) -> bool:
	if is_active:
		return false
	is_active = true
	is_returning = false
	elapsed = 0.0
	target_center = center + Vector3(0.0, 0.0, -7.0)
	for index in range(helicopters.size()):
		helicopters[index].global_position = center + Vector3(float(index) * 3.0, 1.0, 0.0)
	_set_helicopters_visible(true)
	scouting_started.emit()
	return true

func get_status_text() -> String:
	if is_active and is_returning:
		return "HELICÓPTEROS: regresando a la base"
	if is_active:
		return "HELICÓPTEROS: reconocimiento en curso (%.0f s)" % maxf(0.0, flight_duration - elapsed)
	return "HELICÓPTEROS: en plataforma | H: enviar reconocimiento"

func _set_helicopters_visible(value: bool) -> void:
	for helicopter in helicopters:
		helicopter.visible = value

func _create_helicopters() -> void:
	for index in range(2):
		var helicopter := Node3D.new()
		helicopter.name = "HelicopteroReconocimiento_%d" % index
		var body := MeshInstance3D.new()
		var body_mesh := BoxMesh.new()
		body_mesh.size = Vector3(2.4, 0.7, 1.0)
		body.mesh = body_mesh
		body.material_override = _make_material(Color(0.24, 0.42, 0.52))
		helicopter.add_child(body)

		var cockpit := MeshInstance3D.new()
		var cockpit_mesh := BoxMesh.new()
		cockpit_mesh.size = Vector3(0.8, 0.55, 0.85)
		cockpit.mesh = cockpit_mesh
		cockpit.position = Vector3(0.65, 0.28, 0.0)
		cockpit.material_override = _make_material(Color(0.25, 0.85, 0.95), true)
		helicopter.add_child(cockpit)

		var rotor := MeshInstance3D.new()
		var rotor_mesh := BoxMesh.new()
		rotor_mesh.size = Vector3(0.12, 0.06, 4.2)
		rotor.mesh = rotor_mesh
		rotor.position = Vector3(0.0, 0.48, 0.0)
		rotor.material_override = _make_material(Color(0.12, 0.16, 0.2))
		helicopter.add_child(rotor)

		var tail := MeshInstance3D.new()
		var tail_mesh := BoxMesh.new()
		tail_mesh.size = Vector3(1.5, 0.18, 0.2)
		tail.mesh = tail_mesh
		tail.position = Vector3(-1.6, 0.1, 0.0)
		tail.material_override = _make_material(Color(0.24, 0.42, 0.52))
		helicopter.add_child(tail)

		add_child(helicopter)
		helicopters.append(helicopter)
		rotors.append(rotor)

func _make_material(color: Color, glow: bool = false) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	if glow:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = 1.2
	return material

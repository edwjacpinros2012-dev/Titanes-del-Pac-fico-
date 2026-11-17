extends Node3D
class_name CreatureEcosystemManager

signal creature_observed(display_name: String, research_reward: int)

var tracked_player: Node3D
var roamers: Array[Dictionary] = []
var observed_count: int = 0

var species: Array[Dictionary] = [
	{"name":"Mantarraya Trueno","shape":"sphere","color":Color(0.18,0.72,0.95),"scale":Vector3(2.2,0.55,1.7),"speed":2.2,"research":4},
	{"name":"Coral Rey","shape":"sphere","color":Color(0.95,0.42,0.22),"scale":Vector3(1.7,1.6,1.7),"speed":1.0,"research":4},
	{"name":"Taladro de Fosa","shape":"capsule","color":Color(0.55,0.42,0.75),"scale":Vector3(1.0,2.0,1.0),"speed":1.7,"research":6},
	{"name":"Tortuga Muralla","shape":"box","color":Color(0.32,0.62,0.36),"scale":Vector3(2.0,1.1,1.8),"speed":0.8,"research":3},
	{"name":"Serpiente Térmica","shape":"capsule","color":Color(0.95,0.34,0.12),"scale":Vector3(0.7,1.1,2.8),"speed":2.5,"research":5},
	{"name":"Caminante de Sal","shape":"box","color":Color(0.76,0.78,0.82),"scale":Vector3(1.6,2.2,1.3),"speed":1.4,"research":4},
	{"name":"Polilla de Niebla","shape":"sphere","color":Color(0.65,0.8,0.95),"scale":Vector3(1.6,0.7,1.2),"speed":2.8,"research":2},
	{"name":"Cangrejo Faro","shape":"box","color":Color(0.95,0.68,0.22),"scale":Vector3(1.6,1.0,1.6),"speed":1.2,"research":2}
]

func _ready() -> void:
	_spawn_ecosystem()

func set_player_target(target: Node3D) -> void:
	tracked_player = target

func _process(delta: float) -> void:
	for index in range(roamers.size()):
		var entry: Dictionary = roamers[index]
		var creature: Node3D = entry["node"]
		if not is_instance_valid(creature):
			continue
		var target: Vector3 = entry["target"]
		var speed: float = float(entry["speed"])
		if creature.position.distance_to(target) < 1.5:
			target = Vector3(randf_range(-38.0, 38.0), 0.0, randf_range(-38.0, 38.0))
			entry["target"] = target
		creature.position = creature.position.move_toward(target, speed * delta)
		if Vector2(target.x - creature.position.x, target.z - creature.position.z).length() > 0.2:
			creature.rotation.y = lerp_angle(creature.rotation.y, atan2(target.x - creature.position.x, target.z - creature.position.z), delta * 1.5)
		if tracked_player and not bool(entry["observed"]) and creature.global_position.distance_to(tracked_player.global_position) <= 12.0:
			entry["observed"] = true
			observed_count += 1
			creature_observed.emit(str(entry["name"]), int(entry["research"]))
		roamers[index] = entry

func reveal_nearby(center: Vector3, radius: float) -> int:
	var newly_observed := 0
	for index in range(roamers.size()):
		var entry: Dictionary = roamers[index]
		var creature: Node3D = entry["node"]
		if bool(entry["observed"]) or creature.global_position.distance_to(center) > radius:
			continue
		entry["observed"] = true
		roamers[index] = entry
		observed_count += 1
		newly_observed += 1
		creature_observed.emit(str(entry["name"]), int(entry["research"]))
	return newly_observed

func get_status_text() -> String:
	return "ECOSISTEMA: %d/%d especies observadas" % [observed_count, roamers.size()]

func _spawn_ecosystem() -> void:
	for index in range(species.size()):
		var data: Dictionary = species[index]
		var creature := Node3D.new()
		creature.name = str(data["name"]).replace(" ", "_")
		var body := MeshInstance3D.new()
		match str(data["shape"]):
			"capsule":
				body.mesh = CapsuleMesh.new()
			"box":
				body.mesh = BoxMesh.new()
			_:
				body.mesh = SphereMesh.new()
		body.scale = data["scale"]
		body.position.y = 1.1
		body.material_override = _make_material(data["color"], index % 2 == 0)
		creature.add_child(body)

		var marker := MeshInstance3D.new()
		var marker_mesh := SphereMesh.new()
		marker_mesh.radius = 0.16
		marker_mesh.height = 0.32
		marker.mesh = marker_mesh
		marker.position = Vector3(0.0, 2.8, 0.0)
		marker.material_override = _make_material(Color(0.95, 0.9, 0.35), true)
		creature.add_child(marker)

		creature.position = Vector3(randf_range(-35.0, 35.0), 0.0, randf_range(-35.0, 35.0))
		add_child(creature)
		roamers.append({
			"node": creature,
			"name": str(data["name"]),
			"target": Vector3(randf_range(-38.0, 38.0), 0.0, randf_range(-38.0, 38.0)),
			"speed": float(data["speed"]),
			"research": int(data["research"]),
			"observed": false
		})

func _make_material(color: Color, glow: bool) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	if glow:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = 0.65
	return material

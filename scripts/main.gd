extends Node3D

const MOVE_SPEED := 8.0
const PICKUP_DISTANCE := 2.4

var player: CharacterBody3D
var camera: Camera3D
var hud: Label
var status_label: Label
var objective_label: Label
var sync_label: Label
var pilot_sync: PilotSyncManager
var rift_manager: PacificRiftManager
var resources := {"metal": 0, "energia": 0, "cristal": 0}
var base_level := 1
var titan_level := 1
var collected_nodes: Array[Node3D] = []
var world_time := 0.0

func _ready() -> void:
	_setup_input()
	_create_world()
	_create_player()
	_create_gameplay_systems()
	_create_hud()
	_spawn_resources()
	_update_hud()

func _process(delta: float) -> void:
	world_time += delta
	if player and camera:
		var target := player.global_position + Vector3(0, 13, 17)
		camera.global_position = camera.global_position.lerp(target, min(delta * 4.0, 1.0))
		camera.look_at(player.global_position + Vector3(0, 1, 0), Vector3.UP)
	_try_collect_nearby()
	if pilot_sync and player:
		player.set("sync_multiplier", 1.35 if pilot_sync.is_synchronized else 1.0)
	if objective_label and rift_manager:
		objective_label.text = rift_manager.get_objective_text()
	if sync_label and pilot_sync:
		sync_label.text = pilot_sync.get_status_text()

func _physics_process(_delta: float) -> void:
	# El movimiento ahora pertenece al controlador del Titán Alfa.
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("collect"):
		_try_collect_nearby(true)
	if event.is_action_pressed("upgrade_base"):
		_upgrade_base()
	if event.is_action_pressed("evolve_titan"):
		_evolve_titan()

func _setup_input() -> void:
	_add_key("move_forward", KEY_W)
	_add_key("move_forward", KEY_UP)
	_add_key("move_back", KEY_S)
	_add_key("move_back", KEY_DOWN)
	_add_key("move_left", KEY_A)
	_add_key("move_left", KEY_LEFT)
	_add_key("move_right", KEY_D)
	_add_key("move_right", KEY_RIGHT)
	_add_key("collect", KEY_E)
	_add_key("upgrade_base", KEY_B)
	_add_key("evolve_titan", KEY_T)
	_add_key("sync_pilots", KEY_F)
	_add_key("stabilize_rift", KEY_R)

func _add_key(action: String, keycode: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	InputMap.action_add_event(action, event)

func _create_world() -> void:
	var env := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	environment.sky = Sky.new()
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.55, 0.68, 0.78)
	environment.ambient_light_energy = 0.8
	env.environment = environment
	add_child(env)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52, -28, 0)
	sun.light_energy = 1.25
	add_child(sun)

	var ground := StaticBody3D.new()
	ground.name = "Terreno"
	var ground_mesh := MeshInstance3D.new()
	var plane := BoxMesh.new()
	plane.size = Vector3(100, 1, 100)
	ground_mesh.mesh = plane
	ground_mesh.position.y = -0.5
	ground_mesh.material_override = _material(Color(0.16, 0.28, 0.19))
	ground.add_child(ground_mesh)
	var ground_collision := CollisionShape3D.new()
	var ground_shape := BoxShape3D.new()
	ground_shape.size = Vector3(100, 1, 100)
	ground_collision.shape = ground_shape
	ground_collision.position.y = -0.5
	ground.add_child(ground_collision)
	add_child(ground)

	_create_base_visual(Vector3(0, 0, -8))
	_create_rocks_and_trees()

	camera = Camera3D.new()
	camera.position = Vector3(0, 13, 17)
	camera.current = true
	camera.fov = 70
	add_child(camera)

func _create_player() -> void:
	var titan_scene := load("res://scenes/characters/titans/titan_alpha.tscn") as PackedScene
	if titan_scene == null:
		push_error("No se pudo cargar la escena de Titán Alfa.")
		return
	player = titan_scene.instantiate() as CharacterBody3D
	if player == null:
		push_error("La escena de Titán Alfa necesita un CharacterBody3D como raíz.")
		return
	player.name = "TitanAlfa"
	player.position = Vector3(0, 0, 2)
	add_child(player)

func _create_gameplay_systems() -> void:
	pilot_sync = PilotSyncManager.new()
	pilot_sync.name = "PilotSyncManager"
	add_child(pilot_sync)
	pilot_sync.synchronization_started.connect(_on_synchronization_started)
	pilot_sync.synchronization_ended.connect(_on_synchronization_ended)

	rift_manager = PacificRiftManager.new()
	rift_manager.name = "PacificRiftManager"
	add_child(rift_manager)
	rift_manager.rift_stabilized.connect(_on_rift_stabilized)

func _on_synchronization_started() -> void:
	_show_status("¡Enlace de pilotos sincronizado! Movilidad mejorada temporalmente.")

func _on_synchronization_ended() -> void:
	_show_status("El enlace de pilotos volvió al modo de espera.")

func _on_rift_stabilized(_index: int, reward: Dictionary) -> void:
	for resource_id in reward.keys():
		resources[resource_id] = int(resources.get(resource_id, 0)) + int(reward[resource_id])
	_update_hud()
	_show_status("¡Brecha estabilizada! Recompensas: +5 metal, +3 energía, +2 cristal.")

func _create_base_visual(pos: Vector3) -> void:
	var base := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(8, 1.4, 6)
	base.mesh = mesh
	base.position = pos + Vector3(0, 0.7, 0)
	base.material_override = _material(Color(0.23, 0.34, 0.42))
	add_child(base)
	var beacon := MeshInstance3D.new()
	var pillar := CylinderMesh.new()
	pillar.top_radius = 0.35
	pillar.bottom_radius = 0.6
	pillar.height = 4
	beacon.mesh = pillar
	beacon.position = pos + Vector3(0, 3.4, 0)
	beacon.material_override = _material(Color(0.15, 0.8, 1.0), true)
	add_child(beacon)

func _create_rocks_and_trees() -> void:
	for i in range(28):
		var x := randf_range(-42, 42)
		var z := randf_range(-42, 42)
		if absf(x) < 7 and z > -14 and z < 9:
			continue
		var rock := MeshInstance3D.new()
		var mesh := SphereMesh.new()
		mesh.radius = randf_range(0.5, 1.5)
		mesh.height = mesh.radius * 1.5
		rock.mesh = mesh
		rock.position = Vector3(x, mesh.radius * 0.45, z)
		rock.scale = Vector3(1.3, 0.8, 1.0)
		rock.material_override = _material(Color(0.22, 0.25, 0.26))
		add_child(rock)

func _spawn_resources() -> void:
	var kinds := ["metal", "energia", "cristal"]
	var colors := [Color(0.65, 0.7, 0.75), Color(0.2, 0.9, 1.0), Color(0.72, 0.3, 1.0)]
	for i in range(24):
		var kind_index := i % 3
		var node := Node3D.new()
		node.name = "Recurso_" + kinds[kind_index]
		node.set_meta("resource_type", kinds[kind_index])
		node.set_meta("resource_amount", 2 if kind_index == 0 else 1)
		var mesh_instance := MeshInstance3D.new()
		var mesh := SphereMesh.new()
		mesh.radius = 0.55
		mesh.height = 1.1
		mesh_instance.mesh = mesh
		mesh_instance.material_override = _material(colors[kind_index], true)
		node.add_child(mesh_instance)
		node.position = Vector3(randf_range(-35, 35), 0.8, randf_range(-35, 35))
		if node.position.distance_to(Vector3(0, 0, 2)) < 7:
			node.position.x += 12
		add_child(node)
		collected_nodes.append(node)

func _try_collect_nearby(show_message: bool = false) -> void:
	for node in collected_nodes.duplicate():
		if not is_instance_valid(node):
			collected_nodes.erase(node)
			continue
		if player.global_position.distance_to(node.global_position) <= PICKUP_DISTANCE:
			var kind: String = node.get_meta("resource_type")
			var amount: int = node.get_meta("resource_amount")
			resources[kind] += amount
			collected_nodes.erase(node)
			node.queue_free()
			_update_hud()
			_show_status("+" + str(amount) + " " + kind.to_upper() + " recolectado")
			return
	if show_message:
		_show_status("Acércate a un recurso brillante para recogerlo")

func _upgrade_base() -> void:
	var cost_metal := base_level * 8
	var cost_energy := base_level * 4
	if resources["metal"] >= cost_metal and resources["energia"] >= cost_energy:
		resources["metal"] -= cost_metal
		resources["energia"] -= cost_energy
		base_level += 1
		_show_status("¡Base mejorada al nivel " + str(base_level) + "!")
	else:
		_show_status("Faltan recursos: " + str(cost_metal) + " metal y " + str(cost_energy) + " energía")
	_update_hud()

func _evolve_titan() -> void:
	var cost_crystal := titan_level * 5
	var cost_energy := titan_level * 6
	if resources["cristal"] >= cost_crystal and resources["energia"] >= cost_energy:
		resources["cristal"] -= cost_crystal
		resources["energia"] -= cost_energy
		titan_level += 1
		player.scale = Vector3.ONE * (1.0 + (titan_level - 1) * 0.12)
		_show_status("¡Tu titán ha evolucionado al nivel " + str(titan_level) + "!")
	else:
		_show_status("Para evolucionar necesitas " + str(cost_crystal) + " cristal y " + str(cost_energy) + " energía")
	_update_hud()

func _create_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := PanelContainer.new()
	panel.position = Vector2(18, 18)
	panel.custom_minimum_size = Vector2(340, 170)
	layer.add_child(panel)
	var column := VBoxContainer.new()
	panel.add_child(column)
	var heading := Label.new()
	heading.text = "TITANES DEL PACÍFICO"
	heading.add_theme_font_size_override("font_size", 22)
	column.add_child(heading)
	hud = Label.new()
	hud.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(hud)
	objective_label = Label.new()
	objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(objective_label)
	sync_label = Label.new()
	column.add_child(sync_label)
	var help := Label.new()
	help.text = "WASD/Flechas: mover | E: recoger | B: base | T: evolucionar\nMantén F: sincronizar pilotos | Mantén R: estabilizar brecha"
	help.add_theme_font_size_override("font_size", 13)
	column.add_child(help)
	status_label = Label.new()
	status_label.position = Vector2(20, 205)
	status_label.add_theme_font_size_override("font_size", 18)
	layer.add_child(status_label)

func _update_hud() -> void:
	if not hud:
		return
	hud.text = "RECURSOS\nMetal: %d   Energía: %d   Cristal: %d\n\nBASE: nivel %d     TITÁN: nivel %d" % [resources["metal"], resources["energia"], resources["cristal"], base_level, titan_level]

func _show_status(message: String) -> void:
	if status_label:
		status_label.text = message

func _material(color: Color, glow: bool = false) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	if glow:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = 1.5
	return material

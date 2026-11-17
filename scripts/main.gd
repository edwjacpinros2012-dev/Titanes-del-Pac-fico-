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
var trade_manager: TradeManager
var contract_manager: ContractManager
var helicopter_manager: HelicopterScoutManager
var creature_manager: CreatureEcosystemManager
var contracts_label: Label
var helicopter_label: Label
var creature_label: Label
var market_label: Label
var market_open: bool = false
var research_data: int = 0
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
	if contracts_label and contract_manager:
		contracts_label.text = contract_manager.get_summary_text()
	if helicopter_label and helicopter_manager:
		helicopter_label.text = helicopter_manager.get_status_text()
	if creature_label and creature_manager:
		creature_label.text = creature_manager.get_status_text()
	if market_label and market_open and trade_manager:
		market_label.text = trade_manager.get_market_text()

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
	if event.is_action_pressed("market_toggle"):
		market_open = not market_open
		if market_label:
			market_label.visible = market_open
		_show_status("Canal comercial abierto." if market_open else "Canal comercial cerrado.")
	if event.is_action_pressed("scout_helicopters"):
		if helicopter_manager and player:
			if helicopter_manager.dispatch_scout(player.global_position):
				_show_status("Helicópteros enviados a reconocer el sector.")
			else:
				_show_status("Los helicópteros ya están en una misión.")
	if market_open:
		_handle_market_input(event)

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
	_add_key("market_toggle", KEY_C)
	_add_key("scout_helicopters", KEY_H)
	_add_key("market_buy_metal", KEY_1)
	_add_key("market_buy_energy", KEY_2)
	_add_key("market_buy_crystal", KEY_3)
	_add_key("market_sell_metal", KEY_4)
	_add_key("market_sell_energy", KEY_5)
	_add_key("market_sell_crystal", KEY_6)

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

	trade_manager = TradeManager.new()
	trade_manager.name = "TradeManager"
	add_child(trade_manager)
	trade_manager.trade_completed.connect(_on_trade_completed)

	contract_manager = ContractManager.new()
	contract_manager.name = "ContractManager"
	add_child(contract_manager)
	contract_manager.contract_completed.connect(_on_contract_completed)

	helicopter_manager = HelicopterScoutManager.new()
	helicopter_manager.name = "HelicopterScoutManager"
	add_child(helicopter_manager)
	helicopter_manager.scouting_completed.connect(_on_scouting_completed)

	creature_manager = CreatureEcosystemManager.new()
	creature_manager.name = "CreatureEcosystemManager"
	add_child(creature_manager)
	creature_manager.set_player_target(player)
	creature_manager.creature_observed.connect(_on_creature_observed)

func _on_creature_observed(display_name: String, research_reward: int) -> void:
	research_data += research_reward
	_update_hud()
	_show_status("Nueva especie registrada: " + display_name + " | +" + str(research_reward) + " datos de investigación.")

func _on_synchronization_started() -> void:
	_show_status("¡Enlace de pilotos sincronizado! Movilidad mejorada temporalmente.")

func _on_synchronization_ended() -> void:
	_show_status("El enlace de pilotos volvió al modo de espera.")

func _on_rift_stabilized(_index: int, reward: Dictionary) -> void:
	for resource_id in reward.keys():
		resources[resource_id] = int(resources.get(resource_id, 0)) + int(reward[resource_id])
	contract_manager.register_action("rift")
	_update_hud()
	_show_status("¡Brecha estabilizada! Recompensas: +5 metal, +3 energía, +2 cristal.")

func _on_scouting_completed(reward: Dictionary) -> void:
	for resource_id in reward.keys():
		if resource_id == "research_data":
			research_data += int(reward[resource_id])
		else:
			resources[resource_id] = int(resources.get(resource_id, 0)) + int(reward[resource_id])
	contract_manager.register_action("scout")
	_update_hud()
	_show_status("Reconocimiento completado: llegaron materiales y datos de investigación.")

func _on_contract_completed(title: String, reward: Dictionary) -> void:
	for reward_id in reward.keys():
		if reward_id == "credits":
			trade_manager.add_credits(int(reward[reward_id]))
		elif reward_id == "research_data":
			research_data += int(reward[reward_id])
		else:
			resources[reward_id] = int(resources.get(reward_id, 0)) + int(reward[reward_id])
	_update_hud()
	_show_status("Contrato completado: " + title + " | recompensa recibida.")

func _on_trade_completed(_good_id: String, _direction: String, _quantity: int) -> void:
	contract_manager.register_action("trade")
	_update_hud()

func _handle_market_input(event: InputEvent) -> void:
	var completed_trade := false
	if event.is_action_pressed("market_buy_metal"):
		completed_trade = trade_manager.buy_good("metal", 3, resources)
	elif event.is_action_pressed("market_buy_energy"):
		completed_trade = trade_manager.buy_good("energia", 3, resources)
	elif event.is_action_pressed("market_buy_crystal"):
		completed_trade = trade_manager.buy_good("cristal", 2, resources)
	elif event.is_action_pressed("market_sell_metal"):
		completed_trade = trade_manager.sell_good("metal", 3, resources)
	elif event.is_action_pressed("market_sell_energy"):
		completed_trade = trade_manager.sell_good("energia", 3, resources)
	elif event.is_action_pressed("market_sell_crystal"):
		completed_trade = trade_manager.sell_good("cristal", 2, resources)
	if completed_trade:
		_show_status(trade_manager.last_message)
	else:
		if event.is_action_pressed("market_buy_metal") or event.is_action_pressed("market_buy_energy") or event.is_action_pressed("market_buy_crystal") or event.is_action_pressed("market_sell_metal") or event.is_action_pressed("market_sell_energy") or event.is_action_pressed("market_sell_crystal"):
			_show_status(trade_manager.last_message)
	_update_hud()

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
	panel.custom_minimum_size = Vector2(470, 370)
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
	helicopter_label = Label.new()
	column.add_child(helicopter_label)
	creature_label = Label.new()
	column.add_child(creature_label)
	contracts_label = Label.new()
	contracts_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(contracts_label)
	market_label = Label.new()
	market_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	market_label.visible = false
	column.add_child(market_label)
	var help := Label.new()
	help.text = "WASD: mover | E: recoger | B: base | T: evolucionar | F: enlace\nR: estabilizar brecha | H: helicópteros | C: mercado\nMercado abierto: 1-3 comprar | 4-6 vender"
	help.add_theme_font_size_override("font_size", 13)
	column.add_child(help)
	status_label = Label.new()
	status_label.position = Vector2(20, 390)
	status_label.add_theme_font_size_override("font_size", 18)
	layer.add_child(status_label)

func _update_hud() -> void:
	if not hud:
		return
	hud.text = "RECURSOS\nMetal: %d   Energía: %d   Cristal: %d\nDatos de investigación: %d\nCréditos: %d\nBASE: nivel %d     TITÁN: nivel %d" % [resources["metal"], resources["energia"], resources["cristal"], research_data, trade_manager.credits if trade_manager else 0, base_level, titan_level]

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

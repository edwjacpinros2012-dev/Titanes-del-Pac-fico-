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
var npc_manager: NpcPopulationManager
var npc_label: Label
var kaiju_war: KaijuWarManager
var damage_model: CentinelDamageModel
var warfront_state: WarfrontStateManager
var campaign: CampaignManager
var alliance_manager: AllianceManager
var base_development: BaseDevelopmentManager
var technology_tree: TechnologyTreeManager
var technology_label: Label
var base_label: Label
var platform_input: PlatformInput
var kaiju_label: Label
var alliance_label: Label
var community_client: CommunityClient
var online_status_label: Label
var online_email: LineEdit
var online_password: LineEdit
var online_handle: LineEdit
var online_chat_input: LineEdit
var online_chat_log: Label
var online_alliance_name: LineEdit
var online_alliance_tag: LineEdit
var online_alliance_id: LineEdit
var online_alliance_log: Label
var online_safety_user_id: LineEdit
var contracts_label: Label
var helicopter_label: Label
var creature_label: Label
var market_label: Label
var gameplay_loop: GameLoopManager
var loop_status_label: Label
var market_open: bool = false
var research_data: int = 0
var resources := {"metal": 80, "energia": 45, "cristal": 12}
var base_level := 1
var titan_level := 1
var collected_nodes: Array[Node3D] = []
var world_time := 0.0
var autosave_elapsed := 0.0
var syncing_game_state := false
const AUTOSAVE_INTERVAL := 60.0

func _ready() -> void:
	if not GlobalState.resources_changed.is_connected(_on_global_resources_changed):
		GlobalState.resources_changed.connect(_on_global_resources_changed)
	_setup_input()
	_create_world()
	_create_player()
	_create_gameplay_systems()
	_create_hud()
	_load_local_profile()
	_sync_global_state_from_local()
	var field_director := get_node_or_null("FieldCombatDirector")
	if field_director != null and field_director.has_signal("mission_completed"):
		field_director.connect("mission_completed", _on_field_mission_completed)
	_apply_technology_effects()
	_spawn_resources()
	_update_hud()

func _process(delta: float) -> void:
	world_time += delta
	autosave_elapsed += delta
	if autosave_elapsed >= AUTOSAVE_INTERVAL:
		autosave_elapsed = 0.0
		_save_local_profile()
	if player and camera:
		var target := player.global_position + Vector3(0, 13, 17)
		camera.global_position = camera.global_position.lerp(target, min(delta * 4.0, 1.0))
		camera.look_at(player.global_position + Vector3(0, 1, 0), Vector3.UP)
	_try_collect_nearby()
	if pilot_sync and player:
		var tech_mobility := technology_tree.get_mobility_multiplier() if technology_tree else 1.0
		player.set("research_speed_multiplier", tech_mobility)
		player.set("sync_multiplier", 1.35 if pilot_sync.is_synchronized else 1.0)
		player.set("damage_speed_multiplier", damage_model.get_mobility_multiplier() if damage_model else 1.0)
	if kaiju_war and damage_model:
		kaiju_war.set_damage_penalty(damage_model.get_power_penalty())
	if objective_label and rift_manager:
		objective_label.text = rift_manager.get_objective_text()
	if loop_status_label and gameplay_loop:
		loop_status_label.text = gameplay_loop.get_status_text()
	if sync_label and pilot_sync:
		sync_label.text = pilot_sync.get_status_text()
	if contracts_label and contract_manager:
		contracts_label.text = contract_manager.get_summary_text()
	if helicopter_label and helicopter_manager:
		helicopter_label.text = helicopter_manager.get_status_text()
	if creature_label and creature_manager:
		creature_label.text = creature_manager.get_status_text()
	if npc_label and npc_manager:
		npc_label.text = npc_manager.get_status_text()
	if market_label and market_open and trade_manager:
		market_label.text = trade_manager.get_market_text()
	if kaiju_label and kaiju_war:
		kaiju_label.text = kaiju_war.get_status_text() + ("\n" + warfront_state.get_status_text() if warfront_state else "")
	if alliance_label and alliance_manager:
		alliance_label.text = alliance_manager.get_summary()
	if base_development:
		if base_development.advance_production(delta, resources) > 0:
			_update_hud()
	if base_label and base_development:
		base_label.text = base_development.get_status_text()
	if technology_label and technology_tree:
		technology_label.text = technology_tree.get_selected_text(research_data)

func _physics_process(_delta: float) -> void:
	# El movimiento ahora pertenece al controlador del Titán Alfa.
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("collect"):
		_try_collect_nearby(true)
	if event.is_action_pressed("talk_npc"):
		_interact_with_npc()
	if event.is_action_pressed("upgrade_base"):
		_upgrade_base()
	if event.is_action_pressed("base_select_next") and base_development:
		base_development.select_next_facility(base_level)
		_show_status(base_development.get_selected_facility_text(resources, base_level))
	if event.is_action_pressed("base_upgrade_selected"):
		_upgrade_selected_facility()
	if event.is_action_pressed("evolve_titan"):
		_evolve_titan()
	if event.is_action_pressed("market_toggle"):
		market_open = not market_open
		if market_label:
			market_label.visible = market_open
		_show_status("Canal comercial abierto." if market_open else "Canal comercial cerrado.")
	if event.is_action_pressed("kaiju_engage") and kaiju_war:
		if not kaiju_war.is_encounter_active:
			kaiju_war.begin_encounter()
			_show_status("¡Abisal localizado! Analiza su rol y elige táctica antes de resolver.")
		else:
			kaiju_war.resolve_battle("engage")
	if event.is_action_pressed("tactic_flank") and kaiju_war:
		if kaiju_war.select_tactic("flank"):
			_show_status("TÁCTICA: FLANQUEO. " + kaiju_war.last_tactic_feedback)
	if event.is_action_pressed("tactic_guard") and kaiju_war:
		if kaiju_war.select_tactic("guard"):
			_show_status("TÁCTICA: DEFENSA. " + kaiju_war.last_tactic_feedback)
	if event.is_action_pressed("tactic_precision") and kaiju_war:
		if kaiju_war.select_tactic("precision"):
			_show_status("TÁCTICA: PRECISIÓN. " + kaiju_war.last_tactic_feedback)
	if event.is_action_pressed("kaiju_retreat") and kaiju_war:
		kaiju_war.resolve_battle("retreat")
	if event.is_action_pressed("repair_titan") and damage_model:
		var repaired := damage_model.repair_with_resources(resources)
		if repaired > 0 and npc_manager:
			npc_manager.register_action("repair")
		_show_status("Reparación completada: %d puntos. Se consumieron metal y energía." % repaired if repaired > 0 else "Faltan metal y energía o el Centinela ya está reparado.")
		_update_hud()
	if event.is_action_pressed("alliance_join") and alliance_manager:
		if alliance_manager.join_demo_alliance():
			_show_status("Te has unido a Guardianes del Abismo. Alianza de demostración local.")
	if event.is_action_pressed("alliance_create") and alliance_manager:
		if alliance_manager.create_alliance("Vanguardia del Pacífico", "VDP"):
			_show_status("Alianza local creada: Vanguardia del Pacífico.")
	if event.is_action_pressed("expedition_toggle"):
		_toggle_expedition()
	if event.is_action_pressed("save_profile"):
		_save_local_profile()
	if event.is_action_pressed("tech_select_next"):
		_select_next_technology()
	if event.is_action_pressed("tech_research"):
		_research_selected_technology()
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
	_add_key("base_select_next", KEY_V)
	_add_key("base_upgrade_selected", KEY_N)
	_add_key("evolve_titan", KEY_T)
	_add_key("sync_pilots", KEY_F)
	_add_key("stabilize_rift", KEY_R)
	_add_key("market_toggle", KEY_C)
	_add_key("scout_helicopters", KEY_H)
	_add_key("kaiju_engage", KEY_J)
	_add_key("kaiju_retreat", KEY_G)
	_add_key("repair_titan", KEY_Y)
	_add_key("talk_npc", KEY_Z)
	_add_key("expedition_toggle", KEY_M)
	_add_key("tactic_flank", KEY_Q)
	_add_key("tactic_guard", KEY_X)
	_add_key("tactic_precision", KEY_U)
	_add_key("alliance_join", KEY_K)
	_add_key("alliance_create", KEY_P)
	_add_key("save_profile", KEY_F5)
	_add_key("tech_select_next", KEY_O)
	_add_key("tech_research", KEY_I)
	_add_key("market_buy_metal", KEY_1)
	_add_key("market_buy_energy", KEY_2)
	_add_key("market_buy_crystal", KEY_3)
	_add_key("market_sell_metal", KEY_4)
	_add_key("market_sell_energy", KEY_5)
	_add_key("market_sell_crystal", KEY_6)
	_add_gamepad_axis("move_left", JOY_AXIS_LEFT_X, -1.0)
	_add_gamepad_axis("move_right", JOY_AXIS_LEFT_X, 1.0)
	_add_gamepad_axis("move_forward", JOY_AXIS_LEFT_Y, -1.0)
	_add_gamepad_axis("move_back", JOY_AXIS_LEFT_Y, 1.0)
	_add_gamepad_button("collect", JOY_BUTTON_A)
	_add_gamepad_button("kaiju_engage", JOY_BUTTON_X)
	_add_gamepad_button("evolve_titan", JOY_BUTTON_Y)
	_add_gamepad_button("kaiju_retreat", JOY_BUTTON_B)

func _add_key(action: String, keycode: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for existing in InputMap.action_get_events(action):
		if existing is InputEventKey and existing.physical_keycode == keycode:
			return
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	InputMap.action_add_event(action, event)

func _add_gamepad_axis(action: String, axis: JoyAxis, axis_value: float) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for existing in InputMap.action_get_events(action):
		if existing is InputEventJoypadMotion and existing.axis == axis and is_equal_approx(existing.axis_value, axis_value):
			return
	var event := InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = axis_value
	InputMap.action_add_event(action, event)

func _add_gamepad_button(action: String, button_index: JoyButton) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for existing in InputMap.action_get_events(action):
		if existing is InputEventJoypadButton and existing.button_index == button_index:
			return
	var event := InputEventJoypadButton.new()
	event.button_index = button_index
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
	_create_coastal_city()

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

	npc_manager = NpcPopulationManager.new()
	npc_manager.name = "NpcPopulationManager"
	add_child(npc_manager)

	kaiju_war = KaijuWarManager.new()
	kaiju_war.name = "KaijuWarManager"
	add_child(kaiju_war)
	kaiju_war.set_player_target(player)
	kaiju_war.battle_resolved.connect(_on_kaiju_battle_resolved)

	damage_model = CentinelDamageModel.new()
	damage_model.name = "CentinelDamageModel"
	add_child(damage_model)

	warfront_state = WarfrontStateManager.new()
	warfront_state.name = "WarfrontStateManager"
	add_child(warfront_state)

	campaign = CampaignManager.new()
	campaign.name = "CampaignManager"
	add_child(campaign)
	campaign.chapter_changed.connect(_on_campaign_chapter_changed)

	alliance_manager = AllianceManager.new()
	alliance_manager.name = "AllianceManager"
	add_child(alliance_manager)
	alliance_manager.alliance_changed.connect(_on_alliance_changed)
	alliance_manager.message_added.connect(_on_alliance_message)

	technology_tree = TechnologyTreeManager.new()
	technology_tree.name = "TechnologyTreeManager"
	add_child(technology_tree)
	technology_tree.technology_unlocked.connect(_on_technology_unlocked)

	base_development = BaseDevelopmentManager.new()
	base_development.name = "BaseDevelopmentManager"
	add_child(base_development)
	base_development.research_generated.connect(_on_base_research_generated)

	gameplay_loop = GameLoopManager.new()
	gameplay_loop.name = "GameLoopManager"
	add_child(gameplay_loop)
	gameplay_loop.mission_completed.connect(_on_loop_mission_completed)
	gameplay_loop.expedition_completed.connect(_on_loop_expedition_completed)
	gameplay_loop.world_event_started.connect(_on_loop_event_started)
	gameplay_loop.world_event_ended.connect(_on_loop_event_ended)
	gameplay_loop.region_unlocked.connect(_on_loop_region_unlocked)
	gameplay_loop.status_changed.connect(_show_status)

	community_client = CommunityClient.new()
	community_client.name = "CommunityClient"
	add_child(community_client)
	community_client.auth_changed.connect(_on_online_auth_changed)
	community_client.request_failed.connect(_on_online_error)

func _on_base_research_generated(amount: int) -> void:
	research_data += amount
	_update_hud()

func _on_creature_observed(display_name: String, research_reward: int) -> void:
	if npc_manager:
		npc_manager.register_action("observe")
	if alliance_manager:
		alliance_manager.register_objective("research")
	research_data += research_reward
	_update_hud()
	_show_status("Nueva especie registrada: " + display_name + " | +" + str(research_reward) + " datos de investigación.")

func _on_synchronization_started() -> void:
	_show_status("¡Enlace de pilotos sincronizado! Movilidad mejorada temporalmente.")

func _on_synchronization_ended() -> void:
	_show_status("El enlace de pilotos volvió al modo de espera.")

func _on_rift_stabilized(_index: int, reward: Dictionary) -> void:
	for resource_id in reward.keys():
		_add_resource(resource_id, int(reward[resource_id]))
	contract_manager.register_action("rift")
	if npc_manager:
		npc_manager.register_action("rift")
	_update_hud()
	_show_status("¡Brecha estabilizada! Recompensas: +5 metal, +3 energía, +2 cristal.")

func _on_scouting_completed(reward: Dictionary, scan_center: Vector3) -> void:
	for resource_id in reward.keys():
		if resource_id == "research_data":
			research_data += int(reward[resource_id])
		else:
			_add_resource(resource_id, int(reward[resource_id]))
	var scan_radius := base_development.get_scouting_radius(30.0) if base_development else 30.0
	var discovered := creature_manager.reveal_nearby(scan_center, scan_radius) if creature_manager else 0
	contract_manager.register_action("scout")
	if npc_manager:
		npc_manager.register_action("scout")
	if alliance_manager:
		alliance_manager.register_objective("scout")
	_update_hud()
	_show_status("Reconocimiento completado: %d especies detectadas y materiales recuperados." % discovered)

func _on_contract_completed(title: String, reward: Dictionary) -> void:
	for reward_id in reward.keys():
		if reward_id == "credits":
			trade_manager.add_credits(int(reward[reward_id]))
		elif reward_id == "research_data":
			research_data += int(reward[reward_id])
		else:
			_add_resource(reward_id, int(reward[reward_id]))
	_update_hud()
	if campaign:
		campaign.add_experience(2)
		if kaiju_war:
			kaiju_war.set_progression(campaign.player_level, campaign.jaeger_generation)
	_show_status("Contrato completado: " + title + " | recompensa recibida.")

func _on_trade_completed(_good_id: String, _direction: String, _quantity: int) -> void:
	contract_manager.register_action("trade")
	if npc_manager:
		npc_manager.register_action("trade")
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

func _create_coastal_city() -> void:
	var ocean := MeshInstance3D.new()
	var ocean_mesh := BoxMesh.new()
	ocean_mesh.size = Vector3(100, 0.18, 38)
	ocean.mesh = ocean_mesh
	ocean.position = Vector3(0, -0.04, -60)
	ocean.material_override = _material(Color(0.025, 0.13, 0.2))
	add_child(ocean)

	var shoreline := MeshInstance3D.new()
	var shore_mesh := BoxMesh.new()
	shore_mesh.size = Vector3(100, 0.12, 9)
	shoreline.mesh = shore_mesh
	shoreline.position = Vector3(0, 0.015, -34)
	shoreline.material_override = _material(Color(0.42, 0.37, 0.27))
	add_child(shoreline)

	var city_palette := [
		Color(0.12, 0.19, 0.25),
		Color(0.18, 0.25, 0.3),
		Color(0.23, 0.29, 0.32),
		Color(0.1, 0.16, 0.22)
	]
	for index in range(14):
		var building := MeshInstance3D.new()
		var building_mesh := BoxMesh.new()
		var width := randf_range(3.2, 5.8)
		var depth := randf_range(3.0, 5.5)
		var height := randf_range(7.0, 19.0)
		building_mesh.size = Vector3(width, height, depth)
		building.mesh = building_mesh
		building.position = Vector3(-43.0 + float(index) * 6.6, height * 0.5, -39.0 + randf_range(-2.0, 2.0))
		building.material_override = _material(city_palette[index % city_palette.size()])
		add_child(building)

		var window_band := MeshInstance3D.new()
		var window_mesh := BoxMesh.new()
		window_mesh.size = Vector3(width * 0.72, 0.16, 0.08)
		window_band.mesh = window_mesh
		window_band.position = building.position + Vector3(0, randf_range(-height * 0.25, height * 0.25), depth * 0.5 + 0.045)
		window_band.material_override = _material(Color(0.15, 0.68, 0.82), true)
		add_child(window_band)

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
			if gameplay_loop:
				amount += gameplay_loop.get_event_bonus(kind)
				gameplay_loop.report_collection(kind, int(node.get_meta("resource_amount")))
			if npc_manager:
				npc_manager.register_action("collect")
			_add_resource(kind, amount)
			collected_nodes.erase(node)
			node.queue_free()
			_update_hud()
			_show_status("+" + str(amount) + " " + kind.to_upper() + " recolectado")
			return
	if show_message:
		_show_status("Acércate a un recurso brillante para recogerlo")

func _upgrade_base() -> void:
	if base_development and base_development.upgrade_facility("command_hub", resources, base_level):
		base_level = base_development.get_facility_level("command_hub")
		if npc_manager:
			npc_manager.register_base_upgrade()
		_show_status("Centro de mando mejorado. Base nivel %d." % base_level)
	else:
		_show_status(base_development.get_selected_facility_text(resources, base_level) if base_development else "Sistema de base no disponible.")
	_update_hud()

func _upgrade_selected_facility() -> void:
	if base_development == null:
		return
	var facility_id := base_development.get_selected_facility_id()
	if facility_id == "command_hub":
		_upgrade_base()
		return
	if base_development.upgrade_facility(facility_id, resources, base_level):
		if npc_manager:
			npc_manager.register_base_upgrade()
		_show_status("Instalación mejorada: " + base_development.get_facility_name(facility_id))
	else:
		_show_status(base_development.get_selected_facility_text(resources, base_level))
	_update_hud()

func _select_next_technology() -> void:
	if technology_tree:
		var selected_id := technology_tree.select_next()
		_show_status("Tecnología seleccionada: " + technology_tree.get_technology_name(selected_id))

func _research_selected_technology() -> void:
	if technology_tree == null:
		return
	var cost := technology_tree.research_selected(research_data)
	if cost < 0:
		_show_status(technology_tree.get_selected_text(research_data))
		return
	research_data -= cost
	_apply_technology_effects()
	_update_hud()
	_save_local_profile()
	_show_status("Investigación completada: " + technology_tree.get_technology_name(technology_tree.get_selected_id()))

func _on_technology_unlocked(_technology_id: String) -> void:
	_apply_technology_effects()

func _apply_technology_effects() -> void:
	if technology_tree == null:
		return
	if base_development:
		base_development.set_technology_effects(
			technology_tree.get_storage_bonus(),
			technology_tree.get_repair_discount_bonus(),
			technology_tree.get_scouting_bonus(),
			technology_tree.get_production_multiplier()
		)
	if kaiju_war:
		kaiju_war.set_research_power_bonus(technology_tree.get_combat_preparation_bonus())
	if player:
		player.set("research_speed_multiplier", technology_tree.get_mobility_multiplier())

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

func _on_platform_action(action_name: String) -> void:
	match action_name:
		"collect":
			_try_collect_nearby(true)
		"upgrade_base":
			_upgrade_base()
		"base_select_next":
			if base_development:
				base_development.select_next_facility(base_level)
				_show_status(base_development.get_selected_facility_text(resources, base_level))
		"base_upgrade_selected":
			_upgrade_selected_facility()
		"evolve_titan":
			_evolve_titan()
		"market_toggle":
			market_open = not market_open
			if market_label:
				market_label.visible = market_open
			_show_status("Canal comercial abierto." if market_open else "Canal comercial cerrado.")
		"kaiju_engage":
			if kaiju_war:
				if not kaiju_war.is_encounter_active:
					kaiju_war.begin_encounter()
					_show_status("Abisal localizado. Revisa su rol, elige táctica y pulsa J para resolver.")
				else:
					kaiju_war.resolve_battle("engage")
		"kaiju_retreat":
			if kaiju_war:
				kaiju_war.resolve_battle("retreat")
		"repair_titan":
			if damage_model:
				var repaired := damage_model.repair_with_resources(resources)
				if repaired > 0 and npc_manager:
					npc_manager.register_action("repair")
				_show_status("Reparación completada: %d puntos." % repaired if repaired > 0 else "Faltan recursos o el Centinela ya está reparado.")
				_update_hud()
		"tactic_flank":
			if kaiju_war and kaiju_war.select_tactic("flank"):
				_show_status("TÁCTICA: FLANQUEO. " + kaiju_war.last_tactic_feedback)
		"tactic_guard":
			if kaiju_war and kaiju_war.select_tactic("guard"):
				_show_status("TÁCTICA: DEFENSA. " + kaiju_war.last_tactic_feedback)
		"tactic_precision":
			if kaiju_war and kaiju_war.select_tactic("precision"):
				_show_status("TÁCTICA: PRECISIÓN. " + kaiju_war.last_tactic_feedback)
		"talk_npc":
			_interact_with_npc()
		"expedition_toggle":
			_toggle_expedition()
		"tech_select_next":
			_select_next_technology()
		"tech_research":
			_research_selected_technology()

func _create_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var viewport_size := get_viewport().get_visible_rect().size
	var hud_width := minf(440.0, maxf(280.0, viewport_size.x - 24.0))
	var hud_height := minf(340.0, maxf(150.0, viewport_size.y * 0.48))
	var panel := PanelContainer.new()
	panel.position = Vector2(12, 12)
	panel.custom_minimum_size = Vector2(hud_width, hud_height)
	panel.size = Vector2(hud_width, hud_height)
	layer.add_child(panel)
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_child(scroll)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(column)
	var heading := Label.new()
	heading.text = "TITANES DEL PACÍFICO"
	heading.add_theme_font_size_override("font_size", 22)
	column.add_child(heading)
	hud = Label.new()
	hud.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(hud)
	base_label = Label.new()
	base_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(base_label)
	objective_label = Label.new()
	objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(objective_label)
	loop_status_label = Label.new()
	loop_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(loop_status_label)
	sync_label = Label.new()
	column.add_child(sync_label)
	helicopter_label = Label.new()
	column.add_child(helicopter_label)
	kaiju_label = Label.new()
	kaiju_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(kaiju_label)
	technology_label = Label.new()
	technology_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(technology_label)
	alliance_label = Label.new()
	alliance_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(alliance_label)
	creature_label = Label.new()
	column.add_child(creature_label)
	npc_label = Label.new()
	npc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(npc_label)
	contracts_label = Label.new()
	contracts_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(contracts_label)
	market_label = Label.new()
	market_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	market_label.visible = false
	column.add_child(market_label)
	var help := Label.new()
	help.text = "WASD: mover | E: recoger | B: mejorar centro de mando | T: mejorar Jaeger\nV: elegir instalación | N: mejorar instalación | F: enlace | R: brecha\nH: helicópteros | J: enfrentar Abisal | G: retirarse | Z: hablar con NPC | M: expedición | F5: guardar\nK/P: alianza local | C: mercado | O: tecnología siguiente | I: investigar"
	help.add_theme_font_size_override("font_size", 13)
	column.add_child(help)
	status_label = Label.new()
	status_label.anchor_left = 0.02
	status_label.anchor_top = 0.54
	status_label.anchor_right = 0.98
	status_label.anchor_bottom = 0.68
	status_label.offset_left = 0
	status_label.offset_top = 0
	status_label.offset_right = 0
	status_label.offset_bottom = 0
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_font_size_override("font_size", 18)
	layer.add_child(status_label)
	platform_input = PlatformInput.new()
	platform_input.name = "PlatformInput"
	platform_input.action_tapped.connect(_on_platform_action)
	layer.add_child(platform_input)
	_create_online_panel(layer)

func _add_resource(resource_id: String, amount: int) -> void:
	if amount <= 0:
		return
	var capacity := base_development.get_storage_capacity() if base_development else 250
	var current_amount := int(resources.get(resource_id, 0))
	resources[resource_id] = mini(capacity, current_amount + amount)
	_sync_global_state_from_local()

func _update_hud() -> void:
	if not hud:
		return
	hud.text = "RECURSOS\nMetal: %d   Energía: %d   Cristal: %d\nDatos de investigación: %d\nCréditos: %d\nBASE: nivel %d     TITÁN: nivel %d" % [resources["metal"], resources["energia"], resources["cristal"], research_data, trade_manager.credits if trade_manager else 0, base_level, titan_level]

func _show_status(message: String) -> void:
	if status_label:
		status_label.text = message

func _interact_with_npc() -> void:
	if npc_manager == null or player == null:
		return
	var result: Dictionary = npc_manager.interact_nearest(player)
	var message := str(result.get("message",""))
	var reward: Dictionary = result.get("reward",{})
	for reward_id in reward.keys():
		if reward_id == "credits":
			if trade_manager:
				trade_manager.add_credits(int(reward[reward_id]))
		elif reward_id == "research_data":
			research_data += int(reward[reward_id])
		else:
			_add_resource(str(reward_id), int(reward[reward_id]))
	_show_status(message)
	_update_hud()
	if not reward.is_empty():
		_save_local_profile()

func _material(color: Color, glow: bool = false) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	if glow:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = 1.5
	return material

func _on_loop_mission_completed(mission_id: String, reward: Dictionary) -> void:
	_apply_loop_reward(reward)
	_show_status("Misión %s completada: recompensa recibida." % mission_id)
	_update_hud()
	_save_local_profile()

func _on_loop_expedition_completed(region_id: String, reward: Dictionary) -> void:
	_apply_loop_reward(reward)
	_show_status("Expedición completada en %s: recompensas recuperadas." % region_id)
	_update_hud()
	_save_local_profile()

func _apply_loop_reward(reward: Dictionary) -> void:
	for id in reward:
		var amount := int(reward[id])
		if id == "credits":
			if trade_manager: trade_manager.add_credits(amount)
		elif id == "research_data":
			research_data += maxi(0, amount)
		else:
			_add_resource(str(id), amount)

func _on_loop_event_started(_event_id: String, title: String, resource_id: String, bonus: int) -> void:
	_show_status("EVENTO %s: recolecta %s para obtener +%d adicional." % [title, resource_id, bonus])

func _on_loop_event_ended(event_id: String) -> void:
	_show_status("Evento regional finalizado: " + event_id)

func _on_loop_region_unlocked(region_id: String) -> void:
	_show_status("¡Nueva región desbloqueada! " + str(GameLoopManager.REGIONS.get(region_id, {}).get("title", region_id)))
	_save_local_profile()

func _toggle_expedition() -> void:
	if gameplay_loop == null: return
	if not gameplay_loop.active_expedition.is_empty():
		gameplay_loop.cancel_expedition()
		_show_status("Expedición cancelada.")
		return
	if not gameplay_loop.is_region_unlocked("broken_isles"):
		_show_status("Completa la misión inicial para desbloquear Islas Quebradas.")
		return
	if gameplay_loop.start_expedition("broken_isles", "cristal", 4, {"metal":6,"energia":4,"research_data":2}):
		_show_status("Expedición iniciada: reúne 4 cristal. M: cancelar.")

func _on_kaiju_battle_resolved(outcome: String, rewards: Dictionary, consequences: Dictionary) -> void:
	for key in rewards.keys():
		if key == "credits":
			trade_manager.add_credits(int(rewards[key]))
		elif key == "research_data":
			research_data += int(rewards[key])
		else:
			_add_resource(key, int(rewards[key]))
	if warfront_state:
		warfront_state.apply_battle_result(outcome, int(consequences.get("sector_pressure", 0)))
	if damage_model:
		damage_model.apply_battle_result(outcome, int(consequences.get("threat", 1)), str(consequences.get("tactic", "scan")), str(consequences.get("enemy_role", "stalker")))
	if npc_manager:
		npc_manager.register_battle_result(outcome)
		if outcome == "victory":
			npc_manager.register_action("victory")
	var repair_cost := int(consequences.get("repair", 0))
	var supply_loss := int(consequences.get("supply_loss", 0))
	if repair_cost > 0:
		var repair_discount := base_development.get_repair_discount() if base_development else 0.0
		var final_repair_cost := roundi(float(repair_cost) * (1.0 - repair_discount))
		resources["metal"] = maxi(0, int(resources["metal"]) - final_repair_cost)
	if supply_loss > 0:
		resources["energia"] = maxi(0, int(resources["energia"]) - supply_loss)
	if outcome == "victory":
		if campaign:
			campaign.add_experience(3)
		if alliance_manager:
			alliance_manager.register_objective("defense")
		_show_status("¡VICTORIA! Kaiju repelido. Recompensas añadidas.")
	elif outcome == "partial_success":
		if campaign:
			campaign.add_experience(1)
		_show_status("ÉXITO PARCIAL. El Kaiju se retira, pero tu Jaeger necesita reparación.")
	elif outcome == "retreat":
		_show_status("RETIRADA TÁCTICA. Conservas tu progreso; el sector sigue bajo amenaza.")
	else:
		_show_status("DERROTA. El Kaiju sigue activo. Has perdido suministros y debes reparar el Jaeger.")
	if campaign and kaiju_war:
		kaiju_war.set_progression(campaign.player_level, campaign.jaeger_generation)
	_update_hud()
	_save_local_profile()

func _on_campaign_chapter_changed(chapter_name: String, level: int) -> void:
	if kaiju_war and campaign:
		kaiju_war.set_progression(level, campaign.jaeger_generation)
	_show_status("Nueva etapa de guerra: " + chapter_name)

func _on_alliance_changed(_summary: String) -> void:
	_update_hud()

func _on_alliance_message(message: String) -> void:
	_show_status(message)

func _save_local_profile() -> void:
	_sync_global_state_from_local()
	var snapshot := {
		"version": 1,
		"resources": resources,
		"credits": trade_manager.credits if trade_manager else 250,
		"research_data": research_data,
		"base_level": base_level,
		"base_development": base_development.export_state() if base_development else {},
		"titan_level": titan_level,
		"campaign_level": campaign.player_level if campaign else 1,
		"jaeger_generation": campaign.jaeger_generation if campaign else 1,
		"selected_jaeger": GlobalState.selected_jaeger,
		"unlocked_jaegers": GlobalState.unlocked_jaegers.duplicate(),
		"jaeger_marks": GlobalState.jaeger_marks.duplicate(true),
		"alliance_name": alliance_manager.alliance_name if alliance_manager else "",
		"alliance_tag": alliance_manager.alliance_tag if alliance_manager else "",
		"alliance_rank": alliance_manager.rank if alliance_manager else "Sin alianza",
		"alliance_state": alliance_manager.export_state() if alliance_manager else {},
		"technology_state": technology_tree.export_state() if technology_tree else {},
		"warfront_state": warfront_state.export_state() if warfront_state else {},
		"kaiju_war_state": kaiju_war.export_state() if kaiju_war else {},
		"damage_model_state": damage_model.export_state() if damage_model else {},
		"npc_state": npc_manager.export_state() if npc_manager else {},
		"gameplay_loop_state": gameplay_loop.export_state() if gameplay_loop else {},
		"completed_field_missions": GlobalState.completed_missions.duplicate(),
		"field_combat": GlobalState.get_world_state_section("field_combat")
	}
	GlobalState.world_state = snapshot.duplicate(true)
	SaveSystem.save_game(GlobalState)
	SaveSystem.save_profile(snapshot)

func _load_local_profile() -> void:
	SaveSystem.load_game(GlobalState)
	var snapshot: Dictionary = SaveSystem.load_profile()
	if snapshot.is_empty():
		snapshot = GlobalState.world_state.duplicate(true)
	if snapshot.is_empty():
		return
	GlobalState.world_state = snapshot.duplicate(true)
	resources = snapshot.get("resources", resources)
	var saved_field_missions: Variant = snapshot.get("completed_field_missions", [])
	if saved_field_missions is Array:
		GlobalState.completed_missions.clear()
		for mission_value in saved_field_missions:
			var mission_id := str(mission_value).strip_edges()
			if not mission_id.is_empty() and mission_id not in GlobalState.completed_missions:
				GlobalState.completed_missions.append(mission_id)
	var saved_jaegers: Variant = snapshot.get("unlocked_jaegers", ["gipsy"])
	if saved_jaegers is Array:
		GlobalState.unlocked_jaegers.clear()
		GlobalState.unlocked_jaegers.append("gipsy")
		for jaeger_value in saved_jaegers:
			var jaeger_id := str(jaeger_value).strip_edges()
			if jaeger_id in GameState.JAEGER_IDS and jaeger_id not in GlobalState.unlocked_jaegers:
				GlobalState.unlocked_jaegers.append(jaeger_id)
	var saved_marks: Variant = snapshot.get("jaeger_marks", {})
	if saved_marks is Dictionary:
		for jaeger_id in GameState.JAEGER_IDS:
			var mark_value: Variant = saved_marks.get(jaeger_id, 1)
			if typeof(mark_value) == TYPE_INT or typeof(mark_value) == TYPE_FLOAT:
				GlobalState.jaeger_marks[jaeger_id] = clampi(int(mark_value), 1, 10)
	var saved_selected_jaeger := str(snapshot.get("selected_jaeger", "gipsy"))
	GlobalState.selected_jaeger = saved_selected_jaeger if saved_selected_jaeger in GlobalState.unlocked_jaegers else "gipsy"
	base_level = int(snapshot.get("base_level", base_level))
	if base_development:
		var saved_base: Variant = snapshot.get("base_development", {})
		if typeof(saved_base) == TYPE_DICTIONARY and not saved_base.is_empty():
			base_development.import_state(saved_base)
		else:
			base_development.set_legacy_base_level(base_level)
		base_level = base_development.get_facility_level("command_hub")
	titan_level = int(snapshot.get("titan_level", titan_level))
	research_data = int(snapshot.get("research_data", research_data))
	if trade_manager:
		trade_manager.credits = int(snapshot.get("credits", trade_manager.credits))
	if technology_tree:
		var saved_technology: Variant = snapshot.get("technology_state", {})
		if typeof(saved_technology) == TYPE_DICTIONARY:
			technology_tree.import_state(saved_technology)
	if campaign:
		campaign.set_player_level(int(snapshot.get("campaign_level", 1)))
	if warfront_state:
		var saved_warfront: Variant = snapshot.get("warfront_state", {})
		if saved_warfront is Dictionary:
			warfront_state.import_state(saved_warfront)
	if kaiju_war:
		var saved_kaiju: Variant = snapshot.get("kaiju_war_state", {})
		if saved_kaiju is Dictionary and not saved_kaiju.is_empty():
			kaiju_war.import_state(saved_kaiju)
	if damage_model:
		var saved_damage: Variant = snapshot.get("damage_model_state", {})
		if saved_damage is Dictionary and not saved_damage.is_empty():
			damage_model.import_state(saved_damage)
	if gameplay_loop:
		var saved_loop: Variant = snapshot.get("gameplay_loop_state", {})
		if saved_loop is Dictionary and not saved_loop.is_empty():
			gameplay_loop.import_state(saved_loop)
	if npc_manager:
		var saved_npc: Variant = snapshot.get("npc_state", {})
		if saved_npc is Dictionary and not saved_npc.is_empty():
			npc_manager.import_state(saved_npc)
	if kaiju_war and campaign:
		kaiju_war.set_progression(campaign.player_level, campaign.jaeger_generation)
	if alliance_manager and typeof(snapshot.get("alliance_state", {})) == TYPE_DICTIONARY and not snapshot.get("alliance_state", {}).is_empty():
		alliance_manager.import_state(snapshot["alliance_state"])
	_update_hud()

func _sync_global_state_from_local() -> void:
	if syncing_game_state:
		return
	syncing_game_state = true
	GlobalState.resources = resources.duplicate(true)
	GlobalState.base_level = maxi(1, base_level)
	GlobalState.titan_level = maxi(1, titan_level)
	GlobalState.resources_changed.emit()
	syncing_game_state = false

func _on_global_resources_changed() -> void:
	if syncing_game_state:
		return
	resources = GlobalState.resources.duplicate(true)
	_update_hud()

func _on_field_mission_completed(_reward: Dictionary) -> void:
	resources = GlobalState.resources.duplicate(true)
	_show_status("OPERACIÓN COMPLETADA: suministros y progreso sincronizados con tu perfil local.")
	_update_hud()
	_save_local_profile()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE or what == NOTIFICATION_APPLICATION_PAUSED:
		_save_local_profile()

func _create_online_panel(layer: CanvasLayer) -> void:
	if OS.has_feature("mobile") or DisplayServer.is_touchscreen_available():
		return
	var panel := PanelContainer.new()
	panel.position = Vector2(850, 18)
	panel.custom_minimum_size = Vector2(410, 650)
	layer.add_child(panel)
	var column := VBoxContainer.new()
	panel.add_child(column)
	var title := Label.new()
	title.text = "CUENTA Y COMUNIDAD ONLINE"
	title.add_theme_font_size_override("font_size", 17)
	column.add_child(title)
	online_status_label = Label.new()
	online_status_label.text = "Backend sin configurar. Completa client_config.example.json."
	online_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(online_status_label)
	online_email = LineEdit.new()
	online_email.placeholder_text = "Correo electrónico"
	column.add_child(online_email)
	online_password = LineEdit.new()
	online_password.placeholder_text = "Contraseña (mínimo 10 caracteres)"
	online_password.secret = true
	column.add_child(online_password)
	online_handle = LineEdit.new()
	online_handle.placeholder_text = "Usuario público (3-20 caracteres)"
	column.add_child(online_handle)
	var auth_row := HBoxContainer.new()
	column.add_child(auth_row)
	var signup := Button.new()
	signup.text = "Crear cuenta"
	signup.pressed.connect(_on_online_signup_pressed)
	auth_row.add_child(signup)
	var login := Button.new()
	login.text = "Iniciar sesión"
	login.pressed.connect(_on_online_login_pressed)
	auth_row.add_child(login)
	var alliance_title := Label.new()
	alliance_title.text = "ALIANZAS ONLINE"
	column.add_child(alliance_title)
	online_alliance_name = LineEdit.new()
	online_alliance_name.placeholder_text = "Nombre de alianza"
	column.add_child(online_alliance_name)
	online_alliance_tag = LineEdit.new()
	online_alliance_tag.placeholder_text = "Etiqueta (2-5 letras)"
	column.add_child(online_alliance_tag)
	var alliance_create_button := Button.new()
	alliance_create_button.text = "Crear alianza online"
	alliance_create_button.pressed.connect(_on_online_alliance_create)
	column.add_child(alliance_create_button)
	online_alliance_id = LineEdit.new()
	online_alliance_id.placeholder_text = "ID de alianza para solicitar ingreso"
	column.add_child(online_alliance_id)
	var alliance_join_button := Button.new()
	alliance_join_button.text = "Solicitar ingreso"
	alliance_join_button.pressed.connect(_on_online_alliance_join)
	column.add_child(alliance_join_button)
	var alliance_refresh_button := Button.new()
	alliance_refresh_button.text = "Buscar alianzas públicas"
	alliance_refresh_button.pressed.connect(_on_online_alliance_refresh)
	column.add_child(alliance_refresh_button)
	online_alliance_log = Label.new()
	online_alliance_log.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(online_alliance_log)
	var chat_title := Label.new()
	chat_title.text = "CHAT GLOBAL MODERADO"
	column.add_child(chat_title)
	online_chat_log = Label.new()
	online_chat_log.text = "Los mensajes se publican solo después de revisión del servidor."
	online_chat_log.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	online_chat_log.custom_minimum_size = Vector2(360, 90)
	column.add_child(online_chat_log)
	online_chat_input = LineEdit.new()
	online_chat_input.placeholder_text = "Mensaje (máximo 240 caracteres)"
	column.add_child(online_chat_input)
	var chat_row := HBoxContainer.new()
	column.add_child(chat_row)
	var send := Button.new()
	send.text = "Enviar mensaje"
	send.pressed.connect(_on_online_chat_send)
	chat_row.add_child(send)
	online_safety_user_id = LineEdit.new()
	online_safety_user_id.placeholder_text = "ID de jugador para bloquear o denunciar"
	column.add_child(online_safety_user_id)
	var safety_row := HBoxContainer.new()
	column.add_child(safety_row)
	var block_button := Button.new()
	block_button.text = "Bloquear jugador"
	block_button.pressed.connect(_on_online_block_player)
	safety_row.add_child(block_button)
	var report_button := Button.new()
	report_button.text = "Denunciar jugador"
	report_button.pressed.connect(_on_online_report_player)
	safety_row.add_child(report_button)
	var refresh := Button.new()
	refresh.text = "Actualizar chat"
	refresh.pressed.connect(_on_online_chat_refresh)
	chat_row.add_child(refresh)
	var config_file := FileAccess.open("res://backend/supabase/client_config.example.json", FileAccess.READ)
	if config_file:
		var config: Variant = JSON.parse_string(config_file.get_as_text())
		config_file.close()
		if typeof(config) == TYPE_DICTIONARY:
			community_client.configure(str(config.get("supabase_url","")),str(config.get("supabase_anon_key","")))
	if community_client._configured():
		online_status_label.text = "Backend configurado. Puedes registrar o iniciar sesión."
	else:
		online_status_label.text = "Falta configurar Supabase. El chat online permanece inactivo."

func _on_online_signup_pressed() -> void:
	var result: Dictionary = await community_client.sign_up(online_email.text, online_password.text)
	if int(result.get("status",0)) in [200,201] and not community_client.access_token.is_empty():
		var profile_ok: bool = await community_client.register_profile(online_handle.text, online_handle.text)
		online_status_label.text = "Cuenta creada y perfil registrado." if profile_ok else "Cuenta creada. Confirma el correo o revisa el usuario público."
	elif int(result.get("status",0)) in [200,201]:
		online_status_label.text = "Cuenta creada. Revisa tu correo para confirmar y luego inicia sesión."
	else:
		online_status_label.text = str(result.get("error","No se pudo crear la cuenta."))

func _on_online_login_pressed() -> void:
	var result: Dictionary = await community_client.sign_in(online_email.text, online_password.text)
	if int(result.get("status",0)) == 200:
		if not online_handle.text.strip_edges().is_empty():
			await community_client.register_profile(online_handle.text, online_handle.text)
		online_status_label.text = "Sesión iniciada: " + community_client.user_email
	else:
		online_status_label.text = str(result.get("error","No se pudo iniciar sesión."))

func _on_online_auth_changed(is_authenticated: bool, message: String) -> void:
	if online_status_label:
		online_status_label.text = message if is_authenticated else message

func _on_online_error(message: String) -> void:
	if online_status_label:
		online_status_label.text = message

func _on_online_chat_send() -> void:
	var sent: bool = await community_client.send_chat_message(online_chat_input.text)
	if sent:
		online_chat_input.clear()
		online_status_label.text = "Mensaje enviado a revisión. Solo aparecerá si es aprobado."
	else:
		online_status_label.text = "No se pudo enviar. Comprueba tu sesión y los permisos de chat."

func _on_online_chat_refresh() -> void:
	var messages: Array = await community_client.fetch_global_chat()
	var lines: PackedStringArray = []
	for message in messages:
		lines.append(str(message.get("body","")))
	online_chat_log.text = "\n".join(lines) if not lines.is_empty() else "No hay mensajes visibles o todavía no hay conexión."

func _on_online_alliance_create() -> void:
	var alliance_id: String = await community_client.create_online_alliance(online_alliance_name.text, online_alliance_tag.text.to_upper())
	if not alliance_id.is_empty():
		online_alliance_log.text = "Alianza creada. ID: " + alliance_id
		online_alliance_id.text = alliance_id
	else:
		online_alliance_log.text = "No se pudo crear. Inicia sesión, configura SQL 0002 y revisa que no pertenezcas a otra alianza."

func _on_online_alliance_join() -> void:
	var ok: bool = await community_client.request_alliance_join(online_alliance_id.text.strip_edges())
	online_alliance_log.text = "Solicitud enviada al liderazgo." if ok else "No se pudo enviar la solicitud. Comprueba el ID, tu sesión y que no estés en otra alianza."

func _on_online_alliance_refresh() -> void:
	var alliances: Array = await community_client.fetch_public_alliances()
	var lines: PackedStringArray = []
	for alliance in alliances:
		lines.append("[%s] %s — %s" % [str(alliance.get("tag","")),str(alliance.get("name","")),str(alliance.get("id",""))])
	online_alliance_log.text = "\n".join(lines) if not lines.is_empty() else "No se encontraron alianzas o falta iniciar sesión."

func _on_online_block_player() -> void:
	var ok: bool = await community_client.block_player(online_safety_user_id.text.strip_edges())
	online_status_label.text = "Jugador bloqueado; sus mensajes se ocultarán." if ok else "No se pudo bloquear. Revisa el ID y tu sesión."

func _on_online_report_player() -> void:
	var ok: bool = await community_client.report_player(online_safety_user_id.text.strip_edges(), "other", "Reporte enviado desde el juego.")
	online_status_label.text = "Denuncia enviada para revisión." if ok else "No se pudo enviar la denuncia. Revisa el ID y tu sesión."

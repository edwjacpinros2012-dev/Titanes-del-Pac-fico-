extends Node3D
class_name FieldCombatDirector

signal mission_completed(reward: Dictionary)

const KaijuScript = preload("res://scripts/combat/field_kaiju.gd")
const REQUIRED_DEFEATS := 3

var player: Node3D
var defeated_count := 0
var status_text := ""
var mission_finished := false
var hud_label: Label
var health_label: Label
var save_timer := 0.0

func _ready() -> void:
	call_deferred("_begin_field_mission")

func _process(delta: float) -> void:
	save_timer += delta
	if save_timer >= 60.0:
		save_timer = 0.0
		if is_instance_valid(GlobalState):
			SaveSystem.save_game(GlobalState)
	_update_hud()

func _begin_field_mission() -> void:
	var players := get_tree().get_nodes_in_group("player_titan")
	if players.is_empty():
		push_warning("FieldCombatDirector: no se encontró un Titán en el grupo player_titan.")
		return
	player = players[0] as Node3D
	if player.has_signal("health_changed"):
		player.health_changed.connect(_on_health_changed)
	var layer := CanvasLayer.new()
	layer.name = "CombatMissionHUD"
	add_child(layer)
	var panel := PanelContainer.new()
	panel.anchor_left = 0.68
	panel.anchor_top = 0.025
	panel.anchor_right = 0.98
	panel.anchor_bottom = 0.22
	layer.add_child(panel)
	var column := VBoxContainer.new()
	panel.add_child(column)
	var heading := Label.new()
	heading.text = "OPERACIÓN: COSTA DE LA AURORA"
	heading.add_theme_font_size_override("font_size", 16)
	column.add_child(heading)
	hud_label = Label.new()
	hud_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(hud_label)
	health_label = Label.new()
	column.add_child(health_label)
	_spawn_initial_wave()
	_update_hud()

func _spawn_initial_wave() -> void:
	var offsets := [Vector3(-10, 0, -13), Vector3(10, 0, -17), Vector3(0, 0, -25)]
	for index in range(REQUIRED_DEFEATS):
		var kaiju := CharacterBody3D.new()
		kaiju.set_script(KaijuScript)
		kaiju.name = "Kaiju_%02d" % (index + 1)
		kaiju.position = player.position + offsets[index]
		kaiju.defeated.connect(_on_kaiju_defeated)
		add_child(kaiju)

func _on_kaiju_defeated(reward: Dictionary) -> void:
	if mission_finished:
		return
	defeated_count += 1
	for resource_id in reward:
		GlobalState.add_resource(str(resource_id), int(reward[resource_id]))
	if defeated_count >= REQUIRED_DEFEATS:
		mission_finished = true
		var completion_reward := {"metal": 20, "energy": 12}
		for resource_id in completion_reward:
			GlobalState.add_resource(str(resource_id), int(completion_reward[resource_id]))
		SaveSystem.save_game(GlobalState)
		status_text = "Objetivo cumplido. Recompensas guardadas en el perfil local."
		mission_completed.emit(completion_reward)
	else:
		status_text = "Amenaza neutralizada. Recupera suministros y continúa."
		SaveSystem.save_game(GlobalState)
	_update_hud()

func _on_health_changed(current: float, maximum: float) -> void:
	if health_label:
		health_label.text = "INTEGRIDAD %d / %d    ENERGÍA %d%%" % [roundi(current), roundi(maximum), roundi(player.energy)]
	if current <= 0.0:
		status_text = "TITÁN INCAPACITADO — reinicia la misión para volver a desplegar."
	_update_hud()

func _update_hud() -> void:
	if hud_label == null:
		return
	var objective := "OBJETIVO: neutraliza Kaijus (%d/%d)" % [defeated_count, REQUIRED_DEFEATS]
	if mission_finished:
		objective = "MISIÓN COMPLETADA"
	elif player != null and player.is_defeated:
		objective = "TITÁN INCAPACITADO"
	var controls := "SPACE: golpe | RMB/F: pulso (35 energía) | SHIFT: bloquear"
	if OS.has_feature("mobile") or DisplayServer.is_touchscreen_available():
		controls = "Usa la cruceta y los botones táctiles de combate."
	hud_label.text = objective + "\n" + (status_text if not status_text.is_empty() else "Detectados: 3 hostiles. Acércate, apunta y ataca.") + "\n" + controls
	if health_label and player != null:
		health_label.text = "INTEGRIDAD %d / %d    ENERGÍA %d%%" % [roundi(player.health), roundi(player.max_health), roundi(player.energy)]

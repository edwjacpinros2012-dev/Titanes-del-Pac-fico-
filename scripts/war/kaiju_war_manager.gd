extends Node3D
class_name KaijuWarManager

signal encounter_changed(summary: String)
signal battle_resolved(outcome: String, rewards: Dictionary, consequences: Dictionary)

var player: Node3D
var jaeger_level: int = 1
var research_power_bonus: int = 0
var campaign_level: int = 1
var active_kaiju_id := "bruma_abismal"
var active_kaiju_name := "Bruma Abismal"
var active_kaiju_role := "stalker"
var threat := 1
var is_encounter_active := false
var encounter_count := 0
var last_outcome := "Sin encuentros"
var kaiju_node: Node3D
var encounter_distance := 22.0
var last_battle_report: Dictionary = {}
var selected_tactic := "scan"
var pilot_skill := 0
var tactics_used := 0
var successful_counters := 0
var last_tactic_feedback := "Analiza la amenaza antes de elegir una táctica."

const ROSTER_PATH := "res://data/kaiju/kaiju_roster.json"
const TACTICS := ["scan", "flank", "guard", "precision"]

func _ready() -> void:
	_spawn_kaiju("bruma_abismal")

func set_player_target(target: Node3D) -> void:
	player = target

func set_progression(level: int, generation: int) -> void:
	campaign_level = maxi(1, level)
	jaeger_level = maxi(1, generation)

func set_research_power_bonus(value: int) -> void:
	research_power_bonus = clampi(value, 0, 5)

func begin_encounter() -> bool:
	if is_encounter_active:
		return false
	if not is_instance_valid(kaiju_node):
		_spawn_kaiju(_choose_kaiju_for_level())
	is_encounter_active = true
	encounter_count += 1
	selected_tactic = "scan"
	last_tactic_feedback = "Escanea la amenaza y elige una respuesta."
	encounter_changed.emit(get_status_text())
	return true

func select_tactic(tactic_id: String) -> bool:
	if not is_encounter_active or tactic_id not in TACTICS:
		return false
	selected_tactic = tactic_id
	last_tactic_feedback = _get_tactic_description(tactic_id)
	encounter_changed.emit(get_status_text())
	return true

func get_tactical_counter_role() -> String:
	match active_kaiju_role:
		"armored", "siege", "territorial":
			return "flank"
		"stalker", "ambusher", "burrower":
			return "guard"
		"swift", "disruptor", "alpha":
			return "precision"
		_:
			return "precision"

func get_tactical_bonus() -> int:
	if selected_tactic == "scan":
		return 1
	if selected_tactic == get_tactical_counter_role():
		return 3 + int(pilot_skill / 4)
	if selected_tactic == "guard":
		return 1
	return -1

func get_player_power() -> int:
	return 3 + jaeger_level * 2 + int(campaign_level / 3) + research_power_bonus

func get_kaiju_power() -> int:
	return threat * 5

func get_power_gap() -> int:
	return get_player_power() + get_tactical_bonus() - get_kaiju_power()

func get_readiness_state() -> String:
	var gap := get_power_gap()
	if gap >= 3:
		return "PREPARACIÓN FAVORABLE"
	if gap >= -1:
		return "RIESGO ELEVADO"
	return "PELIGRO CRÍTICO: PREPÁRATE O CONSIDERA RETIRARTE"

func get_preparation_report() -> String:
	return "POTENCIA CENTINELA %d | AMENAZA %d | TÁCTICA %s (%+d) | EXPERIENCIA PILOTO %d/10\n%s" % [
		get_player_power(), get_kaiju_power(), selected_tactic.to_upper(), get_tactical_bonus(), pilot_skill, get_readiness_state()
	]

func get_status_text() -> String:
	var state := "ENCUENTRO ACTIVO" if is_encounter_active else "Amenaza detectada"
	return "ABISAL: %s | Rol: %s | Amenaza %d | %s | Último resultado: %s\n%s\n%s" % [
		active_kaiju_name, active_kaiju_role, threat, state, last_outcome,
		get_preparation_report(), last_tactic_feedback
	]

func _get_tactic_description(tactic_id: String) -> String:
	match tactic_id:
		"scan":
			return "LECTURA: estudia patrón y rol del Abisal. Bonificación segura pequeña."
		"flank":
			return "FLANQUEO: busca un ángulo contra amenazas blindadas, de asedio o territoriales."
		"guard":
			return "DEFENSA: protege articulaciones y reactor frente a emboscadas y ataques de excavación."
		"precision":
			return "PRECISIÓN: espera una apertura contra amenazas veloces, disruptoras o alfa."
		_:
			return "Táctica no reconocida."

func resolve_battle(action: String = "engage") -> Dictionary:
	if not is_encounter_active:
		return {}
	var base_power := get_player_power()
	var kaiju_power := get_kaiju_power()
	var tactic_bonus := get_tactical_bonus()
	var player_power := base_power + tactic_bonus
	var matched_counter := selected_tactic == get_tactical_counter_role()
	var rewards := {"credits": 0, "metal": 0, "energia": 0, "cristal": 0, "research_data": 0}
	var consequences := {
		"repair": 0, "supply_loss": 0, "sector_pressure": 0,
		"player_power": player_power, "base_power": base_power,
		"kaiju_power": kaiju_power, "power_gap": player_power - kaiju_power,
		"tactic": selected_tactic, "tactic_bonus": tactic_bonus,
		"pilot_skill": pilot_skill, "enemy_role": active_kaiju_role,
		"readiness": get_readiness_state()
	}
	var outcome := "retreat"
	if action == "retreat":
		outcome = "retreat"
		consequences["repair"] = 1 if selected_tactic == "guard" else 2
		consequences["sector_pressure"] = 1
	elif player_power >= kaiju_power + 3:
		outcome = "victory"
		rewards = {"credits": 80 + threat * 30, "metal": 8 + threat * 2, "energia": 4 + threat, "cristal": threat, "research_data": 3 + threat * 2}
	elif player_power >= kaiju_power - 1:
		outcome = "partial_success"
		rewards = {"credits": 35, "metal": 3, "energia": 2, "cristal": 0, "research_data": 2}
		consequences["repair"] = 1 if selected_tactic == "guard" else 2
	else:
		outcome = "defeat"
		consequences["repair"] = 4 + threat
		consequences["supply_loss"] = 2 + threat
		consequences["sector_pressure"] = 2

	tactics_used += 1
	if matched_counter and action != "retreat":
		successful_counters += 1
		pilot_skill = mini(10, pilot_skill + 1)
		last_tactic_feedback = "¡Buena lectura! La táctica contrarrestó el rol enemigo. Experiencia de piloto +1."
	elif selected_tactic == "scan":
		last_tactic_feedback = "Lectura prudente: obtuviste información, pero no explotaste una debilidad concreta."
	elif action == "retreat":
		last_tactic_feedback = "Retirada registrada. Puedes volver con otra táctica y mejor preparación."
	else:
		last_tactic_feedback = "La táctica no contrarrestó el patrón enemigo. Estudia su rol antes del próximo encuentro."

	last_outcome = outcome
	last_battle_report = {
		"outcome": outcome, "player_power": player_power, "base_power": base_power,
		"kaiju_power": kaiju_power, "power_gap": player_power - kaiju_power,
		"readiness": get_readiness_state(), "threat": threat,
		"kaiju_id": active_kaiju_id, "enemy_role": active_kaiju_role,
		"tactic": selected_tactic, "tactic_bonus": tactic_bonus,
		"matched_counter": matched_counter, "pilot_skill": pilot_skill
	}
	is_encounter_active = false
	if outcome == "victory" or outcome == "partial_success":
		if is_instance_valid(kaiju_node):
			kaiju_node.queue_free()
		kaiju_node = null
		_spawn_kaiju(_choose_kaiju_for_level())
	else:
		if is_instance_valid(kaiju_node):
			kaiju_node.global_position = Vector3(randf_range(-28.0, 28.0), 0.0, -32.0)
	battle_resolved.emit(outcome, rewards, consequences)
	encounter_changed.emit(get_status_text())
	return {"outcome": outcome, "rewards": rewards, "consequences": consequences}

func export_state() -> Dictionary:
	return {
		"version": 2,
		"active_kaiju_id": active_kaiju_id,
		"encounter_count": encounter_count,
		"last_outcome": last_outcome,
		"last_battle_report": last_battle_report.duplicate(true),
		"pilot_skill": pilot_skill,
		"tactics_used": tactics_used,
		"successful_counters": successful_counters
	}

func import_state(data: Dictionary) -> void:
	var saved_id := str(data.get("active_kaiju_id", "bruma_abismal"))
	_spawn_kaiju(saved_id)
	encounter_count = maxi(0, int(data.get("encounter_count", 0)))
	last_outcome = str(data.get("last_outcome", "Sin encuentros"))
	var saved_report: Variant = data.get("last_battle_report", {})
	last_battle_report = saved_report.duplicate(true) if saved_report is Dictionary else {}
	pilot_skill = clampi(int(data.get("pilot_skill", 0)), 0, 10)
	tactics_used = maxi(0, int(data.get("tactics_used", 0)))
	successful_counters = maxi(0, int(data.get("successful_counters", 0)))
	selected_tactic = "scan"
	is_encounter_active = false

func _choose_kaiju_for_level() -> String:
	if campaign_level >= 35:
		return "anguila_cristal"
	if campaign_level >= 22:
		return "coral_rey"
	if campaign_level >= 12:
		return "taladro_de_fosa"
	if campaign_level >= 5:
		return "rompeolas"
	return "bruma_abismal"

func _spawn_kaiju(kaiju_id: String) -> void:
	active_kaiju_id = kaiju_id
	var roster_file := FileAccess.open(ROSTER_PATH, FileAccess.READ)
	if roster_file:
		var parsed: Variant = JSON.parse_string(roster_file.get_as_text())
		roster_file.close()
		if typeof(parsed) == TYPE_DICTIONARY:
			for entry in parsed.get("kaiju", []):
				if str(entry.get("id", "")) == kaiju_id:
					active_kaiju_name = str(entry.get("name", kaiju_id))
					active_kaiju_role = str(entry.get("role", "stalker"))
					threat = _tier_to_number(str(entry.get("tier", "I")))
					break
	if is_instance_valid(kaiju_node):
		kaiju_node.queue_free()
	kaiju_node = Node3D.new()
	kaiju_node.name = "Kaiju_" + kaiju_id
	var body := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 2.8 + threat * 0.45
	mesh.height = mesh.radius * 1.4
	body.mesh = mesh
	body.scale = Vector3(1.5, 1.0, 1.2)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.18 + threat * 0.08, 0.22, 0.28 + threat * 0.06)
	material.emission_enabled = true
	material.emission = Color(0.08, 0.35, 0.48)
	material.emission_energy_multiplier = 0.5
	body.material_override = material
	body.position.y = 2.8
	kaiju_node.add_child(body)
	var dorsal := MeshInstance3D.new()
	var dorsal_mesh := BoxMesh.new()
	dorsal_mesh.size = Vector3(0.8, 2.0 + threat * 0.2, 0.8)
	dorsal.mesh = dorsal_mesh
	dorsal.position = Vector3(0, 4.1, -0.4)
	dorsal.material_override = material
	kaiju_node.add_child(dorsal)
	kaiju_node.position = Vector3(0, 0, -28)
	add_child(kaiju_node)
	encounter_changed.emit(get_status_text())

func _tier_to_number(tier: String) -> int:
	match tier:
		"II": return 2
		"III": return 3
		"IV": return 4
		"V": return 5
		_: return 1

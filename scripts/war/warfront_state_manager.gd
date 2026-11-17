extends Node
class_name WarfrontStateManager

signal state_changed(summary: String)

const DEFAULT_FRONT_ID := "aurora_coast"
const MAX_PRESSURE := 10
const CONTESTED_THRESHOLD := 3
const LOST_THRESHOLD := 6

var front_id := DEFAULT_FRONT_ID
var pressure := 0
var victories := 0
var partial_successes := 0
var retreats := 0
var defeats := 0
var operations := 0

func apply_battle_result(outcome: String, reported_pressure: int = 0) -> void:
	operations += 1
	match outcome:
		"victory":
			victories += 1
			pressure = maxi(0, pressure - 2)
		"partial_success":
			partial_successes += 1
			pressure = maxi(0, pressure - 1)
		"retreat":
			retreats += 1
			pressure = clampi(pressure + maxi(1, reported_pressure), 0, MAX_PRESSURE)
		"defeat":
			defeats += 1
			pressure = clampi(pressure + maxi(2, reported_pressure), 0, MAX_PRESSURE)
	state_changed.emit(get_status_text())

func get_control_state() -> String:
	if pressure >= LOST_THRESHOLD:
		return "PERDIDO"
	if pressure >= CONTESTED_THRESHOLD:
		return "EN DISPUTA"
	return "CONTROLADO"

func get_status_text() -> String:
	return "FRENTE COSTERA: %s | Presión abisal %d/%d | V:%d P:%d R:%d D:%d" % [
		get_control_state(), pressure, MAX_PRESSURE, victories, partial_successes, retreats, defeats
	]

func export_state() -> Dictionary:
	return {
		"version": 1,
		"front_id": front_id,
		"pressure": pressure,
		"victories": victories,
		"partial_successes": partial_successes,
		"retreats": retreats,
		"defeats": defeats,
		"operations": operations
	}

func import_state(data: Dictionary) -> void:
	front_id = str(data.get("front_id", DEFAULT_FRONT_ID))
	pressure = clampi(int(data.get("pressure", 0)), 0, MAX_PRESSURE)
	victories = maxi(0, int(data.get("victories", 0)))
	partial_successes = maxi(0, int(data.get("partial_successes", 0)))
	retreats = maxi(0, int(data.get("retreats", 0)))
	defeats = maxi(0, int(data.get("defeats", 0)))
	operations = maxi(0, int(data.get("operations", victories + partial_successes + retreats + defeats)))
	state_changed.emit(get_status_text())

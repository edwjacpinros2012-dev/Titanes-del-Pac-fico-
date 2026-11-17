extends RefCounted
class_name MissionRunManager

signal phase_changed(phase: String)
signal objective_updated(objective_id: String, current: int, target: int)
signal mission_resolved(result: Dictionary)

const PHASE_BASE := "base"
const PHASE_DEPLOYMENT := "deployment"
const PHASE_ACTIVE := "active"
const PHASE_DEBRIEF := "debrief"
const VALID_OUTCOMES := ["victory", "partial", "retreat", "defeat"]
const REWARD_MULTIPLIERS := {"victory": 1.0, "partial": 0.65, "retreat": 0.2, "defeat": 0.0}

var phase := PHASE_BASE
var current_mission: Dictionary = {}
var objective_progress: Dictionary = {}
var last_result: Dictionary = {}

func start_mission(mission: Dictionary, threat_brief: Dictionary = {}) -> bool:
	if phase != PHASE_BASE:
		return false
	var mission_id := str(mission.get("id", "")).strip_edges()
	if mission_id.is_empty():
		return false
	current_mission = mission.duplicate(true)
	current_mission["id"] = mission_id
	objective_progress.clear()
	var objectives: Array = current_mission.get("objectives", [])
	for objective in objectives:
		if not objective is Dictionary:
			continue
		var objective_id := str(objective.get("id", "")).strip_edges()
		if not objective_id.is_empty():
			objective_progress[objective_id] = 0
	current_mission["threat_brief"] = threat_brief.duplicate(true)
	last_result.clear()
	_set_phase(PHASE_DEPLOYMENT)
	return true

func begin_operation() -> bool:
	if phase != PHASE_DEPLOYMENT:
		return false
	_set_phase(PHASE_ACTIVE)
	return true

func record_objective_progress(objective_id: String, amount: int = 1) -> bool:
	if phase != PHASE_ACTIVE or amount <= 0 or not objective_progress.has(objective_id):
		return false
	var objective := _find_objective(objective_id)
	if objective.is_empty():
		return false
	var target := maxi(1, int(objective.get("target", 1)))
	var current := mini(target, int(objective_progress[objective_id]) + amount)
	objective_progress[objective_id] = current
	objective_updated.emit(objective_id, current, target)
	return true

func resolve_mission(outcome: String, base_rewards: Dictionary = {}) -> Dictionary:
	if phase != PHASE_ACTIVE or outcome not in VALID_OUTCOMES:
		return {}
	var effective_outcome := outcome
	if outcome == "victory" and not _mandatory_objectives_complete():
		effective_outcome = "partial"
	var multiplier := float(REWARD_MULTIPLIERS[effective_outcome])
	var rewards: Dictionary = {}
	for resource_id in base_rewards:
		var amount := maxi(0, int(base_rewards[resource_id]))
		var awarded := int(floor(float(amount) * multiplier))
		if awarded > 0:
			rewards[resource_id] = awarded
	last_result = {
		"mission_id": str(current_mission.get("id", "")),
		"outcome": effective_outcome,
		"requested_outcome": outcome,
		"reward_multiplier": multiplier,
		"rewards": rewards,
		"objective_progress": objective_progress.duplicate(true),
		"threat_brief": current_mission.get("threat_brief", {}).duplicate(true)
	}
	_set_phase(PHASE_DEBRIEF)
	mission_resolved.emit(last_result.duplicate(true))
	return last_result.duplicate(true)

func return_to_base() -> bool:
	if phase != PHASE_DEBRIEF:
		return false
	current_mission.clear()
	objective_progress.clear()
	_set_phase(PHASE_BASE)
	return true

func get_snapshot() -> Dictionary:
	return {
		"phase": phase,
		"current_mission": current_mission.duplicate(true),
		"objective_progress": objective_progress.duplicate(true),
		"last_result": last_result.duplicate(true)
	}

func _find_objective(objective_id: String) -> Dictionary:
	for objective in current_mission.get("objectives", []):
		if objective is Dictionary and str(objective.get("id", "")) == objective_id:
			return objective
	return {}

func _mandatory_objectives_complete() -> bool:
	for objective in current_mission.get("objectives", []):
		if not objective is Dictionary or bool(objective.get("optional", false)):
			continue
		var objective_id := str(objective.get("id", ""))
		var target := maxi(1, int(objective.get("target", 1)))
		if int(objective_progress.get(objective_id, 0)) < target:
			return false
	return true

func _set_phase(next_phase: String) -> void:
	if phase == next_phase:
		return
	phase = next_phase
	phase_changed.emit(phase)

extends Node
class_name ExpeditionManager

signal expedition_started(region_id: String)
signal objective_updated(current: int, target: int)
signal expedition_completed(region_id: String, reward: Dictionary)
signal expedition_cancelled

var active_region := ""
var target_resource := ""
var target_amount := 0
var current_amount := 0
var reward: Dictionary = {}

func start_expedition(region_id: String, resource_id: String, amount: int, reward_data: Dictionary) -> bool:
	if not active_region.is_empty() or region_id.is_empty() or resource_id.is_empty() or amount <= 0:
		return false
	active_region = region_id
	target_resource = resource_id
	target_amount = amount
	current_amount = 0
	reward = reward_data.duplicate(true)
	expedition_started.emit(active_region)
	objective_updated.emit(current_amount, target_amount)
	return true

func report_collection(resource_id: String, amount: int) -> void:
	if active_region.is_empty() or resource_id != target_resource or amount <= 0:
		return
	current_amount = mini(current_amount + amount, target_amount)
	objective_updated.emit(current_amount, target_amount)
	if current_amount >= target_amount:
		var finished_region := active_region
		var finished_reward := reward.duplicate(true)
		active_region = ""
		target_resource = ""
		target_amount = 0
		current_amount = 0
		reward.clear()
		expedition_completed.emit(finished_region, finished_reward)

func cancel_expedition() -> void:
	if active_region.is_empty():
		return
	active_region = ""
	target_resource = ""
	target_amount = 0
	current_amount = 0
	reward.clear()
	expedition_cancelled.emit()

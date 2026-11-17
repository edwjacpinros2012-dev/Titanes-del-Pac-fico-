extends Node
class_name MissionTracker
signal mission_progress(current: int, target: int)
signal mission_completed(mission_id: String)
var active_mission: MissionData
var current_progress := 0
var completed_ids: Array[String] = []
func start_mission(data: MissionData) -> void:
	if data == null or data.mission_id in completed_ids: return
	active_mission = data
	current_progress = 0
	mission_progress.emit(current_progress, active_mission.target_amount)
func report_resource_collected(resource_id: String, amount: int) -> void:
	if active_mission == null or resource_id != active_mission.target_resource: return
	current_progress = mini(current_progress + amount, active_mission.target_amount)
	mission_progress.emit(current_progress, active_mission.target_amount)
	if current_progress >= active_mission.target_amount:
		completed_ids.append(active_mission.mission_id)
		mission_completed.emit(active_mission.mission_id)
		active_mission = null

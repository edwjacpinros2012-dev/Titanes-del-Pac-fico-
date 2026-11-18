extends Node
class_name GameLoopManager
signal mission_started(mission_id: String, title: String, target: int)
signal mission_progress(current: int, target: int)
signal mission_completed(mission_id: String, reward: Dictionary)
signal expedition_started(region_id: String, target_resource: String, target_amount: int)
signal expedition_completed(region_id: String, reward: Dictionary)
signal region_unlocked(region_id: String)
signal world_event_started(event_id: String, title: String, resource_id: String, bonus: int)
signal world_event_ended(event_id: String)
signal status_changed(text: String)
const STARTER_MISSION := {"id":"starter_gather","title":"Suministros para el puesto","description":"Recolecta metal para reforzar la base inicial.","resource":"metal","target":5,"reward":{"energia":8,"research_data":3}}
const REGIONS := {"aurora_coast":{"title":"Costa de la Aurora","rank":1},"broken_isles":{"title":"Islas Quebradas","rank":2},"deep_trench":{"title":"Fosa del Pacífico","rank":3}}
const EVENTS := [{"id":"crystal_echo","title":"Eco cristalino","resource":"cristal","bonus":1},{"id":"metal_tide","title":"Marea de minerales","resource":"metal","bonus":1},{"id":"energy_swell","title":"Oleada energética","resource":"energia","bonus":1}]
@export var event_interval_seconds := 210.0
@export var event_duration_seconds := 50.0
var active_mission: Dictionary = {}
var mission_progress_value := 0
var completed_missions: Array[String] = []
var active_expedition: Dictionary = {}
var unlocked_regions: Array[String] = ["aurora_coast"]
var current_region := "aurora_coast"
var active_event: Dictionary = {}
var event_timer := 0.0
var event_remaining := 0.0
func _ready() -> void:
	if active_mission.is_empty() and completed_missions.is_empty():
		start_mission(STARTER_MISSION)
func _process(delta: float) -> void:
	if not active_event.is_empty():
		event_remaining -= delta
		if event_remaining <= 0.0:
			var ended := str(active_event.get("id",""))
			active_event.clear()
			event_remaining = 0.0
			world_event_ended.emit(ended)
			status_changed.emit("Evento finalizado.")
	else:
		event_timer += delta
		if event_timer >= event_interval_seconds:
			event_timer = 0.0
			start_random_event()
func start_mission(data: Dictionary) -> bool:
	var id := str(data.get("id","")).strip_edges()
	var target := int(data.get("target",0))
	if id.is_empty() or target <= 0 or id in completed_missions: return false
	active_mission = data.duplicate(true)
	mission_progress_value = 0
	mission_started.emit(id,str(data.get("title","Misión")),target)
	mission_progress.emit(0,target)
	status_changed.emit("Misión: "+str(active_mission.get("title","")))
	return true
func report_collection(resource_id: String, amount: int) -> void:
	if amount <= 0: return
	if not active_mission.is_empty() and resource_id == str(active_mission.get("resource","")):
		var target := int(active_mission.get("target",0))
		mission_progress_value = mini(mission_progress_value+amount,target)
		mission_progress.emit(mission_progress_value,target)
		if mission_progress_value >= target:
			var id := str(active_mission.get("id",""))
			var reward: Dictionary = active_mission.get("reward",{}).duplicate(true)
			if id not in completed_missions: completed_missions.append(id)
			active_mission.clear()
			mission_completed.emit(id,reward)
			status_changed.emit("Misión completada: recompensa entregada.")
			if id == "starter_gather": unlock_region("broken_isles")
	if not active_expedition.is_empty() and resource_id == str(active_expedition.get("resource","")):
		var goal := int(active_expedition.get("target",0))
		active_expedition["progress"] = mini(int(active_expedition.get("progress",0))+amount,goal)
		if int(active_expedition["progress"]) >= goal:
			var region := str(active_expedition.get("region",""))
			var reward: Dictionary = active_expedition.get("reward",{}).duplicate(true)
			active_expedition.clear()
			expedition_completed.emit(region,reward)
func start_expedition(region_id: String, resource_id: String, amount: int, reward_data: Dictionary) -> bool:
	if not active_expedition.is_empty() or not is_region_unlocked(region_id) or resource_id.is_empty() or amount <= 0: return false
	active_expedition = {"region":region_id,"resource":resource_id,"target":amount,"progress":0,"reward":reward_data.duplicate(true)}
	expedition_started.emit(region_id,resource_id,amount)
	status_changed.emit("Expedición activa: reúne "+str(amount)+" "+resource_id+".")
	return true
func cancel_expedition() -> bool:
	if active_expedition.is_empty(): return false
	active_expedition.clear()
	status_changed.emit("Expedición cancelada.")
	return true
func unlock_region(region_id: String) -> bool:
	if not REGIONS.has(region_id) or region_id in unlocked_regions: return false
	unlocked_regions.append(region_id)
	region_unlocked.emit(region_id)
	return true
func is_region_unlocked(region_id: String) -> bool: return region_id in unlocked_regions
func travel_to(region_id: String) -> bool:
	if not is_region_unlocked(region_id): return false
	current_region = region_id
	status_changed.emit("Sector actual: "+str(REGIONS.get(region_id,{}).get("title",region_id)))
	return true
func start_random_event() -> void:
	if not active_event.is_empty(): return
	active_event = EVENTS.pick_random().duplicate(true)
	event_remaining = event_duration_seconds
	world_event_started.emit(str(active_event.get("id","")),str(active_event.get("title","Evento")),str(active_event.get("resource","")),int(active_event.get("bonus",0)))
	status_changed.emit("Evento regional: "+str(active_event.get("title","")))
func get_event_bonus(resource_id: String) -> int:
	return maxi(0,int(active_event.get("bonus",0))) if not active_event.is_empty() and resource_id == str(active_event.get("resource","")) else 0
func get_status_text() -> String:
	var text := "REGIÓN: "+str(REGIONS.get(current_region,{}).get("title",current_region))
	if not active_mission.is_empty(): text += "\nMISIÓN: %s (%d/%d)" % [str(active_mission.get("title","")),mission_progress_value,int(active_mission.get("target",0))]
	else: text += "\nMISIÓN: sin misión activa"
	if not active_expedition.is_empty(): text += "\nEXPEDICIÓN: %s (%d/%d)" % [str(active_expedition.get("region","")),int(active_expedition.get("progress",0)),int(active_expedition.get("target",0))]
	if not active_event.is_empty(): text += "\nEVENTO: %s (%ds)" % [str(active_event.get("title","")),ceili(event_remaining)]
	return text
func export_state() -> Dictionary:
	return {"active_mission":active_mission.duplicate(true),"mission_progress":mission_progress_value,"completed_missions":completed_missions.duplicate(),"active_expedition":active_expedition.duplicate(true),"unlocked_regions":unlocked_regions.duplicate(),"current_region":current_region,"active_event":active_event.duplicate(true),"event_timer":event_timer,"event_remaining":event_remaining}
func import_state(data: Dictionary) -> void:
	active_mission = data.get("active_mission",{}).duplicate(true)
	mission_progress_value = maxi(0,int(data.get("mission_progress",0)))
	completed_missions.clear()
	for value in data.get("completed_missions",[]):
		var id := str(value)
		if not id.is_empty() and id not in completed_missions: completed_missions.append(id)
	active_expedition = data.get("active_expedition",{}).duplicate(true)
	unlocked_regions.clear()
	for value in data.get("unlocked_regions",["aurora_coast"]):
		var id := str(value)
		if REGIONS.has(id) and id not in unlocked_regions: unlocked_regions.append(id)
	if unlocked_regions.is_empty(): unlocked_regions.append("aurora_coast")
	current_region = str(data.get("current_region","aurora_coast"))
	if not is_region_unlocked(current_region): current_region = unlocked_regions[0]
	active_event = data.get("active_event",{}).duplicate(true)
	event_timer = maxf(0.0,float(data.get("event_timer",0.0)))
	event_remaining = maxf(0.0,float(data.get("event_remaining",0.0)))

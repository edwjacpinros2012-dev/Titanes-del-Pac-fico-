extends SceneTree

const GameStateScript = preload("res://scripts/core/game_state.gd")
const SaveManagerScript = preload("res://scripts/core/save_manager.gd")
const ThreatDirectorScript = preload("res://scripts/world/threat_director.gd")
const MissionRunManagerScript = preload("res://scripts/missions/mission_run_manager.gd")

func _initialize() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	_test_game_state()
	_test_save_manager()
	_test_threat_director()
	_test_mission_run_manager()
	print("TITANES_TESTS: all core tests passed")
	quit(0)

func _test_game_state() -> void:
	var state = GameStateScript.new()
	state.add_resource("metal", 20)
	assert(int(state.resources["metal"]) == 20)
	assert(state.can_afford({"metal": 12}))
	assert(state.spend({"metal": 12}))
	assert(int(state.resources["metal"]) == 8)
	assert(not state.spend({"metal": 99}))
	assert(int(state.resources["metal"]) == 8)
	state.unlock_region("emerald_jungle")
	state.unlock_region("emerald_jungle")
	assert(state.unlocked_regions.size() == 2)

func _test_save_manager() -> void:
	var manager = SaveManagerScript.new()
	var snapshot := {"resources":{"metal":44,"energia":21},"credits":150,"campaign_level":2,"active_contract":"coastal_patrol"}
	assert(manager.save_profile(snapshot))
	var loaded: Dictionary = manager.load_profile()
	assert(not loaded.is_empty())
	assert(int(loaded.get("credits", 0)) == 150)
	assert(str(loaded.get("active_contract", "")) == "coastal_patrol")
	assert(int(loaded.get("version", 0)) == 2)
	assert(manager.save_profile({"credits": 250, "campaign_level": 3}))
	var damaged_file := FileAccess.open("user://titanes_save.json", FileAccess.WRITE)
	assert(damaged_file != null)
	damaged_file.store_string("{ invalid json")
	damaged_file.close()
	var recovered: Dictionary = manager.load_profile()
	assert(int(recovered.get("credits", 0)) == 150, "corrupt primary save should recover the previous backup")
	assert(manager.save_profile(recovered), "recovered profile should be writable again")
	manager.free()

func _test_threat_director() -> void:
	var director = ThreatDirectorScript.new()
	var prepared := director.build_threat_brief({"pilot_level":2,"titan_generation":1,"titan_condition":1.0,"pilot_sync":1.0,"base_support":1.0,"intelligence":1.0,"regional_pressure":5.0,"mission_risk":0.0})
	var unprepared := director.build_threat_brief({"pilot_level":2,"titan_generation":1,"titan_condition":0.2,"pilot_sync":0.0,"base_support":0.0,"intelligence":0.0,"regional_pressure":80.0,"mission_risk":0.8})
	assert(int(unprepared["tier"]) > int(prepared["tier"]))
	assert(prepared["preparation_notes"].is_empty())
	assert(is_equal_approx(director.apply_outcome(50.0, "victory"), 36.0))
	assert(is_equal_approx(director.apply_outcome(50.0, "defeat"), 59.0))

func _test_mission_run_manager() -> void:
	var manager = MissionRunManagerScript.new()
	var mission := {
		"id": "aurora_first_contact",
		"objectives": [
			{"id": "reach_beacon", "target": 1, "optional": false},
			{"id": "scan_tracks", "target": 3, "optional": true}
		]
	}
	assert(manager.start_mission(mission, {"tier": 1}))
	assert(manager.phase == "deployment")
	assert(not manager.start_mission(mission))
	assert(manager.begin_operation())
	assert(not manager.record_objective_progress("missing", 1))
	assert(manager.record_objective_progress("reach_beacon", 1))
	assert(manager.record_objective_progress("scan_tracks", 9))
	var result: Dictionary = manager.resolve_mission("victory", {"metal": 10, "energy": 5})
	assert(result["outcome"] == "victory")
	assert(int(result["rewards"]["metal"]) == 10)
	assert(manager.phase == "debrief")
	assert(not manager.begin_operation())
	assert(manager.return_to_base())
	assert(manager.phase == "base")
	assert(not manager.return_to_base())

	var incomplete := {"id": "incomplete_test", "objectives": [{"id": "mandatory", "target": 2, "optional": false}]}
	assert(manager.start_mission(incomplete))
	assert(manager.begin_operation())
	var partial: Dictionary = manager.resolve_mission("victory", {"metal": 10})
	assert(partial["outcome"] == "partial")
	assert(int(partial["rewards"]["metal"]) == 6)
	assert(manager.return_to_base())
	manager.free()

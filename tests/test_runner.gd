extends SceneTree

const GameStateScript = preload("res://scripts/core/game_state.gd")
const SaveManagerScript = preload("res://scripts/core/save_manager.gd")
const ThreatDirectorScript = preload("res://scripts/world/threat_director.gd")

func _initialize() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	_test_game_state()
	_test_save_manager()
	_test_threat_director()
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

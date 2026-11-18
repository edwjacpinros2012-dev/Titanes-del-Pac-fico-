extends SceneTree

const ManagerScript = preload("res://scripts/systems/region_restoration_manager.gd")
var passed := 0
var failed := 0

func _initialize() -> void:
	call_deferred("_run")

func _check(ok: bool, label: String) -> void:
	if ok:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)

func _run() -> void:
	var manager = ManagerScript.new()
	var milestone_count := [0]
	manager.milestone_unlocked.connect(func(_region_id, _milestone_id, _threshold): milestone_count[0] += 1)
	root.add_child(manager)
	_check(manager.get_region_snapshot().progress == 0, "new region starts with no restoration progress")
	_check(manager.add_progress(12, "exploration") == 12, "exploration activity adds regional progress")
	_check(manager.add_progress(9, "ecology") == 9, "ecology category adds progress")
	_check(manager.get_region_snapshot().progress == 21, "region total combines activity categories")
	_check(manager.get_region_snapshot().stage == "Cartografiada", "20 percent threshold marks a sector surveyed")
	_check(manager.get_region_snapshot().milestones.has("surveyed"), "survey milestone is claimed once threshold is reached")
	_check(milestone_count[0] == 1, "milestone signal fires on first threshold crossing")
	_check(manager.add_progress(90, "infrastructure") == 79, "progress is capped at 100")
	_check(manager.get_region_snapshot().stage == "Estabilizada", "100 percent stage is reported")
	_check(milestone_count[0] == 4, "all milestone thresholds emit exactly once")
	_check(manager.add_progress(5, "research") == 0, "progress cannot exceed cap")
	_check(manager.add_progress(-3, "ecology") == 0, "negative progress is rejected")
	_check(manager.add_progress(5, "unknown") == 0, "unknown activity category is rejected")
	_check(not manager.set_active_region("missing_region"), "unknown region cannot be selected")
	_check(manager.set_active_region("broken_isles"), "known region can become active")
	manager.add_progress(8, "research")
	var saved := manager.export_state()
	var restored = ManagerScript.new()
	root.add_child(restored)
	_check(restored.import_state(saved), "valid region snapshot imports")
	_check(restored.get_region_snapshot("aurora_coast").progress == 100, "snapshot preserves first region progress")
	_check(restored.get_region_snapshot("broken_isles").progress == 8, "snapshot preserves active region progress")
	var invalid := saved.duplicate(true)
	invalid["regions"]["aurora_coast"]["progress"] = 101
	_check(not restored.import_state(invalid), "out-of-range region snapshot is rejected")
	invalid = saved.duplicate(true)
	invalid["regions"]["broken_isles"]["milestones"].append("unknown")
	_check(not restored.import_state(invalid), "unknown milestone in snapshot is rejected")
	print("REGION RESTORATION TESTS: %d passed, %d failed" % [passed, failed])
	quit(1 if failed > 0 else 0)

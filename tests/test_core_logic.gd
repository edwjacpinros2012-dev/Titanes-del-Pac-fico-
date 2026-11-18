extends SceneTree

const GameStateScript = preload("res://scripts/core/game_state.gd")

var passed := 0
var failed := 0

func _initialize() -> void:
	call_deferred("_run_tests")

func _check(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)

func _run_tests() -> void:
	var state = GameStateScript.new()
	_check(state.resources["metal"] == 0, "new state starts with zero metal")
	state.add_resource("metal", 25)
	_check(state.resources["metal"] == 25, "add_resource adds positive amount")
	state.add_resource("metal", -10)
	_check(state.resources["metal"] == 25, "add_resource ignores negative amount")
	_check(state.can_afford({"metal": 20}), "affordability true when balance covers cost")
	_check(not state.can_afford({"metal": 30}), "affordability false when balance insufficient")
	_check(state.spend({"metal": 10}), "spend succeeds when affordable")
	_check(state.resources["metal"] == 15, "spend deducts exact amount")
	_check(not state.spend({"metal": 20}), "spend fails without enough resources")
	_check(state.resources["metal"] == 15, "failed spend does not alter balance")
	_check(not state.can_afford({"metal": -5}), "negative cost rejected")
	_check(not state.spend({"metal": -5}), "negative spend rejected")
	_check(state.resources["metal"] == 15, "negative spend cannot mint resources")
	state.unlock_region("test_region")
	state.unlock_region("test_region")
	_check(state.unlocked_regions.count("test_region") == 1, "region unlock is idempotent")
	print("CORE TESTS: ", passed, " passed, ", failed, " failed")
	quit(1 if failed > 0 else 0)

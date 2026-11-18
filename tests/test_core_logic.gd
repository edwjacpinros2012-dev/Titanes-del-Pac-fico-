extends SceneTree

const GameStateScript = preload("res://scripts/core/game_state.gd")
const InventoryScript = preload("res://scripts/resources/inventory.gd")
const TradeManagerScript = preload("res://scripts/economy/trade_manager.gd")

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
	_check(state.base_level == 1 and state.titan_level == 1, "default progression levels are valid")
	_check(state.resources.has("energy") and state.resources.has("crystal"), "resource dictionary includes all core resources")
	var signal_counter := [0]
	state.resources_changed.connect(func(): signal_counter[0] += 1)
	state.add_resource("crystal", 3)
	_check(signal_counter[0] == 1, "resource changes emit one signal")
	var SaveManagerScript = preload("res://scripts/core/save_manager.gd")
	var save_manager = SaveManagerScript.new()
	state.base_level = 3
	state.titan_level = 4
	state.unlock_region("test_region_2")
	_check(save_manager.save_game(state), "save_game returns success")
	var loaded_state = GameStateScript.new()
	_check(save_manager.load_game(loaded_state), "load_game returns success for valid save")
	_check(loaded_state.resources["metal"] == 15 and loaded_state.resources["crystal"] == 3, "save/load preserves resource values")
	_check(loaded_state.base_level == 3 and loaded_state.titan_level == 4, "save/load preserves progression levels")
	_check(loaded_state.unlocked_regions.has("test_region_2"), "save/load preserves unlocked regions")
	_check(save_manager.save_profile({"profile_name": "test", "credits": 123, "flags": ["qa"]}), "save_profile accepts valid snapshot")
	var loaded_profile: Dictionary = save_manager.load_profile()
	_check(loaded_profile.get("version", 0) == 2, "profile save/load preserves version metadata")
	_check(loaded_profile.get("credits", -1) == 123, "profile save/load preserves credits field")
	_check(loaded_profile.get("flags", []).has("qa"), "profile save/load preserves custom snapshot fields")
	var state_after_profile_save = GameStateScript.new()
	_check(save_manager.load_game(state_after_profile_save), "game save remains readable after profile save")
	_check(state_after_profile_save.resources["metal"] == 15, "profile save no longer overwrites game save")
	
	var inventory = InventoryScript.new()
	inventory.add_item("metal", 5)
	_check(inventory.has_items({"metal": 5}), "inventory confirms sufficient item quantity")
	_check(not inventory.has_items({"metal": -2}), "inventory rejects negative costs")
	_check(not inventory.remove_items({"metal": -2}), "inventory refuses negative-cost removal")
	_check(inventory.items["metal"] == 5, "invalid inventory transaction does not mint items")
	_check(inventory.remove_items({"metal": 3}), "inventory removes valid cost")
	_check(inventory.items["metal"] == 2, "inventory deducts exact amount")
	var trade = TradeManagerScript.new()
	trade.credits = 0
	var wallet := {"metal": 0, "energia": 0, "cristal": 0}
	_check(not trade.buy_good("metal", -1, wallet), "market rejects negative quantity")
	_check(not trade.buy_good("cristal", 100, wallet), "market rejects purchase beyond stock")
	_check(not trade.buy_good("cristal", 1, wallet), "market rejects purchase without enough credits")
	trade.add_credits(100)
	_check(trade.buy_good("metal", 2, wallet), "market accepts affordable valid purchase")
	_check(wallet["metal"] == 2 and trade.credits == 76, "purchase updates inventory and wallet exactly")
	_check(trade.sell_good("metal", 1, wallet), "market accepts valid sale")
	_check(wallet["metal"] == 1 and trade.credits == 83, "sale updates inventory and wallet exactly")
	print("CORE TESTS: ", passed, " passed, ", failed, " failed")
	quit(1 if failed > 0 else 0)

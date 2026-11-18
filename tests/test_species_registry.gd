extends SceneTree

const RegistryScript = preload("res://scripts/ecology/species_registry.gd")
var passed := 0
var failed := 0
var research_total := 0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)

func _on_research(_species_id: String, amount: int) -> void:
	research_total += amount

func _run() -> void:
	var registry = RegistryScript.new()
	registry.research_data_awarded.connect(_on_research)
	_check(registry.observe("lumina_ray", "aurora_coast"), "valid region observation accepted")
	_check(registry.get_observation_count("lumina_ray") == 1, "first observation registered")
	_check(research_total == 2, "first milestone grants research data")
	_check(not registry.observe("lumina_ray", "broken_isles"), "wrong region rejected")
	_check(not registry.observe("unknown_species", "aurora_coast"), "unknown species rejected")
	registry.observe("lumina_ray", "aurora_coast")
	_check(research_total == 2, "duplicate milestone reward not repeated")
	registry.observe("lumina_ray", "aurora_coast")
	_check(research_total == 5, "three-observation milestone reward granted")
	_check(registry.get_completion("lumina_ray") == 0.6, "research completion progress correct")
	var snapshot: Dictionary = registry.export_snapshot()
	var restored = RegistryScript.new()
	_check(restored.import_snapshot(snapshot), "snapshot restores")
	_check(restored.get_observation_count("lumina_ray") == 3, "snapshot preserves observation count")
	_check(not restored.import_snapshot({"observations":{"lumina_ray":-2}}), "negative observation snapshot rejected")
	print("RESULT: ", passed, " passed; ", failed, " failed")
	quit(1 if failed > 0 else 0)

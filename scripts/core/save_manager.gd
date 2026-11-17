extends Node
class_name SaveManager

const SAVE_PATH := "user://titanes_save.json"
signal save_completed
signal load_completed(success: bool)

func save_game(state: GameState) -> bool:
	var payload := {
		"version": 1,
		"resources": state.resources,
		"base_level": state.base_level,
		"titan_level": state.titan_level,
		"unlocked_regions": state.unlocked_regions
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("No se pudo abrir el archivo de guardado.")
		return false
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()
	save_completed.emit()
	return true

func load_game(state: GameState) -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		load_completed.emit(false)
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		load_completed.emit(false)
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY or int(parsed.get("version", 0)) != 1:
		load_completed.emit(false)
		return false
	state.resources = parsed.get("resources", state.resources)
	state.base_level = int(parsed.get("base_level", 1))
	state.titan_level = int(parsed.get("titan_level", 1))
	state.unlocked_regions = parsed.get("unlocked_regions", ["aurora_coast"])
	state.resources_changed.emit()
	state.progression_changed.emit()
	load_completed.emit(true)
	return true

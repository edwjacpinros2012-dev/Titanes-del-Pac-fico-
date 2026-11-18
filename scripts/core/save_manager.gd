extends Node
class_name SaveManager

const SAVE_PATH := "user://titanes_save.json"
const PROFILE_PATH := "user://titanes_profile.json"
signal save_completed
signal load_completed(success: bool)

func save_game(state: GameState) -> bool:
	if state == null:
		return false
	var payload := {
		"version": 1,
		"resources": state.resources.duplicate(true),
		"base_level": maxi(1, state.base_level),
		"titan_level": maxi(1, state.titan_level),
		"unlocked_regions": state.unlocked_regions.duplicate()
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
	if state == null or not FileAccess.file_exists(SAVE_PATH):
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

	var loaded_resources: Variant = parsed.get("resources", {})
	if typeof(loaded_resources) != TYPE_DICTIONARY:
		load_completed.emit(false)
		return false
	for resource_id in loaded_resources:
		var amount := int(loaded_resources[resource_id])
		if amount < 0:
			load_completed.emit(false)
			return false
	var merged_resources: Dictionary = state.resources.duplicate(true)
	for resource_id in loaded_resources:
		merged_resources[str(resource_id)] = int(loaded_resources[resource_id])
	state.resources = merged_resources
	state.base_level = maxi(1, int(parsed.get("base_level", 1)))
	state.titan_level = maxi(1, int(parsed.get("titan_level", 1)))
	var loaded_regions: Variant = parsed.get("unlocked_regions", ["aurora_coast"])
	if typeof(loaded_regions) != TYPE_ARRAY:
		load_completed.emit(false)
		return false
	state.unlocked_regions.clear()
	for region_value in loaded_regions:
		var region_id := str(region_value).strip_edges()
		if not region_id.is_empty() and region_id not in state.unlocked_regions:
			state.unlocked_regions.append(region_id)
	if state.unlocked_regions.is_empty():
		state.unlocked_regions.append("aurora_coast")
	state.resources_changed.emit()
	state.progression_changed.emit()
	load_completed.emit(true)
	return true

func save_profile(snapshot: Dictionary) -> bool:
	var payload := snapshot.duplicate(true)
	payload["version"] = 2
	var file := FileAccess.open(PROFILE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("No se pudo guardar el perfil local.")
		return false
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()
	save_completed.emit()
	return true

func load_profile() -> Dictionary:
	if not FileAccess.file_exists(PROFILE_PATH):
		return {}
	var file := FileAccess.open(PROFILE_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	var version := int(parsed.get("version", 0))
	if version < 1 or version > 2:
		return {}
	return parsed

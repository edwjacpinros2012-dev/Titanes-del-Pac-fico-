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
		"unlocked_regions": state.unlocked_regions.duplicate(),
		"completed_missions": state.completed_missions.duplicate(),
		"selected_jaeger": state.selected_jaeger,
		"unlocked_jaegers": state.unlocked_jaegers.duplicate(),
		"jaeger_marks": state.jaeger_marks.duplicate(true)
	}
	if not _write_json_atomic(SAVE_PATH, payload):
		push_error("No se pudo guardar el progreso.")
		return false
	save_completed.emit()
	return true

func load_game(state: GameState) -> bool:
	if state == null:
		load_completed.emit(false)
		return false
	var parsed := _load_json_with_backup(SAVE_PATH)
	if parsed.is_empty() or int(parsed.get("version", 0)) != 1:
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
	var loaded_missions: Variant = parsed.get("completed_missions", [])
	var loaded_regions: Variant = parsed.get("unlocked_regions", ["aurora_coast"])
	var loaded_jaegers: Variant = parsed.get("unlocked_jaegers", ["gipsy"])
	var loaded_marks: Variant = parsed.get("jaeger_marks", {"gipsy": 1, "striker": 1, "cherno": 1})
	if typeof(loaded_missions) != TYPE_ARRAY or typeof(loaded_regions) != TYPE_ARRAY or typeof(loaded_jaegers) != TYPE_ARRAY or typeof(loaded_marks) != TYPE_DICTIONARY:
		load_completed.emit(false)
		return false
	var merged_resources: Dictionary = state.resources.duplicate(true)
	for resource_id in loaded_resources:
		merged_resources[str(resource_id)] = int(loaded_resources[resource_id])
	state.resources = merged_resources
	state.completed_missions.clear()
	for mission_value in loaded_missions:
		var mission_id := str(mission_value).strip_edges()
		if not mission_id.is_empty() and mission_id not in state.completed_missions:
			state.completed_missions.append(mission_id)
	state.base_level = maxi(1, int(parsed.get("base_level", 1)))
	state.titan_level = maxi(1, int(parsed.get("titan_level", 1)))
	state.unlocked_jaegers.clear()
	state.unlocked_jaegers.append("gipsy")
	for jaeger_value in loaded_jaegers:
		var jaeger_id := str(jaeger_value).strip_edges()
		if jaeger_id in GameState.JAEGER_IDS and jaeger_id not in state.unlocked_jaegers:
			state.unlocked_jaegers.append(jaeger_id)
	state.jaeger_marks = {"gipsy": 1, "striker": 1, "cherno": 1}
	for jaeger_id in GameState.JAEGER_IDS:
		var raw_mark: Variant = loaded_marks.get(jaeger_id, 1)
		if typeof(raw_mark) == TYPE_INT or typeof(raw_mark) == TYPE_FLOAT:
			state.jaeger_marks[jaeger_id] = clampi(int(raw_mark), 1, 10)
	var selected_jaeger := str(parsed.get("selected_jaeger", "gipsy"))
	state.selected_jaeger = selected_jaeger if selected_jaeger in state.unlocked_jaegers else "gipsy"
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
	if not _write_json_atomic(PROFILE_PATH, payload):
		push_error("No se pudo guardar el perfil local.")
		return false
	save_completed.emit()
	return true

func load_profile() -> Dictionary:
	var snapshot := _load_json_with_backup(PROFILE_PATH)
	var version := int(snapshot.get("version", 0))
	return snapshot if version >= 1 and version <= 2 else {}

func _load_json_with_backup(path: String) -> Dictionary:
	var backup_path := path + ".bak"
	var parsed: Variant = {}
	if FileAccess.file_exists(path):
		var file := FileAccess.open(path, FileAccess.READ)
		if file != null:
			parsed = JSON.parse_string(file.get_as_text())
			file.close()
	if typeof(parsed) == TYPE_DICTIONARY and not parsed.is_empty():
		return parsed
	if not FileAccess.file_exists(backup_path):
		return {}
	var absolute_target := ProjectSettings.globalize_path(path)
	var absolute_backup := ProjectSettings.globalize_path(backup_path)
	if FileAccess.file_exists(path):
		var corrupt_path := path + ".corrupt"
		var absolute_corrupt := ProjectSettings.globalize_path(corrupt_path)
		if FileAccess.file_exists(corrupt_path):
			DirAccess.remove_absolute(absolute_corrupt)
		DirAccess.rename_absolute(absolute_target, absolute_corrupt)
	if DirAccess.rename_absolute(absolute_backup, absolute_target) != OK:
		return {}
	var backup_file := FileAccess.open(path, FileAccess.READ)
	if backup_file == null:
		return {}
	var backup_parsed: Variant = JSON.parse_string(backup_file.get_as_text())
	backup_file.close()
	return backup_parsed if typeof(backup_parsed) == TYPE_DICTIONARY else {}

func _write_json_atomic(path: String, payload: Dictionary) -> bool:
	var temp_path := path + ".tmp"
	var backup_path := path + ".bak"
	var file := FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(payload, "\t"))
	file.flush()
	file.close()
	var absolute_target := ProjectSettings.globalize_path(path)
	var absolute_temp := ProjectSettings.globalize_path(temp_path)
	var absolute_backup := ProjectSettings.globalize_path(backup_path)
	if FileAccess.file_exists(path):
		if FileAccess.file_exists(backup_path):
			DirAccess.remove_absolute(absolute_backup)
		if DirAccess.rename_absolute(absolute_target, absolute_backup) != OK:
			DirAccess.remove_absolute(absolute_temp)
			return false
	if DirAccess.rename_absolute(absolute_temp, absolute_target) != OK:
		if FileAccess.file_exists(backup_path):
			DirAccess.rename_absolute(absolute_backup, absolute_target)
		DirAccess.remove_absolute(absolute_temp)
		return false
	return true

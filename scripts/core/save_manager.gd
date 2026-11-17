extends Node
class_name SaveManager

const SAVE_PATH := "user://titanes_save.json"
const TEMP_PATH := "user://titanes_save.json.tmp"
const BACKUP_PATH := "user://titanes_save.json.bak"

signal save_completed
signal load_completed(success: bool)

func save_game(state: GameState) -> bool:
	var payload := {"version":1,"resources":state.resources.duplicate(true),"base_level":state.base_level,"titan_level":state.titan_level,"unlocked_regions":state.unlocked_regions.duplicate()}
	return _write_payload(payload)

func load_game(state: GameState) -> bool:
	var parsed := _read_payload()
	if parsed.is_empty() or int(parsed.get("version",0)) != 1:
		load_completed.emit(false)
		return false
	state.resources = parsed.get("resources",state.resources).duplicate(true)
	state.base_level = int(parsed.get("base_level",1))
	state.titan_level = int(parsed.get("titan_level",1))
	state.unlocked_regions = parsed.get("unlocked_regions",["aurora_coast"])
	state.resources_changed.emit()
	state.progression_changed.emit()
	load_completed.emit(true)
	return true

func save_profile(snapshot: Dictionary) -> bool:
	var payload := snapshot.duplicate(true)
	payload["version"] = maxi(2,int(payload.get("version",2)))
	return _write_payload(payload)

func load_profile() -> Dictionary:
	var parsed := _read_payload()
	if parsed.is_empty():
		return {}
	var version := int(parsed.get("version",0))
	return parsed if version >= 1 and version <= 2 else {}

func _write_payload(payload: Dictionary) -> bool:
	var file := FileAccess.open(TEMP_PATH,FileAccess.WRITE)
	if file == null:
		push_error("No se pudo abrir el archivo temporal de guardado.")
		return false
	file.store_string(JSON.stringify(payload,"\t"))
	file.flush()
	file.close()
	var save_absolute := ProjectSettings.globalize_path(SAVE_PATH)
	var temp_absolute := ProjectSettings.globalize_path(TEMP_PATH)
	var backup_absolute := ProjectSettings.globalize_path(BACKUP_PATH)
	if FileAccess.file_exists(SAVE_PATH):
		if FileAccess.file_exists(BACKUP_PATH):
			if DirAccess.remove_absolute(backup_absolute) != OK:
				push_error("No se pudo retirar la copia de seguridad anterior.")
				return false
		if DirAccess.rename_absolute(save_absolute,backup_absolute) != OK:
			push_error("No se pudo crear la copia de seguridad del perfil.")
			return false
	if DirAccess.rename_absolute(temp_absolute,save_absolute) != OK:
		if not FileAccess.file_exists(SAVE_PATH) and FileAccess.file_exists(BACKUP_PATH):
			DirAccess.rename_absolute(backup_absolute,save_absolute)
		push_error("No se pudo finalizar el guardado del perfil.")
		return false
	save_completed.emit()
	return true

func _read_payload() -> Dictionary:
	for path in [SAVE_PATH,BACKUP_PATH]:
		if not FileAccess.file_exists(path):
			continue
		var file := FileAccess.open(path,FileAccess.READ)
		if file == null:
			continue
		var parsed: Variant = JSON.parse_string(file.get_as_text())
		file.close()
		if typeof(parsed) == TYPE_DICTIONARY:
			return parsed
	return {}

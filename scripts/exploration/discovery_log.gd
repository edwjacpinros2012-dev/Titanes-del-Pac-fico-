extends Node
class_name DiscoveryLog

signal discovery_recorded(discovery_id: String)
const SAVE_PATH := "user://discovery_log.json"
var discovered: Array[String] = []

func record(discovery_id: String) -> bool:
	if discovery_id.is_empty() or discovery_id in discovered:
		return false
	discovered.append(discovery_id)
	discovery_recorded.emit(discovery_id)
	return true

func save_log() -> bool:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify({"discoveries": discovered}))
	file.close()
	return true

func load_log() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	discovered.clear()
	for value in parsed.get("discoveries", []):
		discovered.append(str(value))
	return true

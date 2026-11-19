extends RefCounted
class_name ProfileStoreV2

## Versioned local profile store. Call load_profile() and save_profile() from a
## game manager; this script is intentionally not wired into the scene automatically.
const FILE_PATH := "user://profile_v2.json"
const TEMP_PATH := "user://profile_v2.tmp"
const BACKUP_PATH := "user://profile_v2.bak"
const SCHEMA_VERSION := 2

const DEFAULT_PROFILE := {
	"schema_version": SCHEMA_VERSION,
	"player": {"pilot_name": "Recluta", "rank": 1, "experience": 0},
	"resources": {"metal": 80, "energia": 45, "cristal": 12, "credits": 0},
	"progress": {"base_level": 1, "titan_level": 1, "research": 0, "unlocked_regions": ["costa_aurora"]},
	"settings": {"music_volume": 0.8, "sfx_volume": 0.8, "camera_sensitivity": 1.0},
	"updated_unix": 0
}

func load_profile() -> Dictionary:
	var loaded := _read_json(FILE_PATH)
	if loaded.is_empty():
		loaded = _read_json(BACKUP_PATH)
	if loaded.is_empty():
		return _deep_copy(DEFAULT_PROFILE)
	return _sanitize_profile(loaded)

func save_profile(profile: Dictionary) -> bool:
	var sanitized := _sanitize_profile(profile)
	sanitized["updated_unix"] = Time.get_unix_time_from_system()
	var file := FileAccess.open(TEMP_PATH, FileAccess.WRITE)
	if file == null:
		push_error("ProfileStoreV2: cannot open temp file; error %s" % FileAccess.get_open_error())
		return false
	file.store_string(JSON.stringify(sanitized, "\t"))
	file.flush()
	file.close()

	# Move the old profile to backup, then promote the temporary file. If promotion
	# fails, restore the previous profile instead of leaving the slot empty.
	var had_previous := FileAccess.file_exists(FILE_PATH)\tif had_previous:
		if FileAccess.file_exists(BACKUP_PATH):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(BACKUP_PATH))
		var backup_err := DirAccess.rename_absolute(ProjectSettings.globalize_path(FILE_PATH), ProjectSettings.globalize_path(BACKUP_PATH))
		if backup_err != OK:
			push_error("ProfileStoreV2: could not preserve previous profile (%s)." % backup_err)
			DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_PATH))
			return false

	var promote_err := DirAccess.rename_absolute(ProjectSettings.globalize_path(TEMP_PATH), ProjectSettings.globalize_path(FILE_PATH))
	if promote_err != OK:
		push_error("ProfileStoreV2: promotion failed (%s)." % promote_err)
		if had_previous and FileAccess.file_exists(BACKUP_PATH):
			DirAccess.rename_absolute(ProjectSettings.globalize_path(BACKUP_PATH), ProjectSettings.globalize_path(FILE_PATH))
		return false
	return true

func reset_profile() -> bool:
	return save_profile(_deep_copy(DEFAULT_PROFILE))

func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var text := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if not parsed is Dictionary:
		push_warning("ProfileStoreV2: invalid profile at %s" % path)
		return {}
	return parsed

func _sanitize_profile(source: Dictionary) -> Dictionary:
	var result := _deep_copy(DEFAULT_PROFILE)
	var player: Variant = source.get("player", {})
	var resources: Variant = source.get("resources", {})
	var progress: Variant = source.get("progress", {})
	var settings: Variant = source.get("settings", {})
	if player is Dictionary:
		result["player"]["pilot_name"] = _safe_string(player.get("pilot_name", "Recluta"), "Recluta", 24)
		result["player"]["rank"] = maxi(1, int(player.get("rank", 1)))
		result["player"]["experience"] = maxi(0, int(player.get("experience", 0)))
	if resources is Dictionary:
		for key in result["resources"].keys():
			result["resources"][key] = maxi(0, int(resources.get(key, result["resources"][key])))
	if progress is Dictionary:
		result["progress"]["base_level"] = maxi(1, int(progress.get("base_level", 1)))
		result["progress"]["titan_level"] = maxi(1, int(progress.get("titan_level", 1)))
		result["progress"]["research"] = maxi(0, int(progress.get("research", 0)))
		var regions: Variant = progress.get("unlocked_regions", ["costa_aurora"])
		if regions is Array:
			var clean_regions: Array[String] = []
			for region in regions:
				var region_id := _safe_string(region, "", 40)
				if not region_id.is_empty() and not clean_regions.has(region_id):
					clean_regions.append(region_id)
			result["progress"]["unlocked_regions"] = clean_regions if not clean_regions.is_empty() else ["costa_aurora"]
	if settings is Dictionary:
		result["settings"]["music_volume"] = clampf(float(settings.get("music_volume", 0.8)), 0.0, 1.0)
		result["settings"]["sfx_volume"] = clampf(float(settings.get("sfx_volume", 0.8)), 0.0, 1.0)
		result["settings"]["camera_sensitivity"] = clampf(float(settings.get("camera_sensitivity", 1.0)), 0.2, 3.0)
	result["schema_version"] = SCHEMA_VERSION
	return result

func _safe_string(value: Variant, fallback: String, max_length: int) -> String:
	if not value is String:
		return fallback
	var cleaned := value.strip_edges()
	if cleaned.is_empty():
		return fallback
	return cleaned.substr(0, max_length)

func _deep_copy(value: Variant) -> Variant:
	return value.duplicate(true) if value is Dictionary or value is Array else value

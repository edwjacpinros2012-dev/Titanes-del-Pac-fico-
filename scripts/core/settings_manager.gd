extends Node
class_name SettingsManager

signal settings_changed(settings: Dictionary)
const PATH := "user://titanes_settings.json"
const DEFAULTS := {
	"master_volume": 0.8,
	"music_volume": 0.65,
	"sfx_volume": 0.8,
	"language": "es",
	"subtitles": true,
	"screen_shake": true,
	"camera_sensitivity": 1.0,
	"touch_controls": true,
	"reduced_motion": false,
	"privacy_analytics_opt_in": false
}
var settings: Dictionary = {}

func _ready() -> void:
	load_settings()

func load_settings() -> Dictionary:
	var parsed: Variant = {}
	if FileAccess.file_exists(PATH):
		var file := FileAccess.open(PATH, FileAccess.READ)
		if file:
			parsed = JSON.parse_string(file.get_as_text())
			file.close()
	settings = DEFAULTS.duplicate(true)
	if typeof(parsed) == TYPE_DICTIONARY:
		for key in DEFAULTS:
			if parsed.has(key):
				settings[key] = parsed[key]
	_clamp_values()
	settings_changed.emit(settings.duplicate(true))
	return settings.duplicate(true)

func set_setting(key: String, value: Variant) -> bool:
	if not DEFAULTS.has(key):
		return false
	settings[key] = value
	_clamp_values()
	return save_settings()

func _clamp_values() -> void:
	for key in ["master_volume", "music_volume", "sfx_volume"]:
		settings[key] = clampf(float(settings.get(key, DEFAULTS[key])), 0.0, 1.0)
	settings["camera_sensitivity"] = clampf(float(settings.get("camera_sensitivity", 1.0)), 0.1, 3.0)
	settings["privacy_analytics_opt_in"] = bool(settings.get("privacy_analytics_opt_in", false))

func save_settings() -> bool:
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(settings, "\t"))
	file.flush()
	file.close()
	settings_changed.emit(settings.duplicate(true))
	return true

func reset_settings() -> bool:
	settings = DEFAULTS.duplicate(true)
	return save_settings()

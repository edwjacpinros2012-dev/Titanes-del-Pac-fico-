extends Node
signal settings_changed(settings: Dictionary)
const SETTINGS_PATH := "user://titanes_settings.json"
const DEFAULTS := {
	"master_volume": 1.0,
	"music_volume": 0.75,
	"sfx_volume": 0.85,
	"language": "es",
	"subtitles": true,
	"camera_sensitivity": 1.0,
	"touch_controls": true,
	"reduced_motion": false
}
var settings: Dictionary = DEFAULTS.duplicate(true)

func _ready() -> void:
	load_settings()
	settings_changed.connect(_apply_audio_settings)
	_apply_audio_settings(settings)

func load_settings() -> void:
	if FileAccess.file_exists(SETTINGS_PATH):
		var f := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
		if f:
			var parsed: Variant = JSON.parse_string(f.get_as_text())
			f.close()
			if typeof(parsed) == TYPE_DICTIONARY:
				for key in DEFAULTS:
					if parsed.has(key):
						settings[key] = _sanitize(key, parsed[key])
	settings_changed.emit(settings.duplicate(true))

func get_setting(key: String, fallback: Variant = null) -> Variant:
	return settings.get(key, fallback)

func set_setting(key: String, value: Variant) -> bool:
	if not DEFAULTS.has(key):
		return false
	settings[key] = _sanitize(key, value)
	save_settings()
	settings_changed.emit(settings.duplicate(true))
	return true

func import_snapshot(snapshot: Dictionary) -> void:
	for key in DEFAULTS:
		if snapshot.has(key):
			settings[key] = _sanitize(key, snapshot[key])
	save_settings()
	settings_changed.emit(settings.duplicate(true))

func export_snapshot() -> Dictionary:
	return settings.duplicate(true)

func reset_settings() -> void:
	settings = DEFAULTS.duplicate(true)
	save_settings()
	settings_changed.emit(settings.duplicate(true))

func save_settings() -> void:
	var f := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(settings, "\\t"))
		f.close()

func _apply_audio_settings(values: Dictionary) -> void:
	_set_bus_volume("Master", float(values.get("master_volume", 1.0)))
	_set_bus_volume("Music", float(values.get("music_volume", 0.75)))
	_set_bus_volume("SFX", float(values.get("sfx_volume", 0.85)))

func _set_bus_volume(bus_name: String, linear_value: float) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	if index < 0:
		return
	var normalized := clampf(linear_value, 0.0, 1.0)
	AudioServer.set_bus_mute(index, normalized <= 0.001)
	if normalized > 0.001:
		AudioServer.set_bus_volume_db(index, linear_to_db(normalized))

func _sanitize(key: String, value: Variant) -> Variant:
	match key:
		"master_volume", "music_volume", "sfx_volume":
			return clampf(float(value), 0.0, 1.0)
		"camera_sensitivity":
			return clampf(float(value), 0.25, 3.0)
		"language":
			return "en" if str(value) == "en" else "es"
		"subtitles", "touch_controls", "reduced_motion":
			return bool(value)
	return DEFAULTS.get(key, value)

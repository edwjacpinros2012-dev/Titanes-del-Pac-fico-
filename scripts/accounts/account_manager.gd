extends Node
class_name AccountManager

signal profile_ready(profile: Dictionary)
signal auth_state_changed(is_authenticated: bool, provider: String)
signal auth_error(message: String)

const PROFILE_PATH := "user://player_identity.json"
const PROFILE_SCHEMA := 1
var profile: Dictionary = {}
var authenticated := false
var provider := "offline"

func _ready() -> void:
	load_or_create_local_profile()

func load_or_create_local_profile() -> Dictionary:
	var data: Variant = {}
	if FileAccess.file_exists(PROFILE_PATH):
		var f := FileAccess.open(PROFILE_PATH, FileAccess.READ)
		if f:
			data = JSON.parse_string(f.get_as_text())
			f.close()
	if typeof(data) != TYPE_DICTIONARY or data.is_empty():
		data = _new_local_profile()
	profile = _normalize_profile(data)
	if not _write_profile():
		auth_error.emit("No se pudo guardar el perfil local.")
	profile_ready.emit(profile.duplicate(true))
	return profile.duplicate(true)

func _new_local_profile() -> Dictionary:
	return {
		"schema": PROFILE_SCHEMA,
		"player_id": "local_" + str(Time.get_unix_time_from_system()) + "_" + str(randi()),
		"display_name": "Piloto",
		"created_at": Time.get_datetime_string_from_system(true),
		"provider": "offline",
		"cloud_enabled": false
	}

func _normalize_profile(data: Dictionary) -> Dictionary:
	var normalized := data.duplicate(true)
	normalized["schema"] = PROFILE_SCHEMA
	if str(normalized.get("player_id", "")).is_empty():
		normalized["player_id"] = str(_new_local_profile()["player_id"])
	if str(normalized.get("display_name", "")).strip_edges().is_empty():
		normalized["display_name"] = "Piloto"
	normalized["provider"] = str(normalized.get("provider", "offline"))
	normalized["cloud_enabled"] = bool(normalized.get("cloud_enabled", false))
	return normalized

func set_display_name(new_name: String) -> bool:
	var clean := new_name.strip_edges()
	if clean.is_empty() or clean.length() > 24:
		return false
	profile["display_name"] = clean
	return _write_profile()

func _write_profile() -> bool:
	var f := FileAccess.open(PROFILE_PATH, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(profile, "\t"))
	f.flush()
	f.close()
	return true

## OAuth must be implemented by a platform/provider SDK and server configuration.
## Never accept a raw Google password or store tokens in this manager.
func begin_google_sign_in() -> void:
	auth_error.emit("Google OAuth todavía no está configurado. Se requiere proveedor OAuth, callback seguro y validación del servidor.")

func complete_provider_sign_in(provider_name: String, verified_player_id: String) -> bool:
	if provider_name != "google" or verified_player_id.strip_edges().is_empty():
		auth_error.emit("La identidad del proveedor no pudo verificarse.")
		return false
	profile["provider"] = "google"
	profile["provider_player_id"] = verified_player_id
	profile["cloud_enabled"] = true
	if not _write_profile():
		auth_error.emit("No se pudo guardar la vinculación.")
		return false
	authenticated = true
	provider = provider_name
	auth_state_changed.emit(true, provider)
	return true

func sign_out_to_offline() -> void:
	authenticated = false
	provider = "offline"
	profile["provider"] = "offline"
	profile["cloud_enabled"] = false
	profile.erase("provider_player_id")
	_write_profile()
	auth_state_changed.emit(false, provider)

func get_profile() -> Dictionary:
	return profile.duplicate(true)

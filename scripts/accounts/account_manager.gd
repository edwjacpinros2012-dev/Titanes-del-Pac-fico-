extends Node
signal profile_changed(profile: Dictionary)
signal authentication_status_changed(message: String)

const PROFILE_PATH := "user://player_identity.json"
var profile: Dictionary = {}
var google_provider_ready := false

func _ready() -> void:
	load_or_create_profile()

func load_or_create_profile() -> Dictionary:
	var parsed: Variant = {}
	if FileAccess.file_exists(PROFILE_PATH):
		var f := FileAccess.open(PROFILE_PATH, FileAccess.READ)
		if f:
			parsed = JSON.parse_string(f.get_as_text())
			f.close()
	if typeof(parsed) == TYPE_DICTIONARY and not parsed.is_empty():
		profile = parsed
	else:
		profile = {
			"schema_version": 1,
			"player_id": _new_local_id(),
			"display_name": "Piloto",
			"provider": "offline",
			"google_linked": false,
			"cloud_enabled": false
		}
	_save_profile()
	profile_changed.emit(profile.duplicate(true))
	return profile.duplicate(true)

func _new_local_id() -> String:
	return "local_" + str(Time.get_unix_time_from_system()) + "_" + str(randi())

func set_display_name(value: String) -> bool:
	var clean := value.strip_edges()
	if clean.length() < 1 or clean.length() > 24:
		authentication_status_changed.emit("El nombre debe tener entre 1 y 24 caracteres.")
		return false
	profile["display_name"] = clean
	_save_profile()
	profile_changed.emit(profile.duplicate(true))
	authentication_status_changed.emit("Nombre de piloto guardado localmente.")
	return true

func begin_google_sign_in() -> void:
	authentication_status_changed.emit("Google no está conectado todavía. Falta configurar OAuth, backend y callback seguro. Puedes seguir jugando sin cuenta.")
	return

func begin_offline_session() -> void:
	profile["provider"] = "offline"
	profile["google_linked"] = false
	profile["cloud_enabled"] = false
	_save_profile()
	profile_changed.emit(profile.duplicate(true))
	authentication_status_changed.emit("Modo offline activo. El progreso se guarda en este dispositivo.")

func is_google_linked() -> bool:
	return bool(profile.get("google_linked", false)) and str(profile.get("provider", "")) == "google"

func export_snapshot() -> Dictionary:
	return profile.duplicate(true)

func _save_profile() -> void:
	var file := FileAccess.open(PROFILE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("No se pudo escribir la identidad local.")
		return
	file.store_string(JSON.stringify(profile, "\t"))
	file.close()

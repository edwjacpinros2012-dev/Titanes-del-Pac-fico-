extends Node

signal profile_changed(profile: Dictionary)
signal authentication_status_changed(message: String)

const PROFILE_PATH := "user://player_identity.json"
const TEMP_PATH := "user://player_identity.tmp"
const BACKUP_PATH := "user://player_identity.bak"
const PROFILE_SCHEMA_VERSION := 3
const MIN_DISPLAY_NAME_LENGTH := 3
const MAX_DISPLAY_NAME_LENGTH := 20

var profile: Dictionary = {}
var google_provider_ready := false
var last_load_warning := ""

func _ready() -> void:
	load_or_create_profile()

func load_or_create_profile() -> Dictionary:
	var parsed := _read_json_file(PROFILE_PATH)
	if parsed.is_empty():
		parsed = _read_json_file(BACKUP_PATH)
		if not parsed.is_empty():
			last_load_warning = "Se recuperó el perfil desde la copia de seguridad."
	if not parsed.is_empty() and _is_valid_profile(parsed):
		profile = _migrate_profile(parsed)
		profile["last_login_at"] = int(Time.get_unix_time_from_system())
		_save_profile()
	else:
		if FileAccess.file_exists(PROFILE_PATH) or FileAccess.file_exists(BACKUP_PATH):
			last_load_warning = "No se pudo validar el perfil anterior. Se creó un perfil local nuevo."
		profile = _new_local_profile()
		_save_profile()
	profile_changed.emit(profile.duplicate(true))
	return profile.duplicate(true)

func _read_json_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		last_load_warning = "No se pudo abrir el archivo del perfil."
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	return parsed if parsed is Dictionary else {}

func _new_local_profile(display_name := "Piloto") -> Dictionary:
	var now := int(Time.get_unix_time_from_system())
	return {
		"schema_version": PROFILE_SCHEMA_VERSION,
		"player_id": _new_local_id(),
		"display_name": display_name,
		"provider": "offline",
		"google_linked": false,
		"cloud_enabled": false,
		"created_at": now,
		"last_login_at": now,
		"pilot_level": 1,
		"tutorial_completed": false
	}

func _new_local_id() -> String:
	return "pilot_" + str(Time.get_unix_time_from_system()) + "_" + str(randi()).pad_zeros(8)

func validate_display_name(value: String) -> bool:
	var clean := value.strip_edges()
	if clean.length() < MIN_DISPLAY_NAME_LENGTH or clean.length() > MAX_DISPLAY_NAME_LENGTH:
		return false
	for index in range(clean.length()):
		var code := clean.unicode_at(index)
		if code < 32 or code == 127:
			return false
	return true

func _is_valid_profile(candidate: Dictionary) -> bool:
	var player_id := str(candidate.get("player_id", "")).strip_edges()
	var display_name := str(candidate.get("display_name", "")).strip_edges()
	var provider := str(candidate.get("provider", "offline"))
	if player_id.is_empty() or not validate_display_name(display_name):
		return false
	if provider not in ["offline", "google"]:
		return false
	# No se acepta una identidad Google declarada por un JSON local.
	if provider == "google" or bool(candidate.get("google_linked", false)):
		return false
	return true

func _migrate_profile(candidate: Dictionary) -> Dictionary:
	var migrated := candidate.duplicate(true)
	migrated["schema_version"] = PROFILE_SCHEMA_VERSION
	migrated["provider"] = "offline"
	migrated["google_linked"] = false
	migrated["cloud_enabled"] = false
	migrated["display_name"] = str(candidate.get("display_name", "Piloto")).strip_edges()
	migrated["pilot_level"] = maxi(1, int(candidate.get("pilot_level", 1)))
	migrated["tutorial_completed"] = bool(candidate.get("tutorial_completed", false))
	if not migrated.has("created_at"):
		migrated["created_at"] = int(Time.get_unix_time_from_system())
	return migrated

func create_local_profile(display_name: String) -> bool:
	var clean := display_name.strip_edges()
	if not validate_display_name(clean):
		authentication_status_changed.emit("El nombre debe tener entre 3 y 20 caracteres.")
		return false
	if not profile.is_empty() and str(profile.get("display_name", "")).to_lower() == clean.to_lower():
		profile["last_login_at"] = int(Time.get_unix_time_from_system())
		if not _save_profile():
			authentication_status_changed.emit("No se pudo actualizar el perfil local.")
			return false
		profile_changed.emit(profile.duplicate(true))
		authentication_status_changed.emit("Perfil local encontrado. Sesión iniciada en este dispositivo.")
		return true
	profile = _new_local_profile(clean)
	if not _save_profile():
		authentication_status_changed.emit("No se pudo guardar el perfil. Comprueba el espacio disponible.")
		return false
	profile_changed.emit(profile.duplicate(true))
	authentication_status_changed.emit("Piloto registrado en este dispositivo. El progreso se guarda localmente.")
	return true

func set_display_name(value: String) -> bool:
	var clean := value.strip_edges()
	if not validate_display_name(clean):
		authentication_status_changed.emit("El nombre debe tener entre 3 y 20 caracteres.")
		return false
	if profile.is_empty():
		profile = _new_local_profile(clean)
	else:
		profile["display_name"] = clean
		profile["last_login_at"] = int(Time.get_unix_time_from_system())
	if not _save_profile():
		return false
	profile_changed.emit(profile.duplicate(true))
	authentication_status_changed.emit("Nombre de piloto guardado localmente.")
	return true

func begin_google_sign_in() -> void:
	# El flujo real requiere OAuth, configuración del proveedor y validación de token
	# en un backend propio. Nunca se simula una sesión externa.
	authentication_status_changed.emit("Google todavía no está conectado. Puedes crear y usar un perfil local sin cuenta externa.")

func begin_offline_session() -> void:
	if profile.is_empty():
		profile = _new_local_profile()
	profile["last_login_at"] = int(Time.get_unix_time_from_system())
	if not _save_profile():
		authentication_status_changed.emit("No se pudo guardar el perfil local.")
		return
	profile_changed.emit(profile.duplicate(true))
	authentication_status_changed.emit("Modo offline activo. Tu perfil permanece en este dispositivo.")

func update_tutorial_completed(completed: bool) -> void:
	profile["tutorial_completed"] = completed
	_save_profile()
	profile_changed.emit(profile.duplicate(true))

func is_google_linked() -> bool:
	return false

func export_snapshot() -> Dictionary:
	return profile.duplicate(true)

func _save_profile() -> bool:
	if profile.is_empty():
		return false
	var file := FileAccess.open(TEMP_PATH, FileAccess.WRITE)
	if file == null:
		last_load_warning = "No se pudo crear el archivo temporal del perfil."
		return false
	file.store_string(JSON.stringify(profile, "\t"))
	file.flush()
	file.close()
	var target := ProjectSettings.globalize_path(PROFILE_PATH)
	var temporary := ProjectSettings.globalize_path(TEMP_PATH)
	var backup := ProjectSettings.globalize_path(BACKUP_PATH)
	if FileAccess.file_exists(PROFILE_PATH):
		if FileAccess.file_exists(BACKUP_PATH):
			DirAccess.remove_absolute(backup)
		var backup_error := DirAccess.rename_absolute(target, backup)
		if backup_error != OK:
			last_load_warning = "No se pudo crear la copia de seguridad del perfil."
			DirAccess.remove_absolute(temporary)
			return false
	var move_error := DirAccess.rename_absolute(temporary, target)
	if move_error != OK:
		last_load_warning = "No se pudo finalizar el guardado del perfil."
		if FileAccess.file_exists(BACKUP_PATH):
			DirAccess.rename_absolute(backup, target)
		return false
	return true

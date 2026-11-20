extends Node
signal profile_changed(profile: Dictionary)
signal authentication_status_changed(message: String)

const PROFILE_PATH := "user://player_identity.json"
const PROFILE_SCHEMA_VERSION := 2
const MIN_DISPLAY_NAME_LENGTH := 1
const MAX_DISPLAY_NAME_LENGTH := 24

var profile: Dictionary = {}
var google_provider_ready := false
var last_load_warning := ""

func _ready() -> void:
	load_or_create_profile()

func load_or_create_profile() -> Dictionary:
	var parsed: Variant = null
	if FileAccess.file_exists(PROFILE_PATH):
		var file := FileAccess.open(PROFILE_PATH, FileAccess.READ)
		if file != null:
			parsed = JSON.parse_string(file.get_as_text())
			file.close()
		else:
			last_load_warning = "No se pudo leer el perfil local."
	if parsed is Dictionary and _is_valid_profile(parsed):
		profile = _normalize_profile(parsed)
	else:
		if FileAccess.file_exists(PROFILE_PATH):
			last_load_warning = "El perfil local no era válido; se inició un perfil nuevo sin importar datos dudosos."
		profile = _new_local_profile()
		_save_profile()
	profile_changed.emit(profile.duplicate(true))
	return profile.duplicate(true)

func _new_local_profile() -> Dictionary:
	var now := int(Time.get_unix_time_from_system())
	return {
		"schema_version": PROFILE_SCHEMA_VERSION,
		"player_id": _new_local_id(),
		"display_name": "Piloto",
		"provider": "offline",
		"google_linked": false,
		"cloud_enabled": false,
		"created_at": now,
		"last_login_at": now
	}

func _new_local_id() -> String:
	return "local_" + str(Time.get_unix_time_from_system()) + "_" + str(randi())

func _is_valid_profile(candidate: Dictionary) -> bool:
	var player_id := str(candidate.get("player_id", "")).strip_edges()
	var display_name := str(candidate.get("display_name", "")).strip_edges()
	var provider := str(candidate.get("provider", "offline"))
	if player_id.is_empty():
		return false
	if display_name.length() < MIN_DISPLAY_NAME_LENGTH or display_name.length() > MAX_DISPLAY_NAME_LENGTH:
		return false
	if provider not in ["offline", "google"]:
		return false
	# Google identity must never be inferred from a local JSON flag alone.
	if provider == "google" or bool(candidate.get("google_linked", false)):
		return false
	return true

func _normalize_profile(candidate: Dictionary) -> Dictionary:
	var normalized := candidate.duplicate(true)
	normalized["schema_version"] = PROFILE_SCHEMA_VERSION
	normalized["provider"] = "offline"
	normalized["google_linked"] = false
	normalized["cloud_enabled"] = false
	normalized["display_name"] = str(candidate.get("display_name", "Piloto")).strip_edges()
	if not normalized.has("created_at"):
		normalized["created_at"] = int(Time.get_unix_time_from_system())
	normalized["last_login_at"] = int(Time.get_unix_time_from_system())
	return normalized

func set_display_name(value: String) -> bool:
	var clean := value.strip_edges()
	if clean.length() < MIN_DISPLAY_NAME_LENGTH or clean.length() > MAX_DISPLAY_NAME_LENGTH:
		authentication_status_changed.emit("El nombre debe tener entre 1 y 24 caracteres.")
		return false
	profile["display_name"] = clean
	_save_profile()
	profile_changed.emit(profile.duplicate(true))
	authentication_status_changed.emit("Nombre de piloto guardado localmente.")
	return true

func create_local_profile(display_name: String) -> bool:
	if not set_display_name(display_name):
		return false
	profile["last_login_at"] = int(Time.get_unix_time_from_system())
	_save_profile()
	authentication_status_changed.emit("Perfil local creado. Puedes jugar sin conectar una cuenta externa.")
	return true

func begin_google_sign_in() -> void:
	if not google_provider_ready:
		authentication_status_changed.emit("Registro con Google aún no disponible: falta OAuth y verificación segura del servidor. No se ha iniciado sesión.")
		return
	authentication_status_changed.emit("El proveedor está marcado como disponible, pero falta implementar el flujo de autenticación verificado.")

func begin_offline_session() -> void:
	profile["provider"] = "offline"
	profile["google_linked"] = false
	profile["cloud_enabled"] = false
	profile["last_login_at"] = int(Time.get_unix_time_from_system())
	_save_profile()
	profile_changed.emit(profile.duplicate(true))
	authentication_status_changed.emit("Modo offline activo. El progreso se guarda en este dispositivo.")

func is_google_linked() -> bool:
	return false

func export_snapshot() -> Dictionary:
	return profile.duplicate(true)

func _save_profile() -> void:
	var file := FileAccess.open(PROFILE_PATH, FileAccess.WRITE)
	if file == null:
		last_load_warning = "No se pudo guardar la identidad local."
		push_error(last_load_warning)
		return
	file.store_string(JSON.stringify(profile, "\\t"))
	file.close()

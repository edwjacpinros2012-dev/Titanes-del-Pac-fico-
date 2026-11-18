extends Node
class_name CloudSyncManager

signal sync_state_changed(state: String)
signal sync_error(message: String)
signal sync_completed

enum SyncState { OFFLINE, IDLE, SYNCING, ERROR }
var state := SyncState.OFFLINE
var cloud_configured := false
var account_linked := false

func configure(endpoint: String, public_client_key: String) -> bool:
	# Public client keys only. Never put service-role/private secrets in a Godot client.
	cloud_configured = endpoint.begins_with("https://") and not public_client_key.strip_edges().is_empty()
	state = SyncState.IDLE if cloud_configured and account_linked else SyncState.OFFLINE
	sync_state_changed.emit(_state_name())
	return cloud_configured

func set_account_linked(linked: bool) -> void:
	account_linked = linked
	state = SyncState.IDLE if linked and cloud_configured else SyncState.OFFLINE
	sync_state_changed.emit(_state_name())

func request_sync(local_snapshot: Dictionary) -> bool:
	if not cloud_configured or not account_linked:
		sync_error.emit("La sincronización requiere una cuenta vinculada y backend configurado.")
		return false
	if local_snapshot.is_empty():
		sync_error.emit("No hay datos locales para sincronizar.")
		return false
	# Deliberately not performing network writes until the backend endpoint,
	# authentication SDK, server-side validation and conflict policy are configured.
	state = SyncState.IDLE
	sync_state_changed.emit(_state_name())
	sync_error.emit("Backend pendiente: no se ha enviado ningún dato.")
	return false

func _state_name() -> String:
	match state:
		SyncState.IDLE: return "idle"
		SyncState.SYNCING: return "syncing"
		SyncState.ERROR: return "error"
		_: return "offline"

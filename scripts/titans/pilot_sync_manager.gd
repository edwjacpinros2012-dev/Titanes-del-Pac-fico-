extends Node
class_name PilotSyncManager

signal sync_progress_changed(value: float)
signal synchronization_started
signal synchronization_ended

@export_range(1.0, 30.0, 0.5) var charge_seconds: float = 5.0
@export_range(1.0, 30.0, 0.5) var active_seconds: float = 10.0
@export_range(0.0, 1.0, 0.05) var decay_per_second: float = 0.18

var sync_value: float = 0.0
var active_time_left: float = 0.0
var is_synchronized: bool = false

func _process(delta: float) -> void:
	if is_synchronized:
		active_time_left = maxf(0.0, active_time_left - delta)
		if active_time_left <= 0.0:
			is_synchronized = false
			synchronization_ended.emit()
		return

	if Input.is_action_pressed("sync_pilots"):
		sync_value = minf(1.0, sync_value + delta / charge_seconds)
		if sync_value >= 1.0:
			is_synchronized = true
			active_time_left = active_seconds
			synchronization_started.emit()
	else:
		sync_value = maxf(0.0, sync_value - decay_per_second * delta)

	sync_progress_changed.emit(sync_value)

func get_status_text() -> String:
	if is_synchronized:
		return "SINCRONIZACIÓN ACTIVA: %.0f s" % active_time_left
	return "ENLACE DE PILOTOS: %d%%" % roundi(sync_value * 100.0)

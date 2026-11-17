extends Node
class_name WorldEventManager

signal event_started(event_id: String, title: String)
signal event_ended(event_id: String)

@export var event_interval: float = 240.0
@export var event_duration: float = 60.0
@export var event_definitions: Array[Dictionary] = [
	{"id":"crystal_surge","title":"Resonancia de cristales","resource":"crystal","bonus":2},
	{"id":"calm_tides","title":"Marea tranquila","resource":"energy","bonus":1},
	{"id":"mineral_wind","title":"Viento mineral","resource":"metal","bonus":2}
]
var timer := 0.0
var remaining := 0.0
var active_event: Dictionary = {}

func _process(delta: float) -> void:
	if not active_event.is_empty():
		remaining -= delta
		if remaining <= 0.0:
			var ended_id := str(active_event.get("id", ""))
			active_event.clear()
			event_ended.emit(ended_id)
		return
	timer += delta
	if timer >= event_interval and not event_definitions.is_empty():
		timer = 0.0
		active_event = event_definitions.pick_random()
		remaining = event_duration
		event_started.emit(str(active_event.get("id", "")), str(active_event.get("title", "Evento")))

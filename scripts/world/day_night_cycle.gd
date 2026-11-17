extends Node
class_name DayNightCycle

signal time_changed(hour: float)
signal day_started(day_number: int)

@export_range(1.0, 120.0, 1.0) var day_length_minutes: float = 24.0
var time_of_day := 8.0
var day_number := 1

func _process(delta: float) -> void:
	var hours_per_second := 24.0 / (day_length_minutes * 60.0)
	time_of_day += delta * hours_per_second
	if time_of_day >= 24.0:
		time_of_day -= 24.0
		day_number += 1
		day_started.emit(day_number)
	time_changed.emit(time_of_day)

func is_night() -> bool:
	return time_of_day < 6.0 or time_of_day >= 19.0

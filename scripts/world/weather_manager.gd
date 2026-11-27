extends Node
class_name WeatherManager

signal weather_changed(weather_id: String)
signal weather_intensity_changed(value: float)

@export var change_interval: float = 180.0
@export var possible_weather: Array[String] = ["clear", "rain", "fog", "storm"]
var current_weather := "clear"
var intensity := 0.0
var elapsed := 0.0

func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= change_interval:
		elapsed = 0.0
		_roll_weather()

func _roll_weather() -> void:
	if possible_weather.is_empty():
		return
	var next_weather: String = possible_weather.pick_random()
	if next_weather == current_weather:
		return
	current_weather = next_weather
	intensity = randf_range(0.25, 1.0) if current_weather != "clear" else 0.0
	weather_changed.emit(current_weather)
	weather_intensity_changed.emit(intensity)

func get_exploration_modifier() -> float:
	match current_weather:
		"fog": return 0.8
		"storm": return 0.65
		"rain": return 0.9
		_: return 1.0

func get_status_text() -> String:
	var labels := {
		"clear": "Despejado",
		"rain": "Lluvia",
		"fog": "Niebla",
		"storm": "Tormenta"
	}
	return "CLIMA: %s | Reconocimiento x%.2f" % [
		str(labels.get(current_weather, current_weather)),
		get_exploration_modifier()
	]

func export_state() -> Dictionary:
	return {
		"version": 1,
		"current_weather": current_weather,
		"intensity": intensity,
		"elapsed": elapsed
	}

func import_state(data: Dictionary) -> void:
	var fallback_weather := "clear"
	if not possible_weather.is_empty():
		fallback_weather = "clear" if "clear" in possible_weather else possible_weather[0]
	var requested_weather := str(data.get("current_weather", fallback_weather))
	current_weather = requested_weather if requested_weather in possible_weather else fallback_weather
	intensity = clampf(float(data.get("intensity", 0.0)), 0.0, 1.0)
	if current_weather == "clear":
		intensity = 0.0
	elapsed = clampf(float(data.get("elapsed", 0.0)), 0.0, maxf(change_interval, 0.0))

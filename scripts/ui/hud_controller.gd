extends CanvasLayer
class_name HUDController
@export var resource_label: Label
@export var level_label: Label
func bind_game_state(state: GameState) -> void:
	if state == null: return
	state.resources_changed.connect(func(): refresh(state))
	state.progression_changed.connect(func(): refresh(state))
	refresh(state)
func refresh(state: GameState) -> void:
	if resource_label:
		resource_label.text = "Metal: %d   Energía: %d   Cristal: %d" % [int(state.resources.get("metal", 0)), int(state.resources.get("energy", 0)), int(state.resources.get("crystal", 0))]
	if level_label:
		level_label.text = "Base %d  |  Titán %d" % [state.base_level, state.titan_level]

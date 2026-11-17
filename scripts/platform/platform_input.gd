extends Control
class_name PlatformInput

signal action_tapped(action_name: String)

const BUTTON_SIZE := Vector2(48, 48)
const GAME_ACTIONS := [
	["E", "collect"], ["J", "kaiju_engage"], ["G", "kaiju_retreat"],
	["T", "evolve_titan"], ["B", "upgrade_base"], ["V", "base_select_next"],
	["N", "base_upgrade_selected"], ["C", "market_toggle"]
]

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if OS.has_feature("mobile") or DisplayServer.is_touchscreen_available():
		_build_touch_controls()

func _build_touch_controls() -> void:
	var movement_panel := PanelContainer.new()
	movement_panel.anchor_left = 0.02
	movement_panel.anchor_top = 0.70
	movement_panel.anchor_right = 0.43
	movement_panel.anchor_bottom = 0.98
	add_child(movement_panel)
	var movement_grid := GridContainer.new()
	movement_grid.columns = 3
	movement_grid.add_theme_constant_override("h_separation", 3)
	movement_grid.add_theme_constant_override("v_separation", 3)
	movement_panel.add_child(movement_grid)
	_add_spacer(movement_grid)
	_add_hold_button(movement_grid, "↑", "move_forward")
	_add_spacer(movement_grid)
	_add_hold_button(movement_grid, "←", "move_left")
	_add_spacer(movement_grid)
	_add_hold_button(movement_grid, "→", "move_right")
	_add_spacer(movement_grid)
	_add_hold_button(movement_grid, "↓", "move_back")
	_add_spacer(movement_grid)

	var actions_panel := PanelContainer.new()
	actions_panel.anchor_left = 0.55
	actions_panel.anchor_top = 0.70
	actions_panel.anchor_right = 0.98
	actions_panel.anchor_bottom = 0.98
	add_child(actions_panel)
	var actions_grid := GridContainer.new()
	actions_grid.columns = 3
	actions_grid.add_theme_constant_override("h_separation", 3)
	actions_grid.add_theme_constant_override("v_separation", 3)
	actions_panel.add_child(actions_grid)
	for item in GAME_ACTIONS:
		_add_tap_button(actions_grid, str(item[0]), str(item[1]))

func _add_spacer(parent: GridContainer) -> void:
	var spacer := Control.new()
	spacer.custom_minimum_size = BUTTON_SIZE
	parent.add_child(spacer)

func _add_hold_button(parent: GridContainer, caption: String, action_name: String) -> void:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = BUTTON_SIZE
	button.focus_mode = Control.FOCUS_NONE
	button.button_down.connect(func() -> void:
		Input.action_press(action_name)
	)
	button.button_up.connect(func() -> void:
		Input.action_release(action_name)
	)
	parent.add_child(button)

func _add_tap_button(parent: GridContainer, caption: String, action_name: String) -> void:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = BUTTON_SIZE
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(func() -> void:
		action_tapped.emit(action_name)
	)
	parent.add_child(button)

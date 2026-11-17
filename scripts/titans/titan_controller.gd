extends CharacterBody3D
class_name TitanController

@export var stats: TitanStats
@export var acceleration: float = 18.0
@export var gravity: float = 24.0

var input_enabled := true
var sync_multiplier: float = 1.0
var research_speed_multiplier: float = 1.0

func _ready() -> void:
	_ensure_action("move_left", KEY_A)
	_ensure_action("move_right", KEY_D)
	_ensure_action("move_forward", KEY_W)
	_ensure_action("move_back", KEY_S)

func _ensure_action(action_name: String, keycode: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	for existing in InputMap.action_get_events(action_name):
		if existing is InputEventKey and existing.physical_keycode == keycode:
			return
	var key_event := InputEventKey.new()
	key_event.physical_keycode = keycode
	InputMap.action_add_event(action_name, key_event)

func _physics_process(delta: float) -> void:
	if not input_enabled:
		velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)
		velocity.z = move_toward(velocity.z, 0.0, acceleration * delta)
	else:
		var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		var direction := Vector3(input_vector.x, 0.0, input_vector.y).normalized()
		var base_speed := stats.move_speed if stats else 7.0
		var speed := base_speed * sync_multiplier * research_speed_multiplier
		velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, direction.z * speed, acceleration * delta)
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0
	move_and_slide()
	if Vector2(velocity.x, velocity.z).length() > 0.2:
		rotation.y = lerp_angle(rotation.y, atan2(velocity.x, velocity.z), delta * 7.0)

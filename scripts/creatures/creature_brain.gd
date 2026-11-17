extends CharacterBody3D
class_name CreatureBrain
@export var definition: CreatureDefinition
@export var wander_radius := 8.0
@export var idle_seconds := 2.0
var home_position: Vector3
var target_position: Vector3
var wait_time := 0.0
func _ready() -> void:
	home_position = global_position
	_choose_wander_target()
func _physics_process(delta: float) -> void:
	wait_time = maxf(0.0, wait_time - delta)
	if wait_time > 0.0:
		velocity.x = move_toward(velocity.x, 0.0, 8.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 8.0 * delta)
	else:
		var direction := target_position - global_position
		direction.y = 0.0
		if direction.length() < 0.8:
			wait_time = idle_seconds
			_choose_wander_target()
		else:
			direction = direction.normalized()
			var speed := definition.movement_speed if definition else 2.5
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
	if not is_on_floor(): velocity.y -= 20.0 * delta
	else: velocity.y = 0.0
	move_and_slide()
func _choose_wander_target() -> void:
	target_position = home_position + Vector3(randf_range(-wander_radius, wander_radius), 0.0, randf_range(-wander_radius, wander_radius))

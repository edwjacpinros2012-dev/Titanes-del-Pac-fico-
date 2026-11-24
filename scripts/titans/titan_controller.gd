extends CharacterBody3D
class_name TitanController

signal health_changed(current: float, maximum: float)
signal attack_performed(special: bool)
signal defeated

@export var stats: TitanStats
@export var acceleration: float = 18.0
@export var gravity: float = 24.0
@export var max_health: float = 200.0
@export var attack_damage: float = 34.0
@export var attack_range: float = 5.5
@export var attack_cooldown: float = 0.8
@export var special_damage: float = 72.0
@export var special_range: float = 9.0
@export var special_energy_cost: float = 35.0

var input_enabled := true
var sync_multiplier: float = 1.0
var research_speed_multiplier: float = 1.0
var damage_speed_multiplier: float = 1.0
var health: float
var energy: float = 100.0
var attack_timer := 0.0
var special_timer := 0.0
var is_guarding := false
var is_defeated := false

func _ready() -> void:
	add_to_group("player_titan")
	health = max_health
	_ensure_action("move_left", KEY_A)
	_ensure_action("move_right", KEY_D)
	_ensure_action("move_forward", KEY_W)
	_ensure_action("move_back", KEY_S)
	_ensure_action("titan_attack", KEY_SPACE)
	_ensure_action("titan_special", KEY_F)
	_ensure_action("titan_guard", KEY_SHIFT)
	_ensure_mouse_action("titan_special", MOUSE_BUTTON_RIGHT)
	health_changed.emit(health, max_health)

func _ensure_action(action_name: String, keycode: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	for existing in InputMap.action_get_events(action_name):
		if existing is InputEventKey and existing.physical_keycode == keycode:
			return
	var key_event := InputEventKey.new()
	key_event.physical_keycode = keycode
	InputMap.action_add_event(action_name, key_event)

func _ensure_mouse_action(action_name: String, button_index: MouseButton) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	for existing in InputMap.action_get_events(action_name):
		if existing is InputEventMouseButton and existing.button_index == button_index:
			return
	var mouse_event := InputEventMouseButton.new()
	mouse_event.button_index = button_index
	InputMap.action_add_event(action_name, mouse_event)

func _unhandled_input(event: InputEvent) -> void:
	if is_defeated:
		return
	if event.is_action_pressed("titan_attack"):
		perform_attack(false)
	elif event.is_action_pressed("titan_special"):
		perform_attack(true)

func _process(delta: float) -> void:
	attack_timer = maxf(0.0, attack_timer - delta)
	special_timer = maxf(0.0, special_timer - delta)
	energy = minf(100.0, energy + 5.0 * delta)
	is_guarding = not is_defeated and Input.is_action_pressed("titan_guard")

func _physics_process(delta: float) -> void:
	if is_defeated:
		velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)
		velocity.z = move_toward(velocity.z, 0.0, acceleration * delta)
	else:
		var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		var direction := Vector3(input_vector.x, 0.0, input_vector.y).normalized()
		var base_speed := stats.move_speed if stats else 7.0
		var speed := base_speed * sync_multiplier * research_speed_multiplier * damage_speed_multiplier
		if is_guarding:
			speed *= 0.45
		velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, direction.z * speed, acceleration * delta)
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0
	move_and_slide()
	if Vector2(velocity.x, velocity.z).length() > 0.2:
		rotation.y = lerp_angle(rotation.y, atan2(velocity.x, velocity.z), delta * 7.0)

func trigger_action(action_name: String) -> void:
	if action_name == "titan_attack":
		perform_attack(false)
	elif action_name == "titan_special":
		perform_attack(true)

func perform_attack(special: bool) -> bool:
	if is_defeated or attack_timer > 0.0:
		return false
	if special and (special_timer > 0.0 or energy < special_energy_cost):
		return false
	var hit_count := 0
	var hit_range := special_range if special else attack_range
	var damage := special_damage if special else attack_damage
	var facing := Vector3(sin(rotation.y), 0.0, cos(rotation.y))
	for target in get_tree().get_nodes_in_group("field_kaiju"):
		if not is_instance_valid(target) or not target is Node3D:
			continue
		var offset: Vector3 = target.global_position - global_position
		offset.y = 0.0
		if offset.length() > hit_range:
			continue
		if not special and offset.length() > 0.01 and facing.dot(offset.normalized()) < -0.15:
			continue
		if target.has_method("receive_damage"):
			target.receive_damage(damage)
			hit_count += 1
	attack_timer = attack_cooldown if not special else 1.2
	if special:
		energy -= special_energy_cost
		special_timer = 5.0
	attack_performed.emit(special)
	_spawn_attack_flash(special, hit_count > 0)
	return true

func apply_damage(amount: float) -> void:
	if is_defeated or amount <= 0.0:
		return
	health = maxf(0.0, health - (amount * 0.35 if is_guarding else amount))
	health_changed.emit(health, max_health)
	if health <= 0.0:
		is_defeated = true
		input_enabled = false
		defeated.emit()

func restore_health(amount: float) -> void:
	if amount <= 0.0:
		return
	is_defeated = false
	input_enabled = true
	health = minf(max_health, health + amount)
	health_changed.emit(health, max_health)

func _spawn_attack_flash(special: bool, connected: bool) -> void:
	var flash := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 1.0 if special else 0.65
	mesh.height = mesh.radius * 2.0
	flash.mesh = mesh
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.15, 0.9, 1.0, 0.65) if special else Color(1.0, 0.48, 0.12, 0.8)
	material.emission_enabled = true
	material.emission = material.albedo_color
	material.emission_energy_multiplier = 1.8
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	flash.material_override = material
	flash.position = Vector3(0, 1.6, 1.6)
	flash.scale = Vector3.ONE * (0.25 if connected else 0.16)
	add_child(flash)
	var tween := create_tween()
	tween.tween_property(flash, "scale", Vector3.ONE * (1.7 if special else 1.1), 0.22)
	tween.tween_callback(flash.queue_free)

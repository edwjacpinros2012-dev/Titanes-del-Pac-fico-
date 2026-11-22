extends CharacterBody3D
class_name FieldKaiju

signal defeated(reward: Dictionary)

@export var max_health := 110.0
@export var movement_speed := 2.8
@export var detection_range := 42.0
@export var attack_range := 3.4
@export var attack_damage := 14.0

var health := 110.0
var target: Node3D
var attack_cooldown := 0.0
var windup := 0.0
var home_position := Vector3.ZERO
var is_dead := false
var body_visual: MeshInstance3D

func _ready() -> void:
	add_to_group("field_kaiju")
	health = max_health
	home_position = global_position
	_build_body()

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	if not is_instance_valid(target):
		var players := get_tree().get_nodes_in_group("player_titan")
		if not players.is_empty():
			target = players[0] as Node3D
	if not is_instance_valid(target):
		velocity.x = move_toward(velocity.x, 0.0, 8.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 8.0 * delta)
		_apply_gravity(delta)
		return
	var offset := target.global_position - global_position
	offset.y = 0.0
	var distance := offset.length()
	if distance > detection_range:
		velocity.x = move_toward(velocity.x, 0.0, 8.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 8.0 * delta)
	elif distance > attack_range:
		windup = 0.0
		var direction := offset.normalized()
		velocity.x = direction.x * movement_speed
		velocity.z = direction.z * movement_speed
		rotation.y = atan2(direction.x, direction.z)
	else:
		velocity.x = move_toward(velocity.x, 0.0, 12.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 12.0 * delta)
		if windup <= 0.0 and attack_cooldown <= 0.0:
			windup = 0.55
		elif windup > 0.0:
			windup -= delta
			if windup <= 0.0:
				_attack_player(distance)
	_apply_gravity(delta)
	move_and_slide()

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 24.0 * delta
	else:
		velocity.y = 0.0

func _attack_player(distance: float) -> void:
	attack_cooldown = 1.8
	if distance <= attack_range + 0.8 and is_instance_valid(target) and target.has_method("apply_damage"):
		target.apply_damage(attack_damage)
		_flash(Color(1.0, 0.12, 0.08))

func receive_damage(amount: float) -> void:
	if is_dead or amount <= 0.0:
		return
	health = maxf(0.0, health - amount)
	_flash(Color(1.0, 0.68, 0.15))
	if health <= 0.0:
		is_dead = true
		velocity = Vector3.ZERO
		defeated.emit({"metal": 6, "energy": 3})
		queue_free()

func _build_body() -> void:
	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.9
	shape.height = 3.4
	collision.shape = shape
	collision.position.y = 1.7
	add_child(collision)
	body_visual = MeshInstance3D.new()
	var body_mesh := SphereMesh.new()
	body_mesh.radius = 1.25
	body_mesh.height = 2.8
	body_visual.mesh = body_mesh
	body_visual.position.y = 1.7
	body_visual.scale = Vector3(1.0, 0.9, 1.35)
	body_visual.material_override = _material(Color(0.18, 0.28, 0.32))
	add_child(body_visual)
	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.62
	head_mesh.height = 1.15
	head.mesh = head_mesh
	head.position = Vector3(0, 2.55, 1.05)
	head.material_override = _material(Color(0.27, 0.38, 0.4))
	add_child(head)
	var eyes := MeshInstance3D.new()
	var eye_mesh := BoxMesh.new()
	eye_mesh.size = Vector3(0.85, 0.12, 0.12)
	eyes.mesh = eye_mesh
	eyes.position = Vector3(0, 2.65, 1.56)
	eyes.material_override = _material(Color(1.0, 0.18, 0.08), true)
	add_child(eyes)

func _material(color: Color, glow := false) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	if glow:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = 2.0
	return material

func _flash(color: Color) -> void:
	if not is_instance_valid(body_visual):
		return
	body_visual.material_override = _material(color, true)
	var tween := create_tween()
	tween.tween_interval(0.12)
	tween.tween_callback(func() -> void:
		if is_instance_valid(body_visual) and not is_dead:
			body_visual.material_override = _material(Color(0.18, 0.28, 0.32))
	)

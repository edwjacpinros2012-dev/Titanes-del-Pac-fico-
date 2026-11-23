extends Node3D

@onready var model_root: Node3D = $ModelRoot
var left_arm: Node3D
var right_arm: Node3D
var left_leg: Node3D
var right_leg: Node3D
var core_light: MeshInstance3D
var idle_time := 0.0

func _ready() -> void:
	_build_jaeger()

func _process(_delta: float) -> void:
	idle_time += _delta
	if left_arm:
		left_arm.rotation.x = sin(idle_time * 0.75) * 0.035
		right_arm.rotation.x = -sin(idle_time * 0.75) * 0.035
		left_leg.rotation.x = -sin(idle_time * 0.75) * 0.012
		right_leg.rotation.x = sin(idle_time * 0.75) * 0.012
	if core_light:
		core_light.scale = Vector3.ONE * (1.0 + sin(idle_time * 2.0) * 0.035)

func _build_jaeger() -> void:
	var armor := _material(Color(0.10, 0.27, 0.36), 0.55, 0.3)
	var dark := _material(Color(0.055, 0.085, 0.105), 0.65, 0.4)
	var trim := _material(Color(0.78, 0.32, 0.12), 0.35, 0.32)
	var glow := _material(Color(0.1, 0.8, 1.0), 0.25, 0.2, true)
	_box(model_root, Vector3(0, 3.15, 0), Vector3(1.55, 1.8, 0.82), armor)
	_box(model_root, Vector3(0, 3.15, 0.48), Vector3(1.08, 0.34, 0.12), trim)
	_box(model_root, Vector3(0, 3.25, -0.46), Vector3(0.62, 0.72, 0.12), glow)
	_box(model_root, Vector3(0, 4.35, 0.03), Vector3(0.64, 0.68, 0.62), dark)
	_box(model_root, Vector3(0, 4.35, 0.37), Vector3(0.48, 0.12, 0.12), glow)
	_box(model_root, Vector3(-0.88, 3.82, 0), Vector3(0.72, 0.42, 0.9), trim)
	_box(model_root, Vector3(0.88, 3.82, 0), Vector3(0.72, 0.42, 0.9), trim)
	left_arm = _limb_pivot(model_root, Vector3(-1.12, 3.52, 0), Vector3(0.54, 1.34, 0.62), armor, dark)
	right_arm = _limb_pivot(model_root, Vector3(1.12, 3.52, 0), Vector3(0.54, 1.34, 0.62), armor, dark)
	left_leg = _limb_pivot(model_root, Vector3(-0.48, 2.34, 0), Vector3(0.62, 1.38, 0.72), armor, dark)
	right_leg = _limb_pivot(model_root, Vector3(0.48, 2.34, 0), Vector3(0.62, 1.38, 0.72), armor, dark)
	_box(model_root, Vector3(-0.48, 1.62, 0.12), Vector3(0.78, 0.35, 1.05), dark)
	_box(model_root, Vector3(0.48, 1.62, 0.12), Vector3(0.78, 0.35, 1.05), dark)
	_box(model_root, Vector3(-1.12, 2.68, 0), Vector3(0.7, 0.55, 0.72), dark)
	_box(model_root, Vector3(1.12, 2.68, 0), Vector3(0.7, 0.55, 0.72), dark)
	var core := MeshInstance3D.new()
	var core_mesh := SphereMesh.new()
	core_mesh.radius = 0.26
	core_mesh.height = 0.52
	core.mesh = core_mesh
	core.position = Vector3(0, 3.25, 0.55)
	core.material_override = glow
	model_root.add_child(core)
	core_light = core
	for side in [-1.0, 1.0]:
		_box(model_root, Vector3(side * 1.48, 3.7, 0.02), Vector3(0.13, 0.9, 0.32), glow)
		_box(model_root, Vector3(side * 0.48, 2.4, 0.4), Vector3(0.18, 0.22, 0.12), trim)

func _limb_pivot(parent: Node3D, pivot_position: Vector3, size: Vector3, armor: Material, dark: Material) -> Node3D:
	var pivot := Node3D.new()
	pivot.position = pivot_position
	parent.add_child(pivot)
	_box(pivot, Vector3(0, -size.y * 0.5, 0), size, armor)
	_box(pivot, Vector3(0, -size.y * 0.5, 0.34), Vector3(size.x * 0.55, size.y * 0.45, 0.12), dark)
	return pivot

func _box(parent: Node3D, position: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	instance.position = position
	instance.material_override = material
	parent.add_child(instance)
	return instance

func _material(color: Color, metallic: float, roughness: float, emissive := false) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = roughness
	if emissive:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = 1.7
	return material

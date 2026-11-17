extends Node3D
class_name ResourceSpawner

@export var resource_scene: PackedScene
@export var resource_id: String = "metal"
@export_range(1, 100, 1) var spawn_count: int = 12
@export var spawn_radius: float = 24.0
@export var spawn_height: float = 0.5
@export var random_seed: int = 0

func _ready() -> void:
	if random_seed != 0:
		seed(random_seed)
	if resource_scene == null:
		push_warning("ResourceSpawner necesita una escena de recurso.")
		return
	for index in range(spawn_count):
		var instance := resource_scene.instantiate() as Node3D
		if instance == null:
			continue
		add_child(instance)
		instance.position = Vector3(randf_range(-spawn_radius, spawn_radius), spawn_height, randf_range(-spawn_radius, spawn_radius))
		if instance is ResourceNode:
			instance.resource_id = resource_id

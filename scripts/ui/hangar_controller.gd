extends Node3D

var display_jaeger: Node3D
var title_label: Label
var detail_label: Label
var select_button: Button
var deploy_button: Button
var status_label: Label
var selected := false
var spin := 0.0

func _ready() -> void:
	_build_hangar()
	_build_interface()
	_refresh_interface()

func _process(delta: float) -> void:
	spin += delta
	if display_jaeger:
		display_jaeger.rotation.y = sin(spin * 0.28) * 0.18

func _build_hangar() -> void:
	var environment_node := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.015, 0.035, 0.055)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.42, 0.58, 0.72)
	environment.ambient_light_energy = 0.8
	environment_node.environment = environment
	add_child(environment_node)
	var key_light := _light(Color(0.48, 0.77, 1.0), 2.0, 16.0)
	key_light.position = Vector3(-5, 9, 6)
	key_light.rotation_degrees = Vector3(-35, -35, 0)
	add_child(key_light)
	var rim_light := _light(Color(0.1, 0.75, 1.0), 2.2, 12.0)
	rim_light.position = Vector3(5, 6, -5)
	rim_light.rotation_degrees = Vector3(-25, 145, 0)
	add_child(rim_light)
	var floor := MeshInstance3D.new()
	var floor_mesh := PlaneMesh.new()
	floor_mesh.size = Vector2(30, 30)
	floor.mesh = floor_mesh
	floor.position.y = -0.08
	floor.material_override = _material(Color(0.035, 0.075, 0.095), 0.55, 0.35)
	add_child(floor)
	var platform := MeshInstance3D.new()
	var platform_mesh := CylinderMesh.new()
	platform_mesh.top_radius = 3.2
	platform_mesh.bottom_radius = 3.35
	platform_mesh.height = 0.38
	platform.mesh = platform_mesh
	platform.position = Vector3(0, 0.2, 0)
	platform.material_override = _material(Color(0.11, 0.17, 0.2), 0.7, 0.28)
	add_child(platform)
	var ring := MeshInstance3D.new()
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = 2.85
	ring_mesh.outer_radius = 3.0
	ring.mesh = ring_mesh
	ring.position.y = 0.43
	ring.material_override = _material(Color(0.04, 0.72, 0.95), 0.3, 0.22, true)
	add_child(ring)
	for index in range(8):
		var pylon := MeshInstance3D.new()
		var pylon_mesh := BoxMesh.new()
		pylon_mesh.size = Vector3(0.25, 5.0, 0.25)
		pylon.mesh = pylon_mesh
		var angle := TAU * float(index) / 8.0
		pylon.position = Vector3(cos(angle) * 7.0, 2.5, sin(angle) * 7.0)
		pylon.material_override = _material(Color(0.08, 0.16, 0.2), 0.6, 0.32)
		add_child(pylon)
		var strip := MeshInstance3D.new()
		var strip_mesh := BoxMesh.new()
		strip_mesh.size = Vector3(0.06, 3.6, 0.08)
		strip.mesh = strip_mesh
		strip.position = pylon.position + Vector3(0.16, 0, 0)
		strip.material_override = _material(Color(0.1, 0.65, 0.95), 0.2, 0.25, true)
		add_child(strip)
	display_jaeger = Node3D.new()
	display_jaeger.name = "TitánAlfaExhibición"
	display_jaeger.set_script(load("res://scripts/titans/jaeger_modular_visual.gd"))
	display_jaeger.position = Vector3(0, 0.42, 0)
	add_child(display_jaeger)
	var camera := Camera3D.new()
	camera.position = Vector3(8.7, 6.8, 11.5)
	camera.current = true
	camera.fov = 43
	add_child(camera)
	camera.look_at(Vector3(0, 2.3, 0), Vector3.UP)

func _build_interface() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var left := PanelContainer.new()
	left.position = Vector2(28, 28)
	left.custom_minimum_size = Vector2(370, 245)
	layer.add_child(left)
	var column := VBoxContainer.new()
	left.add_child(column)
	var eyebrow := Label.new()
	eyebrow.text = "SHATTERDOME  /  HANGAR 01"
	eyebrow.add_theme_color_override("font_color", Color(0.2, 0.82, 1.0))
	column.add_child(eyebrow)
	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 30)
	column.add_child(title_label)
	detail_label = Label.new()
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(detail_label)
	select_button = Button.new()
	select_button.text = "Seleccionar Jaeger"
	select_button.pressed.connect(_on_select_pressed)
	column.add_child(select_button)
	deploy_button = Button.new()
	deploy_button.text = "Desplegar en Costa de la Aurora"
	deploy_button.pressed.connect(_on_deploy_pressed)
	column.add_child(deploy_button)
	status_label = Label.new()
	status_label.text = "MODELO PROVISIONAL: construcción modular original con articulaciones y movimiento de reposo; no es un asset final riggeado."
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_color_override("font_color", Color(1.0, 0.72, 0.35))
	column.add_child(status_label)
	var footer := Label.new()
	footer.anchor_left = 0.03
	footer.anchor_top = 0.94
	footer.anchor_right = 0.97
	footer.anchor_bottom = 0.99
	footer.text = "TITÁN ALFA  /  MARK I  /  A: golpear · F: pulso · SHIFT: defender · WASD: moverse"
	layer.add_child(footer)

func _refresh_interface() -> void:
	selected = HangarState.selected_jaeger_id == "titan_alpha"
	title_label.text = "TITÁN ALFA"
	detail_label.text = "MARK I  ·  Explorador equilibrado\nIntegridad: %d  ·  Golpe: %d  ·  Pulso: %d\nNivel de evolución: %d" % [200 + (GlobalState.titan_level - 1) * 15, 34 + (GlobalState.titan_level - 1) * 3, 72 + (GlobalState.titan_level - 1) * 5, GlobalState.titan_level]
	select_button.text = "Jaeger seleccionado ✓" if selected else "Seleccionar Jaeger"
	deploy_button.disabled = not selected

func _on_select_pressed() -> void:
	selected = HangarState.select_jaeger("titan_alpha")
	_refresh_interface()
	status_label.text = "Titán Alfa asignado a la misión. Modelo modular provisional; arte final pendiente."

func _on_deploy_pressed() -> void:
	if not selected:
		status_label.text = "Selecciona un Jaeger disponible antes del despliegue."
		return
	if not HangarState.deploy_selected_jaeger():
		status_label.text = "No se pudo cargar la escena de combate. Revisa la ruta de misión."

func _light(color: Color, energy: float, range_value: float) -> OmniLight3D:
	var light := OmniLight3D.new()
	light.light_color = color
	light.light_energy = energy
	light.omni_range = range_value
	return light

func _material(color: Color, metallic: float, roughness: float, emissive := false) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = roughness
	if emissive:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = 1.5
	return material

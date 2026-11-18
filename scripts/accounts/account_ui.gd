extends CanvasLayer
var status_label: Label
var name_input: LineEdit
var settings_box: VBoxContainer
var visible_panel := true

func _ready() -> void:
	layer = 80
	_build_ui()

func _build_ui() -> void:
	var panel := PanelContainer.new()
	panel.name = "AccountSettingsPanel"
	panel.anchor_left = 0.0
	panel.anchor_top = 0.0
	panel.anchor_right = 0.0
	panel.anchor_bottom = 0.0
	panel.position = Vector2(14, 14)
	panel.custom_minimum_size = Vector2(300, 0)
	add_child(panel)
	var column := VBoxContainer.new()
	panel.add_child(column)
	var title := Label.new()
	title.text = "PILOTO / AJUSTES"
	title.add_theme_font_size_override("font_size", 18)
	column.add_child(title)
	status_label = Label.new()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.text = _profile_summary()
	column.add_child(status_label)
	name_input = LineEdit.new()
	name_input.placeholder_text = "Nombre de piloto (1–24)"
	name_input.text = str(AccountManager.profile.get("display_name", "Piloto"))
	column.add_child(name_input)
	var save_name := Button.new()
	save_name.text = "Guardar nombre"
	save_name.pressed.connect(func(): AccountManager.set_display_name(name_input.text))
	column.add_child(save_name)
	var google := Button.new()
	google.text = "Registrarse / iniciar con Google"
	google.pressed.connect(AccountManager.begin_google_sign_in)
	column.add_child(google)
	var offline := Button.new()
	offline.text = "Continuar sin cuenta"
	offline.pressed.connect(AccountManager.begin_offline_session)
	column.add_child(offline)
	var settings_title := Label.new()
	settings_title.text = "AJUSTES LOCALES"
	column.add_child(settings_title)
	settings_box = VBoxContainer.new()
	column.add_child(settings_box)
	_add_slider("Volumen general", "master_volume")
	_add_slider("Música", "music_volume")
	_add_slider("Efectos", "sfx_volume")
	_add_slider("Sensibilidad cámara", "camera_sensitivity", 0.25, 3.0)
	_add_check("Subtítulos", "subtitles")
	_add_check("Controles táctiles", "touch_controls")
	_add_check("Movimiento reducido", "reduced_motion")
	var reset := Button.new()
	reset.text = "Restablecer ajustes"
	reset.pressed.connect(SettingsManager.reset_settings)
	column.add_child(reset)
	AccountManager.authentication_status_changed.connect(_on_status)
	AccountManager.profile_changed.connect(_on_profile_changed)
	SettingsManager.settings_changed.connect(_refresh_settings)
	_refresh_settings(SettingsManager.settings)

func _add_slider(label_text: String, setting_key: String, min_value := 0.0, max_value := 1.0) -> void:
	var row := HBoxContainer.new()
	settings_box.add_child(row)
	var label := Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	var slider := HSlider.new()
	slider.min_value = min_value
	slider.max_value = max_value
	slider.step = 0.05
	slider.custom_minimum_size = Vector2(110, 0)
	slider.value = float(SettingsManager.get_setting(setting_key, 1.0))
	slider.value_changed.connect(func(v: float): SettingsManager.set_setting(setting_key, v))
	row.add_child(slider)

func _add_check(label_text: String, setting_key: String) -> void:
	var check := CheckBox.new()
	check.text = label_text
	check.button_pressed = bool(SettingsManager.get_setting(setting_key, true))
	check.toggled.connect(func(v: bool): SettingsManager.set_setting(setting_key, v))
	settings_box.add_child(check)

func _refresh_settings(settings: Dictionary) -> void:
	for child in settings_box.get_children():
		if child is HSlider:
			pass
		elif child is HBoxContainer:
			for nested in child.get_children():
				if nested is HSlider:
					var key := ""
					for setting_key in ["master_volume","music_volume","sfx_volume","camera_sensitivity"]:
						if setting_key in ["master_volume","music_volume","sfx_volume","camera_sensitivity"]:
							key = setting_key
					# Values are applied by direct slider callbacks; no recursive signal update here.
		elif child is CheckBox:
			pass

func _profile_summary() -> String:
	var p := AccountManager.profile
	return "Perfil: %s\nID local: %s\nGoogle: %s | Nube: %s" % [
		str(p.get("display_name", "Piloto")),
		str(p.get("player_id", "—")),
		"vinculado" if bool(p.get("google_linked", false)) else "sin vincular",
		"apagada" if not bool(p.get("cloud_enabled", false)) else "activa"
	]

func _on_status(message: String) -> void:
	status_label.text = _profile_summary() + "\n" + message

func _on_profile_changed(_profile: Dictionary) -> void:
	status_label.text = _profile_summary()

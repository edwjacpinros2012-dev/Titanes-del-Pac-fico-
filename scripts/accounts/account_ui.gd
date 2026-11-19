extends CanvasLayer

var status_label: Label
var name_input: LineEdit
var settings_box: VBoxContainer
var panel_container: PanelContainer
var reopen_button: Button

func _ready() -> void:
	layer = 80
	_build_ui()

func _build_ui() -> void:
	panel_container = PanelContainer.new()
	panel_container.name = "AccountSettingsPanel"
	panel_container.position = Vector2(14, 14)
	panel_container.custom_minimum_size = Vector2(330, 0)
	panel_container.size = Vector2(330, 0)
	add_child(panel_container)
	var panel_column := VBoxContainer.new()
	panel_container.add_child(panel_column)
	var header := HBoxContainer.new()
	panel_column.add_child(header)
	var title := Label.new()
	title.text = "PILOTO / AJUSTES"
	title.add_theme_font_size_override("font_size", 18)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	var close_button := Button.new()
	close_button.text = "×"
	close_button.tooltip_text = "Ocultar panel para jugar"
	close_button.pressed.connect(_hide_panel)
	header.add_child(close_button)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 430)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel_column.add_child(scroll)
	var column := VBoxContainer.new()
	column.custom_minimum_size = Vector2(300, 0)
	scroll.add_child(column)
	status_label = Label.new()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.text = _profile_summary()
	column.add_child(status_label)
	name_input = LineEdit.new()
	name_input.placeholder_text = "Nombre de piloto (3–20)"
	name_input.max_length = AccountManager.MAX_DISPLAY_NAME_LENGTH
	name_input.text = str(AccountManager.profile.get("display_name", "Piloto"))
	column.add_child(name_input)
	var save_name := Button.new()
	save_name.text = "CREAR / ENTRAR CON ESTE PILOTO"
	save_name.pressed.connect(func(): AccountManager.create_local_profile(name_input.text))
	column.add_child(save_name)
	var google := Button.new()
	google.text = "GOOGLE (PRÓXIMAMENTE)"
	google.pressed.connect(AccountManager.begin_google_sign_in)
	column.add_child(google)
	var privacy_note := Label.new()
	privacy_note.text = "El perfil local no necesita correo ni contraseña. Google y la nube no están conectados todavía."
	privacy_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(privacy_note)
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
	reopen_button = Button.new()
	reopen_button.text = "Cuenta / ajustes"
	reopen_button.position = Vector2(14, 14)
	reopen_button.visible = false
	reopen_button.pressed.connect(_show_panel)
	add_child(reopen_button)
	AccountManager.authentication_status_changed.connect(_on_status)
	AccountManager.profile_changed.connect(_on_profile_changed)
	SettingsManager.settings_changed.connect(_refresh_settings)
	_refresh_settings(SettingsManager.settings)

func _hide_panel() -> void:
	panel_container.visible = false
	reopen_button.visible = true

func _show_panel() -> void:
	panel_container.visible = true
	reopen_button.visible = false

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
	slider.set_meta("setting_key", setting_key)
	slider.value = float(SettingsManager.get_setting(setting_key, 1.0))
	slider.value_changed.connect(func(v: float): SettingsManager.set_setting(setting_key, v))
	row.add_child(slider)

func _add_check(label_text: String, setting_key: String) -> void:
	var check := CheckBox.new()
	check.text = label_text
	check.set_meta("setting_key", setting_key)
	check.button_pressed = bool(SettingsManager.get_setting(setting_key, true))
	check.toggled.connect(func(v: bool): SettingsManager.set_setting(setting_key, v))
	settings_box.add_child(check)

func _refresh_settings(settings: Dictionary) -> void:
	for child in settings_box.get_children():
		if child is HBoxContainer:
			for nested in child.get_children():
				if nested is HSlider:
					var key := str(nested.get_meta("setting_key", ""))
					if settings.has(key):
						nested.set_value_no_signal(float(settings[key]))
		elif child is CheckBox:
			var key := str(child.get_meta("setting_key", ""))
			if settings.has(key):
				child.set_pressed_no_signal(bool(settings[key]))

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
	name_input.text = str(AccountManager.profile.get("display_name", "Piloto"))
	status_label.text = _profile_summary()

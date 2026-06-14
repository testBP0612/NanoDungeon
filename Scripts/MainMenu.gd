extends Control

const UI_THEME_SCRIPT := preload("res://Scripts/UITheme.gd")


func _ready() -> void:
	_build_ui()
	UI_THEME_SCRIPT.apply_to(self)


func _build_ui() -> void:
	var viewport_size := get_viewport_rect().size
	var background := ColorRect.new()
	background.color = Color(0.03, 0.04, 0.07)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	_add_menu_background()
	_add_logo_emblem()

	var title := Label.new()
	title.text = "Nano Dungeon"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 44)
	title.position = Vector2(0, 186)
	title.size = Vector2(viewport_size.x, 70)
	add_child(title)

	var subtitle := Label.new()
	subtitle.text = "MVP Demo"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.position = Vector2(0, 252)
	subtitle.size = Vector2(viewport_size.x, 32)
	add_child(subtitle)

	var start_button := Button.new()
	start_button.text = "開始"
	start_button.position = Vector2((viewport_size.x - 200.0) * 0.5, 342)
	start_button.size = Vector2(200, 48)
	start_button.pressed.connect(_on_start_pressed)
	add_child(start_button)

	var quit_button := Button.new()
	quit_button.text = "離開"
	quit_button.position = Vector2((viewport_size.x - 200.0) * 0.5, 404)
	quit_button.size = Vector2(200, 48)
	quit_button.pressed.connect(_on_quit_pressed)
	add_child(quit_button)


func _add_menu_background() -> void:
	var path := "res://assets/bg/menu_bg.png"
	if not ResourceLoader.exists(path):
		return
	var texture: Texture2D = load(path)
	if texture == null:
		return
	var background := TextureRect.new()
	background.name = "MenuBackgroundArt"
	background.texture = texture
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.modulate = Color(1.0, 1.0, 1.0, 0.72)
	add_child(background)


func _add_logo_emblem() -> void:
	var path := "res://assets/ui/logo.png"
	if not ResourceLoader.exists(path):
		return
	var texture: Texture2D = load(path)
	if texture == null:
		return
	var logo := TextureRect.new()
	logo.name = "LogoEmblem"
	logo.texture = texture
	logo.position = Vector2((get_viewport_rect().size.x - 180.0) * 0.5, 38)
	logo.size = Vector2(180, 180)
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(logo)


func _on_start_pressed() -> void:
	RunState.reset_new_run()
	SceneTransition.change_scene("res://Scenes/Battle.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()

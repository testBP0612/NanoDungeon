extends Control


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color(0.03, 0.04, 0.07)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var title := Label.new()
	title.text = "Nano Dungeon"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 44)
	title.position = Vector2(0, 150)
	title.size = Vector2(1024, 70)
	add_child(title)

	var subtitle := Label.new()
	subtitle.text = "MVP Demo"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.position = Vector2(0, 220)
	subtitle.size = Vector2(1024, 32)
	add_child(subtitle)

	var start_button := Button.new()
	start_button.text = "開始"
	start_button.position = Vector2(412, 310)
	start_button.size = Vector2(200, 48)
	start_button.pressed.connect(_on_start_pressed)
	add_child(start_button)

	var quit_button := Button.new()
	quit_button.text = "離開"
	quit_button.position = Vector2(412, 372)
	quit_button.size = Vector2(200, 48)
	quit_button.pressed.connect(_on_quit_pressed)
	add_child(quit_button)


func _on_start_pressed() -> void:
	RunState.reset_new_run()
	SceneTransition.change_scene("res://Scenes/Battle.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()

extends Control


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color(0.02, 0.05, 0.045)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var title := Label.new()
	title.text = "VICTORY"
	title.position = Vector2(0, 130)
	title.size = Vector2(1024, 64)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 44)
	add_child(title)

	var summary := Label.new()
	summary.text = "剩餘 HP：%s / %s\n擊殺數：%s\n用時：%s 秒\nBuild：Phase 4 尚未啟用" % [
		RunState.player_hp,
		RunState.player_max_hp,
		RunState.kills,
		int(RunState.get_elapsed_seconds()),
	]
	summary.position = Vector2(312, 230)
	summary.size = Vector2(400, 140)
	summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	summary.add_theme_font_size_override("font_size", 22)
	add_child(summary)

	_add_button("重來", Vector2(382, 410), _on_restart_pressed)
	_add_button("主選單", Vector2(522, 410), _on_menu_pressed)


func _add_button(text: String, position: Vector2, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.position = position
	button.size = Vector2(120, 42)
	button.pressed.connect(callback)
	add_child(button)


func _on_restart_pressed() -> void:
	RunState.reset_new_run()
	get_tree().change_scene_to_file("res://Scenes/Battle.tscn")


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

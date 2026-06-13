extends CanvasLayer

var feel_config: Dictionary = {}
var _rect: ColorRect
var _busy := false


func _ready() -> void:
	layer = 100
	_rect = ColorRect.new()
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_rect)
	_refresh_config()
	_rect.modulate.a = 1.0
	fade_in()


func change_scene(path: String) -> void:
	if _busy:
		return
	_busy = true
	_refresh_config()
	if not bool(_config().get("enabled", true)):
		get_tree().change_scene_to_file(path)
		_busy = false
		return
	await fade_out()
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	await fade_in()
	_busy = false


func reload_current_scene() -> void:
	if _busy:
		return
	var current_path := get_tree().current_scene.scene_file_path
	if current_path.is_empty():
		get_tree().reload_current_scene()
	else:
		change_scene(current_path)


func fade_in() -> void:
	_refresh_config()
	var config := _config()
	_rect.color = _transition_color()
	var tween := create_tween()
	tween.tween_property(_rect, "modulate:a", 0.0, float(config.get("fade_in_seconds", 0.18)))
	await tween.finished


func fade_out() -> void:
	_refresh_config()
	var config := _config()
	_rect.color = _transition_color()
	var tween := create_tween()
	tween.tween_property(_rect, "modulate:a", 1.0, float(config.get("fade_out_seconds", 0.16)))
	await tween.finished


func _refresh_config() -> void:
	if DataLoader != null:
		if not DataLoader.loaded:
			DataLoader.load_all()
		feel_config = DataLoader.get_feel_config()


func _config() -> Dictionary:
	return feel_config.get("transitions", {})


func _transition_color() -> Color:
	var color_text := String(_config().get("color", "#02040A"))
	return Color(color_text)

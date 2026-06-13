extends StaticBody2D

var peg_id := "normal_peg"
var peg_def: Dictionary = {}
var radius := 18.0
var _base_color := Color(0.2, 0.85, 1.0)
var _flash := 0.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	add_to_group("pegs")


func configure(new_peg_id: String, new_peg_def: Dictionary) -> void:
	peg_id = new_peg_id
	peg_def = new_peg_def.duplicate(true)
	_base_color = _color_for_peg(peg_id)
	if collision_shape != null and collision_shape.shape is CircleShape2D:
		(collision_shape.shape as CircleShape2D).radius = radius
	queue_redraw()


func get_peg_id() -> String:
	return peg_id


func play_hit_feedback() -> void:
	var tween := create_tween()
	tween.tween_method(_set_flash, 1.0, 0.0, 0.16)


func get_peg_color() -> Color:
	return _base_color


func _set_flash(value: float) -> void:
	_flash = value
	queue_redraw()


func _color_for_peg(id: String) -> Color:
	match id:
		"burst_peg":
			return Color(1.0, 0.32, 0.12)
		"heal_peg":
			return Color(0.22, 1.0, 0.08)
		"double_peg":
			return Color(1.0, 0.78, 0.24)
		_:
			return Color(0.2, 0.85, 1.0)


func _draw() -> void:
	var outer := _base_color.lerp(Color.WHITE, _flash)
	draw_circle(Vector2.ZERO, radius, outer)
	draw_circle(Vector2.ZERO, radius * 0.55, Color(0.95, 1.0, 1.0))

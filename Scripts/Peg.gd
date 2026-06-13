extends StaticBody2D

var peg_id := "normal_peg"
var peg_def: Dictionary = {}
var radius := 18.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	add_to_group("pegs")


func configure(new_peg_id: String, new_peg_def: Dictionary) -> void:
	peg_id = new_peg_id
	peg_def = new_peg_def.duplicate(true)
	if collision_shape != null and collision_shape.shape is CircleShape2D:
		(collision_shape.shape as CircleShape2D).radius = radius
	queue_redraw()


func get_peg_id() -> String:
	return peg_id


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, Color(0.2, 0.85, 1.0))
	draw_circle(Vector2.ZERO, radius * 0.55, Color(0.95, 1.0, 1.0))

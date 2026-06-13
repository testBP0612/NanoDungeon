extends RigidBody2D

signal peg_hit(peg_id: String)
signal recovered(ball: RigidBody2D, reason: String)

var ball_id := "normal_ball"
var ball_def: Dictionary = {}
var radius := 10.0
var _recovered := false
var _launch_speed := 0.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 8
	continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
	body_entered.connect(_on_body_entered)


func configure(new_ball_id: String, new_ball_def: Dictionary, player_config: Dictionary) -> void:
	ball_id = new_ball_id
	ball_def = new_ball_def.duplicate(true)
	radius = float(player_config["ball_radius"])
	gravity_scale = float(player_config["ball_gravity_scale"])
	_launch_speed = float(player_config["launch_speed"])

	var material := PhysicsMaterial.new()
	material.bounce = float(player_config["ball_bounce"])
	material.friction = float(player_config["ball_friction"])
	physics_material_override = material

	if collision_shape != null and collision_shape.shape is CircleShape2D:
		(collision_shape.shape as CircleShape2D).radius = radius

	var timer := Timer.new()
	timer.one_shot = true
	timer.timeout.connect(func(): recover("timeout"))
	add_child(timer)
	timer.start(float(player_config["ball_timeout_seconds"]))
	queue_redraw()


func launch(direction: Vector2) -> void:
	apply_central_impulse(direction.normalized() * _launch_speed)


func recover(reason: String) -> void:
	if _recovered:
		return
	_recovered = true
	recovered.emit(self, reason)
	queue_free()


func _on_body_entered(body: Node) -> void:
	if _recovered:
		return
	if body.has_method("get_peg_id"):
		peg_hit.emit(body.get_peg_id())


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, Color(1.0, 0.86, 0.25))
	draw_circle(Vector2.ZERO, radius * 0.45, Color(1.0, 1.0, 0.9))

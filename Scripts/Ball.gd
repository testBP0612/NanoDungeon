extends RigidBody2D

signal peg_hit(peg_id: String, hit_position: Vector2, hit_color: Color)
signal wall_hit(hit_position: Vector2)
signal recovered(ball: RigidBody2D, reason: String)

var ball_id := "normal_ball"
var ball_def: Dictionary = {}
var radius := 10.0
var _recovered := false
var _launch_speed := 0.0
var _ball_color := Color(1.0, 0.86, 0.25)

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 8
	continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
	body_entered.connect(_on_body_entered)


func configure(new_ball_id: String, new_ball_def: Dictionary, player_config: Dictionary) -> void:
	ball_id = new_ball_id
	ball_def = new_ball_def.duplicate(true)
	_ball_color = _color_for_ball(ball_id)
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
	_add_trail()
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
		if body.has_method("play_hit_feedback"):
			body.play_hit_feedback()
		var hit_color := Color(0.2, 0.85, 1.0)
		if body.has_method("get_peg_color"):
			hit_color = body.get_peg_color()
		peg_hit.emit(body.get_peg_id(), body.global_position, hit_color)
	else:
		wall_hit.emit(global_position)


func _add_trail() -> void:
	var particles := CPUParticles2D.new()
	particles.name = "Trail"
	particles.amount = 14
	particles.lifetime = 0.22
	particles.local_coords = false
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = radius * 0.35
	particles.direction = Vector2.ZERO
	particles.spread = 180.0
	particles.gravity = Vector2.ZERO
	particles.initial_velocity_min = 8.0
	particles.initial_velocity_max = 18.0
	particles.scale_amount_min = 1.0
	particles.scale_amount_max = 2.0
	particles.color = _ball_color
	add_child(particles)


func _color_for_ball(id: String) -> Color:
	match id:
		"blast_ball":
			return Color(1.0, 0.42, 0.12)
		"shield_ball":
			return Color(0.38, 0.68, 1.0)
		_:
			return Color(1.0, 0.86, 0.25)


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, _ball_color)
	draw_circle(Vector2.ZERO, radius * 0.45, Color(1.0, 1.0, 0.9))

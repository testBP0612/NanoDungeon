extends RigidBody2D

signal peg_hit(peg_id: String, hit_position: Vector2, hit_color: Color)
signal wall_hit(hit_position: Vector2)
signal recovered(ball: RigidBody2D, reason: String)

var ball_id := "normal_ball"
var ball_def: Dictionary = {}
var radius := 10.0
var _recovered := false
var _launch_speed := 0.0
var _bounce_multiplier := 1.0
var _max_ball_speed := 0.0
var _ball_color := Color(1.0, 0.86, 0.25)
var _peg_rehit_cooldown := 0.0
var _peg_hit_times: Dictionary = {}
var _feel_config: Dictionary = {}

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 8
	continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
	body_entered.connect(_on_body_entered)


func configure(new_ball_id: String, new_ball_def: Dictionary, player_config: Dictionary, feel_config: Dictionary, field_config: Dictionary = {}) -> void:
	ball_id = new_ball_id
	ball_def = new_ball_def.duplicate(true)
	_feel_config = feel_config.duplicate(true)
	_peg_rehit_cooldown = float(_feel_config["peg_rehit_cooldown_seconds"])
	var bottom_row: Dictionary = field_config.get("bottom_row", {})
	_bounce_multiplier = float(bottom_row.get("bounce_multiplier", 1.0))
	_max_ball_speed = float(bottom_row.get("max_ball_speed", 0.0))
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


func launch(direction: Vector2, launch_speed := -1.0) -> void:
	var speed := _launch_speed if launch_speed <= 0.0 else launch_speed
	apply_central_impulse(direction.normalized() * speed)


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
		if not _can_hit_peg(body):
			return
		if String(body.get_peg_id()) == "bounce_peg":
			_apply_bumper_boost()
		if body.has_method("play_hit_feedback"):
			body.play_hit_feedback()
		var hit_color := Color(0.2, 0.85, 1.0)
		if body.has_method("get_peg_color"):
			hit_color = body.get_peg_color()
		peg_hit.emit(body.get_peg_id(), body.global_position, hit_color)
	else:
		wall_hit.emit(global_position)


func _apply_bumper_boost() -> void:
	if _bounce_multiplier <= 0.0:
		return
	var current_speed := linear_velocity.length()
	if current_speed <= 0.01:
		return
	var boosted_speed := current_speed * _bounce_multiplier
	if _max_ball_speed > 0.0:
		boosted_speed = min(boosted_speed, _max_ball_speed)
	linear_velocity = linear_velocity.normalized() * boosted_speed


func _add_trail() -> void:
	var trail: Dictionary = _feel_config.get("trail", {})
	var particles := CPUParticles2D.new()
	particles.name = "Trail"
	particles.amount = int(trail["amount"])
	particles.lifetime = float(trail["lifetime"])
	particles.local_coords = false
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = radius * float(trail["radius_multiplier"])
	particles.direction = Vector2(float(trail["direction_x"]), float(trail["direction_y"]))
	particles.spread = float(trail["spread_degrees"])
	particles.gravity = Vector2(float(trail["gravity_x"]), float(trail["gravity_y"]))
	particles.initial_velocity_min = float(trail["initial_velocity_min"])
	particles.initial_velocity_max = float(trail["initial_velocity_max"])
	particles.scale_amount_min = float(trail["scale_min"])
	particles.scale_amount_max = float(trail["scale_max"])
	particles.color = _ball_color
	add_child(particles)


func _can_hit_peg(peg: Node) -> bool:
	var peg_key := str(peg.get_instance_id())
	var now := Time.get_ticks_msec() / 1000.0
	var last_hit := float(_peg_hit_times.get(peg_key, -9999.0))
	if now - last_hit < _peg_rehit_cooldown:
		return false
	_peg_hit_times[peg_key] = now
	return true


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

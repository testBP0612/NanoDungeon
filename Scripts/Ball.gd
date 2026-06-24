extends RigidBody2D

signal peg_hit(peg_id: String, hit_position: Vector2, hit_color: Color, combo_count: int)
signal wall_hit(hit_position: Vector2)
signal recovered(ball: RigidBody2D, reason: String)

var ball_id := "normal_ball"
var ball_def: Dictionary = {}
var radius := 10.0
var _recovered := false
var _launch_speed := 0.0
var _bounce_multiplier := 1.0
var _peg_bounce_boost := 1.0
var _max_ball_speed := 0.0
var _ball_color := Color(1.0, 0.86, 0.25)
var _peg_rehit_cooldown := 0.0
var _peg_hit_times: Dictionary = {}
var _feel_config: Dictionary = {}
var _scene_fx: Dictionary = {}
var _ball_squash: Dictionary = {}
var _combo_hits := 0
var _sprite: Sprite2D
var _texture: Texture2D
var _pulse_phase := 0.0
var _visual_squash_scale := Vector2.ONE
var _squash_tween: Tween

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 8
	continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
	body_entered.connect(_on_body_entered)
	_load_texture()


func configure(new_ball_id: String, new_ball_def: Dictionary, player_config: Dictionary, feel_config: Dictionary, field_config: Dictionary = {}) -> void:
	ball_id = new_ball_id
	ball_def = new_ball_def.duplicate(true)
	_feel_config = feel_config.duplicate(true)
	var scene_fx_config: Dictionary = _feel_config.get("scene_fx", {})
	_scene_fx = scene_fx_config.duplicate(true)
	var squash_config: Dictionary = _feel_config.get("ball_squash", {})
	_ball_squash = squash_config.duplicate(true)
	_peg_rehit_cooldown = float(_feel_config["peg_rehit_cooldown_seconds"])
	var bottom_row: Dictionary = field_config.get("bottom_row", {})
	_bounce_multiplier = float(bottom_row.get("bounce_multiplier", 1.0))
	_peg_bounce_boost = float(player_config.get("peg_bounce_boost", 1.0))
	_max_ball_speed = float(player_config.get("max_ball_speed", bottom_row.get("max_ball_speed", 0.0)))
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
	_update_sprite()
	queue_redraw()


func _process(delta: float) -> void:
	if radius <= 0.0:
		return
	_pulse_phase += delta * float(_scene_fx.get("ball_pulse_speed", 3.2))
	_update_sprite()
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
			_apply_speed_boost(_bounce_multiplier)
		else:
			_apply_speed_boost(_peg_bounce_boost)
		_play_squash_feedback()
		if body.has_method("play_hit_feedback"):
			body.play_hit_feedback()
		var hit_color := Color(0.2, 0.85, 1.0)
		if body.has_method("get_peg_color"):
			hit_color = body.get_peg_color()
		_combo_hits += 1
		peg_hit.emit(body.get_peg_id(), body.global_position, hit_color, _combo_hits)
	else:
		wall_hit.emit(global_position)


func get_combo_hits() -> int:
	return _combo_hits


func _apply_speed_boost(multiplier: float) -> void:
	if multiplier <= 0.0:
		return
	var current_speed := linear_velocity.length()
	if current_speed <= 0.01:
		return
	var boosted_speed := current_speed * multiplier
	if _max_ball_speed > 0.0:
		boosted_speed = min(boosted_speed, _max_ball_speed)
	linear_velocity = linear_velocity.normalized() * boosted_speed


func _play_squash_feedback() -> void:
	if not bool(_ball_squash.get("enabled", true)):
		return
	if _squash_tween != null and _squash_tween.is_valid():
		_squash_tween.kill()
	var squash_scale := _vector2_from_array(_ball_squash.get("squash_scale", [1.18, 0.82]), Vector2(1.18, 0.82))
	var stretch_scale := _vector2_from_array(_ball_squash.get("stretch_scale", [0.88, 1.12]), Vector2(0.88, 1.12))
	_squash_tween = create_tween()
	_squash_tween.tween_method(_set_visual_squash_scale, squash_scale, stretch_scale, float(_ball_squash.get("squash_seconds", 0.04)))
	_squash_tween.tween_method(_set_visual_squash_scale, stretch_scale, Vector2.ONE, float(_ball_squash.get("stretch_seconds", 0.06)))
	_squash_tween.tween_interval(float(_ball_squash.get("recover_seconds", 0.08)))
	_squash_tween.tween_callback(func() -> void: _set_visual_squash_scale(Vector2.ONE))


func _set_visual_squash_scale(value: Vector2) -> void:
	_visual_squash_scale = value
	_update_sprite()
	queue_redraw()


func _vector2_from_array(value: Variant, fallback: Vector2) -> Vector2:
	if typeof(value) != TYPE_ARRAY:
		return fallback
	var array := value as Array
	if array.size() < 2:
		return fallback
	return Vector2(float(array[0]), float(array[1]))


func _add_trail() -> void:
	var trail: Dictionary = _feel_config.get("trail", {})
	var particles := CPUParticles2D.new()
	particles.name = "Trail"
	particles.amount = int(round(float(trail["amount"]) * float(_scene_fx.get("ball_trail_amount_multiplier", 1.25))))
	particles.lifetime = float(trail["lifetime"]) * float(_scene_fx.get("ball_trail_lifetime_multiplier", 1.15))
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
	if radius <= 0.0:
		return
	var pulse := _pulse_amount()
	draw_set_transform(Vector2.ZERO, 0.0, _visual_squash_scale)
	var halo := _ball_color
	halo.a = float(_scene_fx.get("ball_halo_alpha", 0.28))
	draw_circle(Vector2.ZERO, radius * float(_scene_fx.get("ball_halo_radius", 1.95)) * pulse, halo)
	var core := Color.WHITE
	core.a = float(_scene_fx.get("ball_core_alpha", 0.82))
	draw_circle(Vector2.ZERO, radius * 0.42 * pulse, core)
	if _texture != null:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return
	draw_circle(Vector2.ZERO, radius, _ball_color)
	draw_circle(Vector2.ZERO, radius * 0.45, Color(1.0, 1.0, 0.9))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _load_texture() -> void:
	var path := "res://assets/balls/ball_base.png"
	if not ResourceLoader.exists(path):
		return
	_texture = load(path)
	if _texture == null:
		return
	_sprite = Sprite2D.new()
	_sprite.name = "ArtSprite"
	_sprite.texture = _texture
	_sprite.centered = true
	_sprite.z_index = 1
	add_child(_sprite)


func _update_sprite() -> void:
	if _sprite == null or _texture == null or radius <= 0.0:
		return
	var target_diameter := radius * 2.45 * _pulse_amount()
	var texture_diameter := float(max(_texture.get_width(), _texture.get_height()))
	_sprite.scale = _visual_squash_scale * (target_diameter / texture_diameter)
	_sprite.modulate = _ball_color


func _pulse_amount() -> float:
	var amount := float(_scene_fx.get("ball_pulse_scale", 0.055))
	return 1.0 + sin(_pulse_phase) * amount

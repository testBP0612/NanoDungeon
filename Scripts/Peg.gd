extends StaticBody2D

var peg_id := "normal_peg"
var peg_def: Dictionary = {}
var radius := 0.0
var _base_color := Color(0.2, 0.85, 1.0)
var _flash := 0.0
var _sprite: Sprite2D
var _texture: Texture2D
var _scene_fx: Dictionary = {}
var _pulse_phase := 0.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	add_to_group("pegs")
	_load_texture()


func configure(new_peg_id: String, new_peg_def: Dictionary, new_radius: float, feel_config: Dictionary = {}) -> void:
	peg_id = new_peg_id
	peg_def = new_peg_def.duplicate(true)
	radius = new_radius
	var scene_fx_config: Dictionary = feel_config.get("scene_fx", {})
	_scene_fx = scene_fx_config.duplicate(true)
	_base_color = _color_for_peg(peg_id)
	if collision_shape != null:
		var shape := CircleShape2D.new()
		shape.radius = radius
		collision_shape.shape = shape
	_update_sprite()
	queue_redraw()


func _process(delta: float) -> void:
	if radius <= 0.0 or not bool(_scene_fx.get("peg_idle_pulse_enabled", true)):
		return
	_pulse_phase += delta * float(_scene_fx.get("peg_pulse_speed", 2.4))
	_update_sprite()
	queue_redraw()


func get_peg_id() -> String:
	return peg_id


func play_hit_feedback() -> void:
	var tween := create_tween()
	tween.tween_method(_set_flash, 1.0, 0.0, 0.16)


func play_reroll_feedback(duration: float, scale_multiplier: float) -> void:
	var original_scale: Vector2 = scale
	var first_leg: float = max(0.01, duration * 0.33)
	var second_leg: float = max(0.01, duration - first_leg)
	var tween := create_tween()
	tween.parallel().tween_method(_set_flash, 0.8, 0.0, duration)
	tween.parallel().tween_property(self, "scale", original_scale * scale_multiplier, first_leg)
	tween.tween_property(self, "scale", original_scale, second_leg)


func get_peg_color() -> Color:
	return _base_color


func _set_flash(value: float) -> void:
	_flash = value
	_update_sprite()
	queue_redraw()


func _color_for_peg(id: String) -> Color:
	match id:
		"burst_peg":
			return Color(1.0, 0.32, 0.12)
		"heal_peg":
			return Color(0.22, 1.0, 0.08)
		"double_peg":
			return Color(1.0, 0.78, 0.24)
		"bounce_peg":
			return Color(0.72, 0.78, 0.9)
		_:
			return Color(0.2, 0.85, 1.0)


func _draw() -> void:
	if radius <= 0.0:
		return
	var outer := _base_color.lerp(Color.WHITE, _flash)
	var pulse := _pulse_amount()
	if peg_id == "bounce_peg":
		_draw_bumper_ring(outer, pulse)
		return
	_draw_peg_glow(outer, pulse)
	if _texture != null:
		return
	draw_circle(Vector2.ZERO, radius, outer)
	draw_circle(Vector2.ZERO, radius * 0.55, Color(0.95, 1.0, 1.0))


func _draw_peg_glow(color: Color, pulse: float) -> void:
	var halo_alpha := float(_scene_fx.get("peg_halo_alpha", 0.22)) + _flash * 0.18
	var halo_radius := radius * float(_scene_fx.get("peg_halo_radius", 1.75)) * pulse
	var halo_color := color
	halo_color.a = halo_alpha
	draw_circle(Vector2.ZERO, halo_radius, halo_color)
	var core_color := Color.WHITE
	core_color.a = float(_scene_fx.get("peg_core_alpha", 0.72)) + _flash * 0.2
	draw_circle(Vector2.ZERO, radius * 0.38 * pulse, core_color)


func _draw_bumper_ring(color: Color, pulse: float) -> void:
	var flash_scale := 1.0 + _flash * float(_scene_fx.get("bumper_hit_pulse_scale", 0.22))
	var ring_radius := radius * float(_scene_fx.get("bumper_ring_radius", 1.45)) * pulse * flash_scale
	var ring_width := float(_scene_fx.get("bumper_ring_width", 5.0))
	var halo_color := color
	halo_color.a = float(_scene_fx.get("bumper_halo_alpha", 0.25)) + _flash * 0.24
	draw_circle(Vector2.ZERO, ring_radius * 1.22, halo_color)
	var outer := _base_color.lerp(Color.WHITE, _flash)
	outer.a = 0.92
	draw_arc(Vector2.ZERO, ring_radius, 0.0, TAU, 96, outer, ring_width, true)
	var inner := Color.WHITE
	inner.a = 0.78
	draw_arc(Vector2.ZERO, radius * 0.72 * pulse, 0.0, TAU, 96, inner, max(1.5, ring_width * 0.42), true)
	var tick_count: int = int(max(1, int(_scene_fx.get("bumper_tick_count", 8))))
	for index in range(tick_count):
		var angle: float = TAU * float(index) / float(tick_count) + _pulse_phase * 0.12
		var start: Vector2 = Vector2.RIGHT.rotated(angle) * (ring_radius - ring_width * 1.6)
		var end: Vector2 = Vector2.RIGHT.rotated(angle) * (ring_radius + ring_width * 1.1)
		var tick_color: Color = Color.WHITE.lerp(color, 0.35)
		tick_color.a = 0.78
		draw_line(start, end, tick_color, float(max(1.5, ring_width * 0.38)), true)


func _load_texture() -> void:
	var path := "res://assets/pegs/peg_base.png"
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
	_update_sprite()


func _update_sprite() -> void:
	if _sprite == null or _texture == null or radius <= 0.0:
		return
	_sprite.visible = peg_id != "bounce_peg"
	var target_diameter := radius * 2.35 * _pulse_amount()
	var texture_diameter := float(max(_texture.get_width(), _texture.get_height()))
	_sprite.scale = Vector2.ONE * (target_diameter / texture_diameter)
	_sprite.modulate = _base_color.lerp(Color.WHITE, _flash)


func _pulse_amount() -> float:
	var amount := float(_scene_fx.get("peg_pulse_scale", 0.075))
	return 1.0 + sin(_pulse_phase) * amount

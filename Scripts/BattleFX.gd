extends Node

var feel_config: Dictionary = {}
var sfx_enabled := true
var _camera: Camera2D
var _ui_root: Control
var _shake_time := 0.0
var _shake_duration := 0.0
var _shake_strength := 0.0


func configure(camera: Camera2D, ui_root: Control, new_feel_config: Dictionary) -> void:
	_camera = camera
	_ui_root = ui_root
	feel_config = new_feel_config.duplicate(true)
	sfx_enabled = bool(_sfx_config()["enabled"])


func update(delta: float) -> void:
	_update_screen_shake(delta)


func set_sfx_enabled(enabled: bool) -> void:
	sfx_enabled = enabled


func spawn_launch_feedback(position: Vector2) -> void:
	var particles := _particles_config()
	spawn_particles(
		position,
		Color(1.0, 0.9, 0.35),
		int(particles["launch_amount"]),
		float(particles["launch_lifetime"])
	)


func spawn_hit_particles(position: Vector2, color: Color) -> void:
	var particles := _particles_config()
	spawn_particles(
		position,
		color,
		int(particles["hit_amount"]),
		float(particles["hit_lifetime"])
	)


func spawn_particles(position: Vector2, color: Color, amount: int, lifetime: float) -> void:
	var particles_config := _particles_config()
	var particles := CPUParticles2D.new()
	particles.position = position
	particles.one_shot = true
	particles.amount = amount
	particles.lifetime = lifetime
	particles.explosiveness = 1.0
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = float(particles_config["emission_radius"])
	particles.direction = Vector2(float(particles_config["direction_x"]), float(particles_config["direction_y"]))
	particles.spread = float(particles_config["spread_degrees"])
	particles.gravity = Vector2(0, float(particles_config["gravity_y"]))
	particles.initial_velocity_min = float(particles_config["initial_velocity_min"])
	particles.initial_velocity_max = float(particles_config["initial_velocity_max"])
	particles.scale_amount_min = float(particles_config["scale_min"])
	particles.scale_amount_max = float(particles_config["scale_max"])
	particles.color = color
	add_child(particles)
	particles.emitting = true
	var timer := get_tree().create_timer(lifetime + float(particles_config["cleanup_extra_delay"]))
	timer.timeout.connect(particles.queue_free)


func show_floating_text(text: String, world_position: Vector2, color: Color) -> void:
	if _ui_root == null:
		return
	var config := _floating_text_config()
	var label := Label.new()
	label.text = text
	label.position = world_position
	label.size = Vector2(float(config["width"]), float(config["height"]))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", int(config["font_size"]))
	label.modulate = color
	_ui_root.add_child(label)

	var rise := Vector2(float(config["rise_x"]), float(config["rise_y"]))
	var duration := float(config["duration"])
	var tween := create_tween()
	tween.parallel().tween_property(label, "position", world_position + rise, duration)
	tween.parallel().tween_property(label, "modulate:a", 0.0, duration)
	tween.tween_callback(label.queue_free)


func start_hit_shake() -> void:
	var shake := _shake_config()
	start_screen_shake(float(shake["hit_strength"]), float(shake["hit_duration"]))


func start_enemy_attack_shake() -> void:
	var shake := _shake_config()
	start_screen_shake(float(shake["enemy_attack_strength"]), float(shake["enemy_attack_duration"]))


func start_screen_shake(strength: float, duration: float) -> void:
	_shake_strength = max(_shake_strength, strength)
	_shake_duration = max(_shake_duration, duration)
	_shake_time = _shake_duration


func play_sfx(event_id: String) -> void:
	if not sfx_enabled:
		return

	var sfx := _sfx_config()
	var frequencies: Dictionary = sfx.get("frequencies", {})
	var frequency := float(frequencies[event_id])
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = float(sfx["mix_rate"])
	stream.buffer_length = float(sfx["buffer_length"])

	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = float(sfx["volume_db"])
	add_child(player)
	player.play()

	var playback := player.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback == null:
		player.queue_free()
		return

	var frame_count := int(stream.mix_rate * float(sfx["duration"]))
	for i in range(frame_count):
		var t := float(i) / stream.mix_rate
		var amp := sin(t * TAU * frequency) * float(sfx["amplitude"]) * (1.0 - float(i) / float(frame_count))
		playback.push_frame(Vector2(amp, amp))

	var timer := get_tree().create_timer(float(sfx["cleanup_delay"]))
	timer.timeout.connect(player.queue_free)


func _update_screen_shake(delta: float) -> void:
	if _camera == null:
		return
	if _shake_time <= 0.0:
		_camera.offset = Vector2.ZERO
		return
	_shake_time = max(0.0, _shake_time - delta)
	var fade: float = _shake_time / max(_shake_duration, 0.001)
	_camera.offset = Vector2(
		randf_range(-_shake_strength, _shake_strength) * fade,
		randf_range(-_shake_strength, _shake_strength) * fade
	)


func _shake_config() -> Dictionary:
	return feel_config.get("shake", {})


func _particles_config() -> Dictionary:
	return feel_config.get("particles", {})


func _floating_text_config() -> Dictionary:
	return feel_config.get("floating_text", {})


func _sfx_config() -> Dictionary:
	return feel_config.get("sfx", {})

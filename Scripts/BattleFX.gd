extends Node

var feel_config: Dictionary = {}
var sfx_enabled := true
var _camera: Camera2D
var _ui_root: Control
var _shake_time := 0.0
var _shake_duration := 0.0
var _shake_strength := 0.0
var _turn_banner: Label
var _telegraph_flash: ColorRect
var _player_hit_flash: ColorRect
var _low_hp_edges: Array[ColorRect] = []
var _low_hp_phase := 0.0


func configure(camera: Camera2D, ui_root: Control, new_feel_config: Dictionary) -> void:
	_camera = camera
	_ui_root = ui_root
	feel_config = new_feel_config.duplicate(true)
	sfx_enabled = bool(_sfx_config()["enabled"])
	_ensure_overlay_nodes()


func update(delta: float) -> void:
	_update_screen_shake(delta)


func update_low_hp(player_hp: int, player_max_hp: int, delta: float) -> void:
	var config := _low_hp_config()
	if _low_hp_edges.is_empty() or not bool(config.get("enabled", true)) or player_max_hp <= 0:
		_set_low_hp_alpha(0.0)
		return
	var ratio := float(player_hp) / float(player_max_hp)
	if ratio > float(config.get("threshold_ratio", 0.25)):
		_set_low_hp_alpha(0.0)
		return
	_low_hp_phase += delta * float(config.get("pulse_speed", 4.0))
	var alpha := (0.5 + sin(_low_hp_phase) * 0.5) * float(config.get("max_alpha", 0.28))
	_set_low_hp_alpha(alpha)


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


func spawn_hit_particles(position: Vector2, color: Color, combo_count := 1) -> void:
	var particles := _particles_config()
	var combo := _combo_config()
	var visual_level = min(max(combo_count - 1, 0), int(combo.get("max_visual_level", 6)))
	spawn_particles(
		position,
		color,
		int(particles["hit_amount"]) + visual_level * int(combo.get("particle_amount_step", 0)),
		float(particles["hit_lifetime"]) + float(visual_level) * float(combo.get("particle_lifetime_step", 0.0))
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


func show_combo_feedback(combo_count: int, world_position: Vector2) -> void:
	var config := _combo_config()
	if not bool(config.get("enabled", true)) or combo_count < int(config.get("show_at", 2)):
		return
	show_floating_text("combo x%s" % combo_count, world_position + Vector2(0, -24), Color(String(config.get("text_color", "#FFE66D"))))


func show_miss_feedback(world_position: Vector2) -> void:
	var config := _drain_config()
	show_floating_text(String(config.get("miss_text", "MISS")), world_position, Color(String(config.get("miss_color", "#6F748A"))))
	var shake := _shake_config()
	start_screen_shake(float(shake.get("miss_strength", 1.5)), float(shake.get("miss_duration", 0.08)))


func start_hit_shake() -> void:
	var shake := _shake_config()
	start_screen_shake(float(shake["hit_strength"]), float(shake["hit_duration"]))


func start_enemy_attack_shake() -> void:
	var shake := _shake_config()
	start_screen_shake(float(shake["enemy_attack_strength"]), float(shake["enemy_attack_duration"]))


func start_telegraph_shake() -> void:
	var shake := _shake_config()
	start_screen_shake(float(shake.get("telegraph_strength", 7.0)), float(shake.get("telegraph_duration", 0.18)))


func start_screen_shake(strength: float, duration: float) -> void:
	_shake_strength = max(_shake_strength, strength)
	_shake_duration = max(_shake_duration, duration)
	_shake_time = _shake_duration


func play_sfx(event_id: String, pitch_scale := 1.0) -> void:
	if not sfx_enabled:
		return

	var sfx := _sfx_config()
	var frequencies: Dictionary = sfx.get("frequencies", {})
	if not frequencies.has(event_id):
		return
	var frequency := float(frequencies[event_id]) * pitch_scale
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


func show_turn_banner(text: String, color: Color, duration := -1.0) -> void:
	if _turn_banner == null:
		return
	var config := _turn_pacing_config()
	var show_duration := float(config.get("banner_duration", 0.72)) if duration < 0.0 else duration
	_turn_banner.text = text
	_turn_banner.modulate = color
	_turn_banner.modulate.a = 0.0
	_turn_banner.scale = Vector2(0.96, 0.96)
	var tween := create_tween()
	tween.parallel().tween_property(_turn_banner, "modulate:a", 1.0, 0.12)
	tween.parallel().tween_property(_turn_banner, "scale", Vector2.ONE, 0.12)
	tween.tween_interval(show_duration)
	tween.parallel().tween_property(_turn_banner, "modulate:a", 0.0, 0.18)
	tween.parallel().tween_property(_turn_banner, "scale", Vector2(1.02, 1.02), 0.18)
	await tween.finished


func show_boss_telegraph() -> void:
	var config := _telegraph_config()
	if not bool(config.get("enabled", true)):
		return
	_flash_overlay(_telegraph_flash, Color(1.0, 0.05, 0.08, float(config.get("flash_alpha", 0.28))), float(config.get("flash_seconds", 0.34)))
	start_telegraph_shake()
	await show_turn_banner(String(config.get("boss_warning_text", "核心過載 來襲")), Color(1.0, 0.16, 0.18), float(config.get("banner_duration", 0.95)))


func flash_player_hit() -> void:
	var config := _enemy_attack_config()
	_flash_overlay(_player_hit_flash, Color(1.0, 0.03, 0.03, 0.24), float(config.get("player_hit_flash_seconds", 0.22)))


func flash_enemy_hit(enemy_node: CanvasItem) -> void:
	if enemy_node == null:
		return
	var config := _enemy_attack_config()
	var original_position: Vector2 = enemy_node.position
	var original_color: Color = enemy_node.modulate
	var shake_pixels := float(config.get("enemy_hit_shake_pixels", 6.0))
	var tween := create_tween()
	tween.parallel().tween_property(enemy_node, "modulate", Color.WHITE, 0.04)
	tween.parallel().tween_property(enemy_node, "position", original_position + Vector2(shake_pixels, 0), 0.04)
	tween.tween_property(enemy_node, "position", original_position - Vector2(shake_pixels * 0.6, 0), 0.04)
	tween.parallel().tween_property(enemy_node, "modulate", original_color, float(config.get("enemy_hit_flash_seconds", 0.18)))
	tween.parallel().tween_property(enemy_node, "position", original_position, float(config.get("enemy_hit_flash_seconds", 0.18)))
	await tween.finished


func play_enemy_windup(enemy_node: CanvasItem) -> void:
	if enemy_node == null:
		return
	var config := _enemy_attack_config()
	var original_position: Vector2 = enemy_node.position
	enemy_node.set_meta("feel_original_position", original_position)
	var lunge := float(config.get("enemy_lunge_pixels", 14.0))
	var tween := create_tween()
	tween.tween_property(enemy_node, "position", original_position + Vector2(-lunge, lunge * 0.45), float(config.get("windup_seconds", 0.34)))
	await tween.finished


func play_enemy_recover(enemy_node: CanvasItem) -> void:
	if enemy_node == null:
		return
	var config := _enemy_attack_config()
	var original_position: Vector2 = enemy_node.get_meta("feel_original_position", enemy_node.position)
	var tween := create_tween()
	tween.tween_property(enemy_node, "position", original_position, float(config.get("recover_seconds", 0.22)))
	await tween.finished


func play_launcher_recoil(launcher_node: Node2D, direction: Vector2) -> void:
	if launcher_node == null:
		return
	var config := _charge_config()
	var original_position := launcher_node.position
	var recoil := -direction.normalized() * float(config.get("launcher_recoil_pixels", 10.0))
	var tween := create_tween()
	tween.tween_property(launcher_node, "position", original_position + recoil, float(config.get("launcher_recoil_seconds", 0.11)) * 0.45)
	tween.tween_property(launcher_node, "position", original_position, float(config.get("launcher_recoil_seconds", 0.11)))


func update_charge_feedback(power: float, power_bar: Control, launcher_node: CanvasItem) -> void:
	var config := _charge_config()
	var alpha: float = lerp(float(config.get("bar_min_alpha", 0.55)), float(config.get("bar_max_alpha", 1.0)), clamp(power / 100.0, 0.0, 1.0))
	if power_bar != null:
		power_bar.modulate.a = alpha
	if launcher_node != null:
		launcher_node.modulate = Color(0.9, 0.25 + power * 0.004, 1.0, 1.0)


func animate_settlement(damage_label: Label, hp_bar: ProgressBar, total_damage: int, from_hp: int, to_hp: int) -> void:
	var config := _settlement_config()
	var count_duration := float(config.get("count_up_seconds", 0.42))
	var drain_duration := float(config.get("enemy_hp_drain_seconds", 0.46))
	var tween := create_tween()
	var update_damage := func(value: float) -> void:
		if damage_label != null:
			damage_label.text = "本回合傷害：%s" % int(round(value))
	tween.tween_method(update_damage, 0.0, float(total_damage), count_duration)
	if hp_bar != null:
		tween.tween_property(hp_bar, "value", to_hp, drain_duration).from(from_hp)
	await tween.finished


func flash_reroll_peg(peg: Node, delay: float) -> void:
	var config := _reroll_flash_config()
	if peg == null or not peg.has_method("play_reroll_feedback") or not bool(config.get("enabled", true)):
		return
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
	peg.play_reroll_feedback(float(config.get("duration", 0.18)), float(config.get("scale", 1.18)))


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


func _ensure_overlay_nodes() -> void:
	if _ui_root == null:
		return
	if _turn_banner == null:
		_turn_banner = Label.new()
		_turn_banner.name = "TurnBanner"
		_turn_banner.position = Vector2(260, 420)
		_turn_banner.size = Vector2(504, 68)
		_turn_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_turn_banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_turn_banner.add_theme_font_size_override("font_size", 34)
		_turn_banner.modulate.a = 0.0
		_ui_root.add_child(_turn_banner)
	if _telegraph_flash == null:
		_telegraph_flash = _make_full_rect("TelegraphFlash", Color.TRANSPARENT)
		_ui_root.add_child(_telegraph_flash)
	if _player_hit_flash == null:
		_player_hit_flash = _make_full_rect("PlayerHitFlash", Color.TRANSPARENT)
		_ui_root.add_child(_player_hit_flash)
	if _low_hp_edges.is_empty():
		_low_hp_edges.append(_make_edge_rect("LowHpTop", Vector2(0, 0), Vector2(1024, 90)))
		_low_hp_edges.append(_make_edge_rect("LowHpBottom", Vector2(0, 934), Vector2(1024, 90)))
		_low_hp_edges.append(_make_edge_rect("LowHpLeft", Vector2(0, 0), Vector2(76, 1024)))
		_low_hp_edges.append(_make_edge_rect("LowHpRight", Vector2(948, 0), Vector2(76, 1024)))
		for edge in _low_hp_edges:
			_ui_root.add_child(edge)


func _make_full_rect(node_name: String, color: Color) -> ColorRect:
	var rect := ColorRect.new()
	rect.name = node_name
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.color = color
	return rect


func _make_edge_rect(node_name: String, position: Vector2, size: Vector2) -> ColorRect:
	var rect := ColorRect.new()
	rect.name = node_name
	rect.position = position
	rect.size = size
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.color = Color(1.0, 0.02, 0.02, 0.0)
	return rect


func _flash_overlay(rect: ColorRect, color: Color, duration: float) -> void:
	if rect == null:
		return
	rect.color = color
	rect.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(rect, "modulate:a", 1.0, duration * 0.35)
	tween.tween_property(rect, "modulate:a", 0.0, duration * 0.65)


func _set_low_hp_alpha(alpha: float) -> void:
	for edge in _low_hp_edges:
		edge.color.a = alpha


func _shake_config() -> Dictionary:
	return feel_config.get("shake", {})


func _turn_pacing_config() -> Dictionary:
	return feel_config.get("turn_pacing", {})


func _enemy_attack_config() -> Dictionary:
	return feel_config.get("enemy_attack", {})


func _combo_config() -> Dictionary:
	return feel_config.get("combo", {})


func _telegraph_config() -> Dictionary:
	return feel_config.get("telegraph", {})


func _low_hp_config() -> Dictionary:
	return feel_config.get("low_hp", {})


func _charge_config() -> Dictionary:
	return feel_config.get("charge", {})


func _drain_config() -> Dictionary:
	return feel_config.get("drain", {})


func _settlement_config() -> Dictionary:
	return feel_config.get("settlement", {})


func _reroll_flash_config() -> Dictionary:
	return feel_config.get("reroll_flash", {})


func _particles_config() -> Dictionary:
	return feel_config.get("particles", {})


func _floating_text_config() -> Dictionary:
	return feel_config.get("floating_text", {})


func _sfx_config() -> Dictionary:
	return feel_config.get("sfx", {})

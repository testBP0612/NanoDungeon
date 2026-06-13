extends Node2D

enum BattleState { INIT, ROUND_START, AIMING, LAUNCHED, SETTLE, ENEMY_TURN, CHECK, ENDED }

const BALL_SCENE := preload("res://Scenes/Ball.tscn")
const PEG_SCENE := preload("res://Scenes/Peg.tscn")
const ROUND_CONTEXT_SCRIPT := preload("res://Scripts/RoundContext.gd")
const EFFECT_RESOLVER_SCRIPT := preload("res://Scripts/EffectResolver.gd")

var state := BattleState.INIT
var player_config: Dictionary = {}
var normal_peg_def: Dictionary = {}
var normal_ball_def: Dictionary = {}
var enemy_def: Dictionary = {}
var enemy_hp := 0
var enemy_max_hp := 0
var round_index := 0
var launcher_position := Vector2(512, 118)
var phase2_ball_sequence: Array = []
var sfx_enabled := true
var _shake_time := 0.0
var _shake_duration := 0.0
var _shake_strength := 0.0
var round_context: RefCounted = ROUND_CONTEXT_SCRIPT.new()
var effect_resolver: RefCounted = EFFECT_RESOLVER_SCRIPT.new()

@onready var battle_camera: Camera2D = $BattleCamera
@onready var peg_container: Node2D = $PinballField/PegContainer
@onready var ball_container: Node2D = $PinballField/BallContainer
@onready var bottom_sensor: Area2D = $PinballField/BottomSensor
@onready var launcher_visual: Polygon2D = $AimOverlay/LauncherVisual
@onready var aim_line: Line2D = $AimOverlay/AimLine
@onready var player_hp_label: Label = $BattleUI/UIRoot/PlayerHPLabel
@onready var enemy_hp_label: Label = $BattleUI/UIRoot/EnemyHPLabel
@onready var round_label: Label = $BattleUI/UIRoot/RoundLabel
@onready var damage_label: Label = $BattleUI/UIRoot/DamageLabel
@onready var balls_label: Label = $BattleUI/UIRoot/BallsLabel
@onready var status_label: Label = $BattleUI/UIRoot/StatusLabel
@onready var sfx_toggle_button: Button = $BattleUI/UIRoot/SfxToggleButton
@onready var restart_button: Button = $BattleUI/UIRoot/RestartButton
@onready var menu_button: Button = $BattleUI/UIRoot/MenuButton


func _ready() -> void:
	RunState.ensure_run_started()
	_load_definitions()
	_connect_scene_nodes()
	_spawn_pegs()
	enemy_hp = int(enemy_def["hp"])
	enemy_max_hp = enemy_hp
	_transition_to(BattleState.ROUND_START)


func _process(delta: float) -> void:
	_update_screen_shake(delta)
	_update_aim_overlay()
	_update_ui()


func _input(event: InputEvent) -> void:
	if state != BattleState.AIMING:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_fire_ball()


func _load_definitions() -> void:
	if not DataLoader.loaded:
		DataLoader.load_all()
	player_config = DataLoader.get_player_config()
	normal_peg_def = DataLoader.get_peg("normal_peg")
	normal_ball_def = DataLoader.get_ball(String(player_config["starting_ball_id"]))
	phase2_ball_sequence = player_config.get("phase2_test_ball_sequence", [String(player_config["starting_ball_id"])])
	sfx_enabled = bool(player_config.get("sfx_enabled", true))
	enemy_def = DataLoader.get_enemy(RunState.current_battle_index)


func _connect_scene_nodes() -> void:
	bottom_sensor.body_entered.connect(_on_bottom_sensor_body_entered)
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	sfx_toggle_button.pressed.connect(_on_sfx_toggle_pressed)
	launcher_visual.position = launcher_position


func _spawn_pegs() -> void:
	var peg_slots := [
		{"id": "normal_peg", "position": Vector2(370, 230)},
		{"id": "burst_peg", "position": Vector2(512, 230)},
		{"id": "heal_peg", "position": Vector2(654, 230)},
		{"id": "double_peg", "position": Vector2(440, 340)},
		{"id": "normal_peg", "position": Vector2(584, 340)},
		{"id": "burst_peg", "position": Vector2(370, 455)},
		{"id": "heal_peg", "position": Vector2(512, 455)},
		{"id": "double_peg", "position": Vector2(654, 455)},
	]

	for slot in peg_slots:
		var peg_id := String(slot["id"])
		var peg := PEG_SCENE.instantiate()
		peg_container.add_child(peg)
		peg.position = slot["position"]
		peg.configure(peg_id, DataLoader.get_peg(peg_id))


func _transition_to(next_state: BattleState, message := "") -> void:
	state = next_state
	match state:
		BattleState.ROUND_START:
			_begin_round()
		BattleState.AIMING:
			status_label.text = "瞄準後點擊發射"
		BattleState.SETTLE:
			_settle_round()
		BattleState.ENEMY_TURN:
			_enemy_turn()
		BattleState.CHECK:
			_check_battle_end()
		BattleState.ENDED:
			_show_end_state(message)


func _begin_round() -> void:
	round_index += 1
	round_context.start_round(RunState.balls_per_round)
	_transition_to(BattleState.AIMING)


func _fire_ball() -> void:
	if round_context.balls_remaining <= 0:
		return

	var ball := BALL_SCENE.instantiate()
	var ball_id := _ball_id_for_next_launch()
	var ball_def := DataLoader.get_ball(ball_id)
	ball_container.add_child(ball)
	ball.position = launcher_position
	ball.configure(ball_id, ball_def, player_config)
	ball.peg_hit.connect(_on_ball_peg_hit)
	ball.wall_hit.connect(_on_ball_wall_hit)
	ball.recovered.connect(_on_ball_recovered)
	var launch_result: Dictionary = effect_resolver.apply_ball_launch_effect(ball_def, round_context)

	round_context.balls_remaining -= 1
	round_context.balls_in_play += 1
	status_label.text = String(launch_result.get("message", ""))
	if status_label.text.is_empty():
		status_label.text = "%s 飛行中" % String(ball_def.get("name", "Ball"))
	_transition_to(BattleState.LAUNCHED)
	_spawn_launch_feedback()
	_play_sfx("launch")
	ball.launch(_aim_direction())
	_update_ui()


func _aim_direction() -> Vector2:
	var direction := get_global_mouse_position() - launcher_position
	if direction.length() <= 0.01:
		return Vector2.DOWN
	if direction.y < 0.2:
		direction.y = 0.2
	return direction.normalized()


func _update_aim_overlay() -> void:
	launcher_visual.visible = true
	aim_line.visible = state == BattleState.AIMING
	if aim_line.visible:
		var direction := _aim_direction()
		aim_line.points = PackedVector2Array([
			launcher_position,
			launcher_position + direction * 115.0,
		])


func _ball_id_for_next_launch() -> String:
	if phase2_ball_sequence.is_empty():
		return String(player_config["starting_ball_id"])
	var launched_this_round: int = RunState.balls_per_round - int(round_context.balls_remaining)
	return String(phase2_ball_sequence[launched_this_round % phase2_ball_sequence.size()])


func _on_ball_peg_hit(peg_id: String, hit_position: Vector2, hit_color: Color) -> void:
	var peg_def := DataLoader.get_peg(peg_id)
	var result: Dictionary = effect_resolver.apply_peg_effect(peg_def, round_context)
	var message := String(result.get("message", ""))
	if not message.is_empty():
		status_label.text = message
	var damage_added := int(result.get("damage_added", 0))
	var heal_added := int(result.get("heal_added", 0))
	var multiplier_applied := bool(result.get("multiplier_applied", false))
	var feedback_text := String(result.get("feedback_text", ""))
	if damage_added > 0:
		_show_floating_text(feedback_text, hit_position, hit_color)
	if heal_added > 0:
		_show_floating_text(feedback_text, hit_position, Color(0.22, 1.0, 0.08))
	if multiplier_applied:
		_show_floating_text(feedback_text, hit_position, Color(1.0, 0.78, 0.24))
	_spawn_hit_particles(hit_position, hit_color)
	_start_screen_shake(2.5, 0.10)
	_play_sfx("hit")
	_update_ui()


func _on_ball_wall_hit(_hit_position: Vector2) -> void:
	_play_sfx("wall")


func _on_ball_recovered(_ball: RigidBody2D, reason: String) -> void:
	round_context.balls_in_play = max(0, round_context.balls_in_play - 1)
	status_label.text = "球已回收：%s" % reason
	_play_sfx("drop")
	if round_context.balls_in_play > 0:
		return
	if round_context.balls_remaining > 0:
		_transition_to(BattleState.AIMING)
	else:
		_transition_to(BattleState.SETTLE)


func _on_bottom_sensor_body_entered(body: Node) -> void:
	if body.has_method("recover"):
		body.recover("bottom")


func _settle_round() -> void:
	var settlement: Dictionary = effect_resolver.apply_settlement_effects(round_context)
	var bonus_damage := int(settlement.get("bonus_damage", 0))
	var heal_amount := int(settlement.get("heal_amount", 0))
	if heal_amount > 0:
		RunState.heal_player(heal_amount)
	round_context.mark_settled()
	enemy_hp = max(0, enemy_hp - round_context.damage_accumulator)
	status_label.text = "結算 %s 傷害" % round_context.damage_accumulator
	if bonus_damage > 0:
		status_label.text += "（Blast +%s）" % bonus_damage
	if heal_amount > 0:
		status_label.text += "，回復 %s HP" % heal_amount
	_show_floating_text("TOTAL %s" % round_context.damage_accumulator, Vector2(512, 610), Color(1.0, 0.9, 0.35))
	_play_sfx("settle")
	_transition_to(BattleState.CHECK)


func _enemy_turn() -> void:
	var base_attack := int(enemy_def["attack"])
	var attack: int = effect_resolver.resolve_enemy_attack(base_attack, round_context)
	RunState.damage_player(attack)
	round_context.enemy_acted_this_settlement = true
	status_label.text = "%s 反擊，玩家 -%s HP" % [String(enemy_def["name"]), attack]
	if attack < base_attack:
		status_label.text += "（Shield 減免）"
	_transition_to(BattleState.CHECK)


func _check_battle_end() -> void:
	if enemy_hp <= 0:
		RunState.kills += 1
		_transition_to(BattleState.ENDED, "敵人已擊破")
		return
	if RunState.is_player_dead():
		_transition_to(BattleState.ENDED, "玩家 HP 歸零")
		return
	if not round_context.enemy_acted_this_settlement:
		_transition_to(BattleState.ENEMY_TURN)
	else:
		_transition_to(BattleState.ROUND_START)


func _show_end_state(message: String) -> void:
	status_label.text = message
	restart_button.visible = true
	menu_button.visible = true


func _update_ui() -> void:
	if player_hp_label == null:
		return
	player_hp_label.text = "玩家 HP：%s / %s" % [RunState.player_hp, RunState.player_max_hp]
	enemy_hp_label.text = "敵人 HP：%s / %s  %s" % [enemy_hp, enemy_max_hp, String(enemy_def.get("name", ""))]
	round_label.text = "回合：%s" % round_index
	damage_label.text = "本回合傷害：%s" % round_context.damage_accumulator
	balls_label.text = "剩餘球：%s｜場上球：%s" % [round_context.balls_remaining, round_context.balls_in_play]
	sfx_toggle_button.text = "SFX: %s" % ("ON" if sfx_enabled else "OFF")


func _spawn_launch_feedback() -> void:
	_spawn_hit_particles(launcher_position, Color(1.0, 0.9, 0.35), 8, 0.18)


func _spawn_hit_particles(hit_position: Vector2, color: Color, amount := 14, lifetime := 0.25) -> void:
	var particles := CPUParticles2D.new()
	particles.position = hit_position
	particles.one_shot = true
	particles.amount = amount
	particles.lifetime = lifetime
	particles.explosiveness = 1.0
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 4.0
	particles.direction = Vector2.UP
	particles.spread = 180.0
	particles.gravity = Vector2(0, 180)
	particles.initial_velocity_min = 60.0
	particles.initial_velocity_max = 130.0
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 4.0
	particles.color = color
	add_child(particles)
	particles.emitting = true
	var timer := get_tree().create_timer(lifetime + 0.15)
	timer.timeout.connect(particles.queue_free)


func _show_floating_text(text: String, world_position: Vector2, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.position = world_position
	label.size = Vector2(140, 30)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 20)
	label.modulate = color
	$BattleUI/UIRoot.add_child(label)
	var tween := create_tween()
	tween.parallel().tween_property(label, "position", world_position + Vector2(-20, -42), 0.55)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.55)
	tween.tween_callback(label.queue_free)


func _start_screen_shake(strength: float, duration: float) -> void:
	_shake_strength = max(_shake_strength, strength)
	_shake_duration = max(_shake_duration, duration)
	_shake_time = _shake_duration


func _update_screen_shake(delta: float) -> void:
	if _shake_time <= 0.0:
		battle_camera.offset = Vector2.ZERO
		return
	_shake_time = max(0.0, _shake_time - delta)
	var fade: float = _shake_time / max(_shake_duration, 0.001)
	battle_camera.offset = Vector2(
		randf_range(-_shake_strength, _shake_strength) * fade,
		randf_range(-_shake_strength, _shake_strength) * fade
	)


func _play_sfx(event_id: String) -> void:
	if not sfx_enabled:
		return

	var frequencies := {
		"launch": 660.0,
		"hit": 920.0,
		"wall": 420.0,
		"drop": 240.0,
		"settle": 520.0,
	}
	var frequency := float(frequencies.get(event_id, 440.0))
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = 22050.0
	stream.buffer_length = 0.08

	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = -16.0
	add_child(player)
	player.play()

	var playback := player.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback == null:
		player.queue_free()
		return
	var frame_count := int(stream.mix_rate * 0.055)
	for i in range(frame_count):
		var t := float(i) / stream.mix_rate
		var amp := sin(t * TAU * frequency) * 0.18 * (1.0 - float(i) / float(frame_count))
		playback.push_frame(Vector2(amp, amp))

	var timer := get_tree().create_timer(0.12)
	timer.timeout.connect(player.queue_free)


func _on_sfx_toggle_pressed() -> void:
	sfx_enabled = not sfx_enabled
	_update_ui()


func _on_restart_pressed() -> void:
	RunState.reset_new_run()
	get_tree().reload_current_scene()


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

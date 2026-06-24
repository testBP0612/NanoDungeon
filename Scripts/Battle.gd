extends Node2D

enum BattleState { INIT, ROUND_START, AIMING, LAUNCHED, SETTLE, ENEMY_TURN, CHECK, REWARD, GAME_OVER, VICTORY }

const BALL_SCENE := preload("res://Scenes/Ball.tscn")
const PEG_SCENE := preload("res://Scenes/Peg.tscn")
const ROUND_CONTEXT_SCRIPT := preload("res://Scripts/RoundContext.gd")
const EFFECT_RESOLVER_SCRIPT := preload("res://Scripts/EffectResolver.gd")
const FIELD_GENERATOR_SCRIPT := preload("res://Scripts/FieldGenerator.gd")
const UI_THEME_SCRIPT := preload("res://Scripts/UITheme.gd")

var state := BattleState.INIT
var player_config: Dictionary = {}
var feel_config: Dictionary = {}
var overload_config: Dictionary = {}
var enemy_def: Dictionary = {}
var enemy_hp := 0
var enemy_max_hp := 0
var round_index := 0
var launcher_position := Vector2(816, 118)
var sfx_enabled := true
var _last_player_hp := -1
var _last_enemy_hp := -1
var field_config: Dictionary = {}
var dynamic_peg_cells: Array = []
var dynamic_peg_nodes: Array[Node] = []
var bottom_peg_nodes: Array[Node] = []
var _settlement_animating := false
var _overload_triggered_this_round := false
var _overload_active_this_round := false
var _execute_in_progress := false
var round_context: RefCounted = ROUND_CONTEXT_SCRIPT.new()
var effect_resolver: RefCounted = EFFECT_RESOLVER_SCRIPT.new()
var field_generator: RefCounted = FIELD_GENERATOR_SCRIPT.new()
var _enemy_float_phase := 0.0
var _enemy_portrait_base_position := Vector2.ZERO
var _launcher_ball_sprite: Sprite2D
var _aim_endpoint_marker: Polygon2D
var _aim_dash_segments: Array[Line2D] = []

@onready var battle_camera: Camera2D = $BattleCamera
@onready var battle_fx: Node = $BattleFX
@onready var peg_container: Node2D = $PinballField/PegContainer
@onready var ball_container: Node2D = $PinballField/BallContainer
@onready var bottom_sensor: Area2D = $PinballField/BottomSensor
@onready var launcher_visual: Polygon2D = $AimOverlay/LauncherVisual
@onready var aim_line: Line2D = $AimOverlay/AimLine
@onready var player_hp_label: Label = $BattleUI/UIRoot/PlayerHPLabel
@onready var enemy_hp_label: Label = $BattleUI/UIRoot/EnemyHPLabel
@onready var player_hp_bar: ProgressBar = $BattleUI/UIRoot/PlayerHPBar
@onready var enemy_hp_bar: ProgressBar = $BattleUI/UIRoot/EnemyHPBar
@onready var round_label: Label = $BattleUI/UIRoot/RoundLabel
@onready var damage_label: Label = $BattleUI/UIRoot/DamageLabel
@onready var balls_label: Label = $BattleUI/UIRoot/BallsLabel
@onready var launch_label: Label = $BattleUI/UIRoot/LaunchSpeedLabel
@onready var launch_bar: ProgressBar = $BattleUI/UIRoot/LaunchSpeedBar
@onready var overload_label: Label = $BattleUI/UIRoot/OverloadLabel
@onready var overload_bar: ProgressBar = $BattleUI/UIRoot/OverloadBar
@onready var floor_label: Label = $BattleUI/UIRoot/FloorLabel
@onready var enemy_type_label: Label = $BattleUI/UIRoot/EnemyTypeLabel
@onready var enemy_dialogue_label: Label = $BattleUI/UIRoot/EnemyDialogueLabel
@onready var enemy_portrait: ColorRect = $BattleUI/UIRoot/EnemyPortrait
@onready var enemy_portrait_texture: TextureRect = $BattleUI/UIRoot/EnemyPortrait/EnemyPortraitTexture
@onready var status_label: Label = $BattleUI/UIRoot/StatusLabel
@onready var sfx_toggle_button: Button = $BattleUI/UIRoot/SfxToggleButton
@onready var restart_button: Button = $BattleUI/UIRoot/RestartButton
@onready var menu_button: Button = $BattleUI/UIRoot/MenuButton
@onready var field_border: Line2D = $PinballField/FieldBorder


func _ready() -> void:
	RunState.ensure_run_started()
	_load_definitions()
	_connect_scene_nodes()
	_spawn_pegs()
	_load_enemy_from_run_state()
	await _transition_to(BattleState.ROUND_START)


func _process(delta: float) -> void:
	battle_fx.update(delta)
	battle_fx.update_low_hp(RunState.player_hp, RunState.player_max_hp, delta)
	_update_enemy_idle(delta)
	battle_fx.update_launcher_ready_feedback(launch_bar, _launcher_feedback_node())
	_update_aim_overlay()
	_update_ui()


func _input(event: InputEvent) -> void:
	if _execute_in_progress:
		return
	if state != BattleState.AIMING:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_handle_launch_input()
	elif event is InputEventKey and event.keycode == KEY_SPACE and event.pressed and not event.echo:
		_handle_launch_input()


func _load_definitions() -> void:
	if not DataLoader.loaded:
		DataLoader.load_all()
	player_config = DataLoader.get_player_config()
	feel_config = DataLoader.get_feel_config()
	field_config = DataLoader.get_field_config()
	overload_config = DataLoader.get_overload_config()
	sfx_enabled = bool(feel_config["sfx"]["enabled"])


func _connect_scene_nodes() -> void:
	UI_THEME_SCRIPT.apply_to($BattleUI/UIRoot, feel_config.get("hud", {}))
	_layout_scene_polish_ui()
	_add_launcher_ball_sprite()
	_add_aim_endpoint_marker()
	_add_hud_panel()
	_add_enemy_panel()
	_add_battle_background()
	_add_hud_frames()
	battle_fx.configure(battle_camera, $BattleUI/UIRoot, feel_config)
	battle_fx.configure_overload(overload_config)
	battle_fx.set_sfx_enabled(sfx_enabled)
	bottom_sensor.body_entered.connect(_on_bottom_sensor_body_entered)
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	sfx_toggle_button.pressed.connect(_on_sfx_toggle_pressed)
	launcher_visual.position = launcher_position


func _load_enemy_from_run_state() -> void:
	enemy_def = DataLoader.get_enemy(RunState.current_battle_index)
	enemy_hp = int(enemy_def["hp"])
	enemy_max_hp = enemy_hp
	round_index = 0
	_last_enemy_hp = -1
	_update_enemy_display()


func _update_enemy_display() -> void:
	var enemy_type := String(enemy_def.get("type", "normal"))
	enemy_type_label.text = enemy_type.to_upper()
	enemy_dialogue_label.text = String(enemy_def.get("dialogue", ""))
	floor_label.text = "場次：%s / %s" % [RunState.current_battle_index + 1, DataLoader.enemies.size()]
	var has_portrait := _set_enemy_portrait_texture(String(enemy_def.get("id", "")))
	match enemy_type:
		"boss":
			enemy_portrait.color = Color(0.8, 0.05, 0.08, 0.0 if has_portrait else 0.55)
		"elite":
			enemy_portrait.color = Color(1.0, 0.42, 0.12, 0.0 if has_portrait else 0.55)
		_:
			enemy_portrait.color = Color(1.0, 0.18, 0.58, 0.0 if has_portrait else 0.45)


func _layout_scene_polish_ui() -> void:
	var hud: Dictionary = feel_config.get("hud", {})
	var enemy_display: Dictionary = feel_config.get("enemy_display", {})
	player_hp_label.position = _vector2_from_array(hud.get("player_label_position", [32, 32]), player_hp_label.position)
	player_hp_label.size = _vector2_from_array(hud.get("player_label_size", [280, 30]), player_hp_label.size)
	player_hp_bar.position = _vector2_from_array(hud.get("player_bar_position", [32, 66]), player_hp_bar.position)
	player_hp_bar.size = _vector2_from_array(hud.get("player_bar_size", [252, 16]), player_hp_bar.size)
	round_label.position = _vector2_from_array(hud.get("round_label_position", [32, 104]), round_label.position)
	damage_label.position = _vector2_from_array(hud.get("damage_label_position", [32, 138]), damage_label.position)
	balls_label.position = _vector2_from_array(hud.get("balls_label_position", [32, 172]), balls_label.position)
	launch_label.position = _vector2_from_array(hud.get("launch_label_position", [32, 214]), launch_label.position)
	launch_bar.position = _vector2_from_array(hud.get("launch_bar_position", [32, 248]), launch_bar.position)
	launch_bar.size = _vector2_from_array(hud.get("launch_bar_size", [252, 16]), launch_bar.size)
	overload_label.position = _vector2_from_array(hud.get("overload_label_position", [32, 286]), overload_label.position)
	overload_bar.position = _vector2_from_array(hud.get("overload_bar_position", [32, 320]), overload_bar.position)
	overload_bar.size = _vector2_from_array(hud.get("overload_bar_size", [252, 16]), overload_bar.size)
	status_label.position = _vector2_from_array(hud.get("status_position", [560, 990]), status_label.position)
	status_label.size = _vector2_from_array(hud.get("status_size", [520, 36]), status_label.size)
	sfx_toggle_button.position = _vector2_from_array(hud.get("sfx_button_position", [1536, 24]), sfx_toggle_button.position)
	sfx_toggle_button.size = _vector2_from_array(hud.get("sfx_button_size", [120, 38]), sfx_toggle_button.size)
	enemy_portrait.position = _vector2_from_array(enemy_display.get("portrait_position", [746, 112]), enemy_portrait.position)
	enemy_portrait.size = _vector2_from_array(enemy_display.get("portrait_size", [232, 202]), enemy_portrait.size)
	_enemy_portrait_base_position = enemy_portrait.position
	enemy_hp_label.position = _vector2_from_array(enemy_display.get("hp_label_position", [720, 320]), enemy_hp_label.position)
	enemy_hp_label.size = _vector2_from_array(enemy_display.get("hp_label_size", [280, 48]), enemy_hp_label.size)
	enemy_hp_bar.position = _vector2_from_array(enemy_display.get("hp_bar_position", [732, 374]), enemy_hp_bar.position)
	enemy_hp_bar.size = _vector2_from_array(enemy_display.get("hp_bar_size", [252, 16]), enemy_hp_bar.size)
	enemy_type_label.position = _vector2_from_array(enemy_display.get("type_label_position", [720, 398]), enemy_type_label.position)
	enemy_type_label.size = _vector2_from_array(enemy_display.get("type_label_size", [280, 28]), enemy_type_label.size)
	enemy_dialogue_label.position = _vector2_from_array(enemy_display.get("dialogue_position", [690, 432]), enemy_dialogue_label.position)
	enemy_dialogue_label.size = _vector2_from_array(enemy_display.get("dialogue_size", [318, 56]), enemy_dialogue_label.size)
	floor_label.position = _vector2_from_array(enemy_display.get("floor_label_position", [734, 58]), floor_label.position)
	for item in [player_hp_label, player_hp_bar, enemy_hp_label, enemy_hp_bar, round_label, damage_label, balls_label, launch_label, launch_bar, overload_label, overload_bar, floor_label, enemy_type_label, enemy_dialogue_label, status_label, sfx_toggle_button]:
		(item as CanvasItem).z_index = 20
	enemy_portrait.z_index = 10
	enemy_portrait_texture.z_index = 11
	_apply_scene_polish_colors()


func _add_launcher_ball_sprite() -> void:
	var path := "res://assets/balls/ball_base.png"
	if not ResourceLoader.exists(path):
		return
	var texture: Texture2D = load(path)
	if texture == null:
		return
	launcher_visual.visible = false
	_launcher_ball_sprite = Sprite2D.new()
	_launcher_ball_sprite.name = "LauncherBallArt"
	_launcher_ball_sprite.texture = texture
	_launcher_ball_sprite.centered = true
	_launcher_ball_sprite.position = launcher_position
	_launcher_ball_sprite.scale = Vector2.ONE * (36.0 / float(max(texture.get_width(), texture.get_height())))
	_launcher_ball_sprite.modulate = Color(1.0, 0.92, 0.25)
	_launcher_ball_sprite.z_index = 12
	$AimOverlay.add_child(_launcher_ball_sprite)


func _launcher_feedback_node() -> Node2D:
	return _launcher_ball_sprite if _launcher_ball_sprite != null else launcher_visual


func _add_aim_endpoint_marker() -> void:
	var preview_config: Dictionary = feel_config.get("aim_preview", {})
	_aim_endpoint_marker = Polygon2D.new()
	_aim_endpoint_marker.name = "AimEndpointMarker"
	_aim_endpoint_marker.polygon = _circle_points(float(preview_config.get("end_marker_radius", 7.0)), 18)
	_aim_endpoint_marker.color = Color(String(preview_config.get("end_marker_color", "#00E5FF")))
	_aim_endpoint_marker.z_index = 13
	_aim_endpoint_marker.visible = false
	$AimOverlay.add_child(_aim_endpoint_marker)


func _apply_scene_polish_colors() -> void:
	var hud: Dictionary = feel_config.get("hud", {})
	var label_color := Color(String(hud.get("label_color", "#E8FBFF")))
	for label in [player_hp_label, enemy_hp_label, round_label, damage_label, balls_label, launch_label, overload_label, floor_label, enemy_type_label, enemy_dialogue_label, status_label]:
		(label as Label).modulate = label_color
	player_hp_bar.modulate = Color(String(hud.get("player_color", "#46FF9B")))
	enemy_hp_bar.modulate = Color(String(hud.get("enemy_color", "#FF4E87")))
	launch_bar.modulate = Color(String(hud.get("launch_color", "#FFE66D")))
	overload_bar.modulate = Color(String(hud.get("overload_color", "#00E5FF")))


func _add_hud_panel() -> void:
	var ui_root: Control = $BattleUI/UIRoot
	var hud: Dictionary = feel_config.get("hud", {})
	var panel := ColorRect.new()
	panel.name = "ScenePolishHudPanel"
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.z_index = -20
	panel.position = _vector2_from_array(hud.get("panel_position", [16, 16]), Vector2(16, 16))
	panel.size = _vector2_from_array(hud.get("panel_size", [328, 336]), Vector2(328, 336))
	panel.color = Color(String(hud.get("panel_color", "#071019CC")))
	ui_root.add_child(panel)
	ui_root.move_child(panel, 0)
	var border := _make_rect_line("HudPanelBorder", panel.position, panel.size, Color(String(hud.get("panel_border_color", "#00E5FF88"))), 2.0)
	border.z_index = -19
	ui_root.add_child(border)
	ui_root.move_child(border, 1)
	var tick_color := Color(String(hud.get("panel_tick_color", "#9EF8FFAA")))
	for y in [64.0, 100.0, 136.0, 172.0, 248.0, 320.0]:
		var tick := Line2D.new()
		tick.name = "HudPanelTick"
		tick.width = 1.0
		tick.default_color = tick_color
		tick.points = PackedVector2Array([panel.position + Vector2(12, y), panel.position + Vector2(panel.size.x - 12, y)])
		tick.z_index = 1
		ui_root.add_child(tick)
		ui_root.move_child(tick, 2)


func _add_enemy_panel() -> void:
	var ui_root: Control = $BattleUI/UIRoot
	var config: Dictionary = feel_config.get("enemy_display", {})
	var panel := ColorRect.new()
	panel.name = "ScenePolishEnemyPanel"
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.z_index = -20
	panel.position = _vector2_from_array(config.get("panel_position", [716, 84]), Vector2(716, 84))
	panel.size = _vector2_from_array(config.get("panel_size", [292, 366]), Vector2(292, 366))
	panel.color = Color(String(config.get("panel_color", "#060B12D9")))
	ui_root.add_child(panel)
	ui_root.move_child(panel, 0)
	var border := _make_rect_line("EnemyPanelBorder", panel.position, panel.size, Color(String(config.get("border_color", "#FF2D9588"))), 2.0)
	border.z_index = -19
	ui_root.add_child(border)
	ui_root.move_child(border, 1)


func _make_rect_line(node_name: String, position: Vector2, size: Vector2, color: Color, width: float) -> Line2D:
	var line := Line2D.new()
	line.name = node_name
	line.width = width
	line.default_color = color
	line.closed = true
	line.z_index = 1
	line.points = PackedVector2Array([
		position,
		position + Vector2(size.x, 0),
		position + size,
		position + Vector2(0, size.y),
	])
	return line


func _vector2_from_array(value: Variant, fallback: Vector2) -> Vector2:
	if typeof(value) != TYPE_ARRAY:
		return fallback
	var array: Array = value
	if array.size() < 2:
		return fallback
	return Vector2(float(array[0]), float(array[1]))


func _update_enemy_idle(delta: float) -> void:
	if enemy_portrait == null:
		return
	var config: Dictionary = feel_config.get("enemy_display", {})
	_enemy_float_phase += delta * float(config.get("float_speed", 1.4))
	enemy_portrait.position = _enemy_portrait_base_position + Vector2(0.0, sin(_enemy_float_phase) * float(config.get("float_pixels", 6.0)))


func _enemy_hit_position() -> Vector2:
	if enemy_portrait == null:
		return Vector2(512, 600)
	return enemy_portrait.get_global_rect().get_center()


func _set_enemy_portrait_texture(enemy_id: String) -> bool:
	if enemy_portrait_texture == null:
		return false
	var path := "res://assets/enemies/%s.png" % enemy_id
	if not ResourceLoader.exists(path):
		enemy_portrait_texture.texture = null
		return false
	var texture: Texture2D = load(path)
	enemy_portrait_texture.texture = texture
	return texture != null


func _add_battle_background() -> void:
	var path := "res://assets/bg/battle_bg.png"
	if not ResourceLoader.exists(path):
		return
	var texture: Texture2D = load(path)
	if texture == null:
		return
	var bg := Sprite2D.new()
	bg.name = "BattleBackgroundArt"
	bg.texture = texture
	bg.centered = true
	var viewport_size := get_viewport_rect().size
	bg.position = viewport_size * 0.5
	bg.scale = Vector2(viewport_size.x / texture.get_width(), viewport_size.y / texture.get_height())
	bg.modulate = Color(1.0, 1.0, 1.0, 0.38)
	bg.z_index = -20
	add_child(bg)
	move_child(bg, 0)


func _add_hud_frames() -> void:
	var path := "res://assets/ui/bar_frame.png"
	if not ResourceLoader.exists(path):
		return
	var texture: Texture2D = load(path)
	if texture == null:
		return
	for bar in [player_hp_bar, enemy_hp_bar, launch_bar, overload_bar]:
		_add_frame_for_bar(bar, texture)


func _add_frame_for_bar(bar: ProgressBar, texture: Texture2D) -> void:
	if bar == null:
		return
	var frame := TextureRect.new()
	frame.name = "%sFrameArt" % bar.name
	frame.texture = texture
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_SCALE
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.modulate = Color(1.0, 1.0, 1.0, 0.55)
	frame.position = bar.position - Vector2(8, 7)
	frame.size = bar.size + Vector2(16, 14)
	var parent := bar.get_parent()
	parent.add_child(frame)
	parent.move_child(frame, bar.get_index())


func _spawn_pegs() -> void:
	field_generator.configure(field_config["generator"])
	dynamic_peg_cells = field_generator.build_dynamic_cells(field_config)
	for cell in dynamic_peg_cells:
		var peg := PEG_SCENE.instantiate()
		peg_container.add_child(peg)
		peg.position = Vector2(float(cell["x"]), float(cell["y"]))
		dynamic_peg_nodes.append(peg)

	for cell in field_generator.build_bottom_cells(field_config):
		var peg_id := String((cell as Dictionary)["id"])
		var peg := PEG_SCENE.instantiate()
		peg_container.add_child(peg)
		peg.position = Vector2(float((cell as Dictionary)["x"]), float((cell as Dictionary)["y"]))
		peg.configure(peg_id, DataLoader.get_peg(peg_id), float(cell["radius"]), feel_config)
		bottom_peg_nodes.append(peg)


func _reroll_dynamic_pegs() -> void:
	var weight_multiplier := _overload_weight_multiplier()
	var rolled_cells: Array = field_generator.roll_dynamic_types(field_config, dynamic_peg_cells, RunState.guaranteed_double_peg_count, weight_multiplier)
	var reroll_flash: Dictionary = feel_config.get("reroll_flash", {})
	var stagger := float(reroll_flash.get("stagger_seconds", 0.004))
	if RunState.is_overload_active():
		stagger *= float(overload_config.get("presentation", {}).get("reroll_stagger_multiplier", 1.0))
	for index in range(min(dynamic_peg_nodes.size(), rolled_cells.size())):
		var cell := rolled_cells[index] as Dictionary
		var peg := dynamic_peg_nodes[index]
		var peg_id := String(cell["id"])
		peg.configure(peg_id, DataLoader.get_peg(peg_id), float(cell["radius"]), feel_config)
		battle_fx.flash_reroll_peg(peg, float(index) * stagger)


func _transition_to(next_state: BattleState, message := "") -> void:
	if _execute_in_progress and next_state not in [BattleState.CHECK, BattleState.REWARD, BattleState.GAME_OVER, BattleState.VICTORY]:
		return
	state = next_state
	match state:
		BattleState.ROUND_START:
			await _begin_round()
		BattleState.AIMING:
			status_label.text = "算好角度後點擊 / 空白鍵發射"
		BattleState.SETTLE:
			await _settle_round()
		BattleState.ENEMY_TURN:
			await _enemy_turn()
		BattleState.CHECK:
			await _check_battle_end()
		BattleState.REWARD:
			_advance_to_next_battle()
		BattleState.GAME_OVER:
			SceneTransition.change_scene("res://Scenes/GameOver.tscn")
		BattleState.VICTORY:
			SceneTransition.change_scene("res://Scenes/Victory.tscn")


func _begin_round() -> void:
	round_index += 1
	_execute_in_progress = false
	_overload_triggered_this_round = false
	if RunState.should_force_overload(overload_config):
		_trigger_overload(true)
	_overload_active_this_round = RunState.is_overload_active()
	battle_fx.set_overload_active_visual(_overload_active_this_round)
	if bool(field_config["generator"].get("reroll_each_round", true)) or round_index == 1:
		_reroll_dynamic_pegs()
	round_context.start_round(RunState.balls_per_round)
	await _wait_pacing("round_start_delay")
	await battle_fx.show_turn_banner("你的回合", Color(0.0, 0.92, 1.0))
	await _transition_to(BattleState.AIMING)


func _handle_launch_input() -> void:
	if _execute_in_progress:
		return
	_fire_ball()


func _fire_ball() -> void:
	if _execute_in_progress:
		return
	if round_context.balls_remaining <= 0:
		return

	var launch_speed := _fixed_launch_speed()
	var launch_direction := _aim_direction()
	var ball := BALL_SCENE.instantiate()
	var ball_id := _ball_id_for_next_launch()
	var ball_def := DataLoader.get_ball(ball_id)
	ball_container.add_child(ball)
	ball.position = launcher_position
	ball.configure(ball_id, ball_def, player_config, feel_config, field_config)
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
	battle_fx.spawn_launch_feedback(launcher_position)
	battle_fx.play_launcher_recoil(_launcher_feedback_node(), launch_direction)
	battle_fx.play_sfx("launch", 1.08)
	ball.launch(launch_direction, launch_speed)
	_update_ui()


func _ball_id_for_next_launch() -> String:
	if RunState.unlocked_balls.is_empty():
		return String(player_config["starting_ball_id"])
	var launched_this_round: int = RunState.balls_per_round - int(round_context.balls_remaining)
	return String(RunState.unlocked_balls[launched_this_round % RunState.unlocked_balls.size()])


func _aim_direction() -> Vector2:
	var direction := get_global_mouse_position() - launcher_position
	if direction.length() <= 0.01:
		return Vector2.DOWN
	if direction.y < 0.2:
		direction.y = 0.2
	return direction.normalized()


func _update_aim_overlay() -> void:
	launcher_visual.visible = _launcher_ball_sprite == null
	var is_aiming := state == BattleState.AIMING
	if is_aiming:
		var points := _aim_trajectory_points()
		var preview_config: Dictionary = feel_config.get("aim_preview", {})
		if bool(preview_config.get("dashed", false)):
			aim_line.visible = false
			_update_aim_dash_segments(points, preview_config)
		else:
			_hide_aim_dash_segments()
			aim_line.visible = true
			aim_line.points = points
			aim_line.width = float(preview_config.get("line_width", aim_line.width))
			aim_line.default_color = Color(String(preview_config.get("line_color", "#FFE66D")))
		_update_aim_endpoint_marker(points, preview_config)
	else:
		aim_line.visible = false
		_hide_aim_dash_segments()
		if _aim_endpoint_marker != null:
			_aim_endpoint_marker.visible = false


func _update_aim_dash_segments(points: PackedVector2Array, preview_config: Dictionary) -> void:
	var segment_count: int = max(0, points.size() - 1)
	_ensure_aim_dash_segment_count(segment_count)
	var color := Color(String(preview_config.get("line_color", "#FFE66D88")))
	var width := float(preview_config.get("line_width", 3.0))
	for index in range(_aim_dash_segments.size()):
		var segment := _aim_dash_segments[index]
		var visible := index < segment_count and index % 2 == 0
		segment.visible = visible
		if visible:
			segment.points = PackedVector2Array([points[index], points[index + 1]])
			segment.width = width
			segment.default_color = color


func _ensure_aim_dash_segment_count(count: int) -> void:
	while _aim_dash_segments.size() < count:
		var segment := Line2D.new()
		segment.name = "AimDashSegment"
		segment.z_index = 11
		segment.joint_mode = Line2D.LINE_JOINT_ROUND
		segment.begin_cap_mode = Line2D.LINE_CAP_ROUND
		segment.end_cap_mode = Line2D.LINE_CAP_ROUND
		$AimOverlay.add_child(segment)
		_aim_dash_segments.append(segment)


func _hide_aim_dash_segments() -> void:
	for segment in _aim_dash_segments:
		segment.visible = false


func _update_aim_endpoint_marker(points: PackedVector2Array, preview_config: Dictionary) -> void:
	if _aim_endpoint_marker == null:
		return
	if points.is_empty():
		_aim_endpoint_marker.visible = false
		return
	var radius := float(preview_config.get("end_marker_radius", 7.0))
	_aim_endpoint_marker.polygon = _circle_points(radius, 18)
	_aim_endpoint_marker.color = Color(String(preview_config.get("end_marker_color", "#00E5FF")))
	_aim_endpoint_marker.position = points[points.size() - 1]
	var pulse_speed := float(preview_config.get("end_marker_pulse_speed", 5.0))
	var pulse_scale := float(preview_config.get("end_marker_pulse_scale", 0.12))
	var pulse := 1.0 + sin(Time.get_ticks_msec() * 0.001 * pulse_speed) * pulse_scale
	_aim_endpoint_marker.scale = Vector2.ONE * pulse
	_aim_endpoint_marker.visible = true


func _circle_points(radius: float, point_count: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	var safe_count: int = max(6, point_count)
	for index in range(safe_count):
		var angle := TAU * float(index) / float(safe_count)
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	return points


func _fixed_launch_speed() -> float:
	return max(1.0, float(player_config.get("launch_speed", 1.0)))


func _aim_trajectory_points() -> PackedVector2Array:
	var preview_config: Dictionary = feel_config.get("aim_preview", {})
	var point_count: int = max(2, int(preview_config.get("point_count", 18)))
	var time_step: float = max(0.01, float(preview_config.get("time_step", 0.06)))
	var velocity := _aim_direction() * _aim_preview_speed()
	var gravity := Vector2.DOWN * float(ProjectSettings.get_setting("physics/2d/default_gravity")) * float(player_config.get("ball_gravity_scale", 1.0))
	var points := PackedVector2Array()
	for index in range(point_count):
		var time: float = float(index) * time_step
		points.append(launcher_position + velocity * time + gravity * 0.5 * time * time)
	return points


func _aim_preview_speed() -> float:
	return _fixed_launch_speed()


func _on_ball_peg_hit(peg_id: String, hit_position: Vector2, hit_color: Color, combo_count: int) -> void:
	if _execute_in_progress:
		return
	var peg_feel: Dictionary = battle_fx.peg_feedback_config(peg_id)
	var peg_def := RunState.get_modified_peg_def(DataLoader.get_peg(peg_id))
	var damage_multiplier := _overload_damage_multiplier()
	var result: Dictionary = effect_resolver.apply_peg_effect(peg_def, round_context, damage_multiplier)
	_apply_overload_charge(peg_id)
	var message := String(result.get("message", ""))
	if not message.is_empty():
		status_label.text = message
	var damage_added := int(result.get("damage_added", 0))
	var heal_added := int(result.get("heal_added", 0))
	var multiplier_applied := bool(result.get("multiplier_applied", false))
	var feedback_text := String(result.get("feedback_text", ""))
	if damage_added > 0:
		battle_fx.show_floating_text(feedback_text, hit_position, hit_color)
	if heal_added > 0:
		battle_fx.show_floating_text(feedback_text, hit_position, Color(0.22, 1.0, 0.08))
	if multiplier_applied:
		battle_fx.show_floating_text(feedback_text, hit_position, Color(1.0, 0.78, 0.24))
	battle_fx.spawn_hit_particles(hit_position, hit_color, combo_count, float(peg_feel.get("particle_scale", 1.0)))
	battle_fx.show_combo_feedback(combo_count, hit_position)
	battle_fx.start_hit_shake(float(peg_feel.get("shake_mult", 1.0)))
	battle_fx.apply_hitstop(float(peg_feel.get("hitstop_mult", 1.0)))
	var combo_config: Dictionary = feel_config.get("combo", {})
	var round_heat_config: Dictionary = feel_config.get("round_heat", {})
	var heat_pitch_bonus := _round_heat_ratio() * float(round_heat_config.get("sfx_pitch_bonus", 0.0))
	var overload_pitch_bonus := float(overload_config.get("sfx", {}).get("active_hit_pitch_bonus", 0.0)) if RunState.is_overload_active() else 0.0
	var pitch_scale := (1.0 + overload_pitch_bonus + heat_pitch_bonus + float(max(combo_count - 1, 0)) * float(combo_config.get("sfx_pitch_step", 0.06))) * float(peg_feel.get("sfx_pitch_mult", 1.0))
	battle_fx.play_sfx("hit", pitch_scale)
	_update_ui()
	_try_trigger_execute()


func _on_ball_wall_hit(_hit_position: Vector2) -> void:
	battle_fx.play_sfx("wall")


func _on_ball_recovered(ball: RigidBody2D, reason: String) -> void:
	var hit_count := 0
	if ball != null and ball.has_method("get_combo_hits"):
		hit_count = int(ball.get_combo_hits())
	round_context.balls_in_play = max(0, round_context.balls_in_play - 1)
	if _execute_in_progress:
		return
	status_label.text = "球已回收：%s" % reason
	var drain_config: Dictionary = feel_config.get("drain", {})
	if hit_count <= int(drain_config.get("miss_hit_threshold", 1)):
		battle_fx.show_miss_feedback(Vector2(launcher_position.x, 900))
	battle_fx.play_sfx("drop")
	if round_context.balls_in_play > 0:
		return
	if round_context.balls_remaining > 0:
		_transition_to(BattleState.AIMING)
	else:
		await _transition_to(BattleState.SETTLE)


func _on_bottom_sensor_body_entered(body: Node) -> void:
	if body.has_method("recover"):
		body.recover("bottom")


func _settle_round() -> void:
	if _execute_in_progress:
		return
	await _wait_pacing("settle_pre_delay")
	var settlement: Dictionary = effect_resolver.apply_settlement_effects(round_context)
	var bonus_damage := int(settlement.get("bonus_damage", 0))
	var heal_amount := int(settlement.get("heal_amount", 0))
	if heal_amount > 0:
		RunState.heal_player(heal_amount)
	if not _overload_triggered_this_round:
		RunState.record_overload_miss_round(overload_config)
	round_context.mark_settled()
	var previous_enemy_hp: int = enemy_hp
	var next_enemy_hp: int = max(0, enemy_hp - round_context.damage_accumulator)
	status_label.text = "結算 %s 傷害" % round_context.damage_accumulator
	if bonus_damage > 0:
		status_label.text += "（Blast +%s）" % bonus_damage
	if heal_amount > 0:
		status_label.text += "，回復 %s HP" % heal_amount
	_settlement_animating = true
	await battle_fx.play_player_attack(launcher_position, _enemy_hit_position(), round_context.damage_accumulator, enemy_max_hp, RunState.is_overload_active())
	await battle_fx.animate_settlement(damage_label, enemy_hp_bar, round_context.damage_accumulator, previous_enemy_hp, next_enemy_hp)
	_settlement_animating = false
	enemy_hp = next_enemy_hp
	_last_enemy_hp = enemy_hp
	battle_fx.show_floating_text("TOTAL %s" % round_context.damage_accumulator, Vector2(launcher_position.x, 610), Color(1.0, 0.9, 0.35))
	await battle_fx.flash_enemy_hit(enemy_portrait)
	battle_fx.play_sfx("settle")
	await _wait_pacing("settle_post_delay")
	_finish_overload_round()
	await _transition_to(BattleState.CHECK)


func _try_trigger_execute() -> void:
	if _execute_in_progress or enemy_hp <= 0:
		return
	var execute_config: Dictionary = player_config.get("execute", {})
	if not bool(execute_config.get("enabled", true)):
		return
	var margin := int(execute_config.get("margin", 0))
	if round_context.damage_accumulator < enemy_hp + margin:
		return
	call_deferred("_begin_execute_clear")


func _begin_execute_clear() -> void:
	if _execute_in_progress:
		return
	_execute_in_progress = true
	state = BattleState.SETTLE
	round_context.balls_remaining = 0
	status_label.text = "強制清除序列啟動"
	for child in ball_container.get_children():
		if child != null and child.has_method("recover"):
			child.recover("execute")
	round_context.balls_in_play = 0
	if round_context.pending_heal > 0:
		RunState.heal_player(round_context.pending_heal)
	if not _overload_triggered_this_round:
		RunState.record_overload_miss_round(overload_config)
	round_context.mark_settled()
	var previous_enemy_hp := enemy_hp
	var resolved_damage: int = max(int(round_context.damage_accumulator), previous_enemy_hp)
	await battle_fx.show_overkill_cutin()
	await battle_fx.play_player_attack(launcher_position, _enemy_hit_position(), resolved_damage, enemy_max_hp, RunState.is_overload_active())
	_settlement_animating = true
	await battle_fx.animate_settlement(damage_label, enemy_hp_bar, resolved_damage, previous_enemy_hp, 0)
	_settlement_animating = false
	enemy_hp = 0
	_last_enemy_hp = enemy_hp
	battle_fx.show_floating_text("OVERKILL %s" % resolved_damage, Vector2(launcher_position.x, 610), Color(1.0, 0.92, 0.34))
	await battle_fx.flash_enemy_hit(enemy_portrait)
	battle_fx.play_sfx("settle", 1.12)
	_finish_overload_round()
	_execute_in_progress = false
	await _transition_to(BattleState.CHECK)


func _enemy_turn() -> void:
	await _wait_pacing("enemy_turn_pre_delay")
	var attack_info := _enemy_attack_value()
	if bool(attack_info.get("special", false)):
		await battle_fx.show_boss_telegraph()
	await battle_fx.show_turn_banner("敵人回合", Color(1.0, 0.2, 0.28))
	await battle_fx.play_enemy_windup(enemy_portrait)
	var attack_config: Dictionary = feel_config.get("enemy_attack", {})
	await get_tree().create_timer(float(attack_config.get("impact_seconds", 0.12))).timeout
	var base_attack := int(attack_info["attack"])
	var attack: int = effect_resolver.resolve_enemy_attack(base_attack, round_context)
	RunState.damage_player(attack)
	round_context.enemy_acted_this_settlement = true
	status_label.text = "%s，玩家 -%s HP" % [String(attack_info["message"]), attack]
	if attack < base_attack:
		status_label.text += "（Shield 減免）"
	battle_fx.show_floating_text("-%s HP" % attack, Vector2(132, 48), Color(1.0, 0.2, 0.2))
	battle_fx.flash_player_hit()
	battle_fx.start_enemy_attack_shake()
	battle_fx.play_sfx("enemy_attack")
	await battle_fx.play_enemy_recover(enemy_portrait)
	await _wait_pacing("enemy_turn_post_delay")
	await _transition_to(BattleState.CHECK)


func _enemy_attack_value() -> Dictionary:
	if String(enemy_def.get("type", "")) == "boss" and enemy_def.has("special"):
		var special: Dictionary = enemy_def["special"]
		var every_n_rounds := int(special.get("every_n_rounds", 3))
		if every_n_rounds > 0 and round_index % every_n_rounds == 0:
			return {
				"attack": RunState.get_modified_enemy_attack(int(special.get("attack", enemy_def["attack"]))),
				"message": "%s 施放 %s" % [String(enemy_def["name"]), String(special.get("name", "強攻擊"))],
				"special": true,
			}
	return {
		"attack": RunState.get_modified_enemy_attack(int(enemy_def["attack"])),
		"message": "%s 反擊" % String(enemy_def["name"]),
		"special": false,
	}


func _check_battle_end() -> void:
	await _wait_pacing("check_delay")
	if RunState.is_player_dead():
		await _transition_to(BattleState.GAME_OVER)
		return
	if enemy_hp <= 0:
		RunState.kills += 1
		if String(enemy_def.get("type", "")) == "boss" or RunState.current_battle_index >= DataLoader.enemies.size() - 1:
			await _transition_to(BattleState.VICTORY)
		else:
			await _transition_to(BattleState.REWARD)
		return
	if not round_context.enemy_acted_this_settlement:
		await _transition_to(BattleState.ENEMY_TURN)
	else:
		await _transition_to(BattleState.ROUND_START)


func _advance_to_next_battle() -> void:
	RunState.pending_upgrade_enemy_type = String(enemy_def.get("type", "normal"))
	status_label.text = "選擇升級"
	SceneTransition.change_scene("res://Scenes/UpgradeScreen.tscn")


func _update_ui() -> void:
	if player_hp_label == null:
		return
	player_hp_label.text = "玩家 HP：%s / %s" % [RunState.player_hp, RunState.player_max_hp]
	enemy_hp_label.text = "%s\nHP：%s / %s" % [String(enemy_def.get("name", "")), enemy_hp, enemy_max_hp]
	round_label.text = "回合：%s" % round_index
	if not _settlement_animating:
		damage_label.text = "本回合傷害：%s" % round_context.damage_accumulator
	balls_label.text = "剩餘球：%s｜場上球：%s" % [round_context.balls_remaining, round_context.balls_in_play]
	var fixed_speed := _fixed_launch_speed()
	launch_label.text = "固定初速：%s｜單鍵發射" % int(round(fixed_speed))
	launch_bar.max_value = fixed_speed
	launch_bar.value = fixed_speed
	battle_fx.update_overload_gauge(
		overload_bar,
		overload_label,
		field_border,
		RunState.get_overload_charge_ratio(overload_config),
		RunState.overload_rounds_remaining,
		get_process_delta_time()
	)
	battle_fx.update_round_heat(field_border, damage_label, round_context.damage_accumulator, enemy_max_hp, get_process_delta_time())
	sfx_toggle_button.text = "SFX: %s" % ("ON" if sfx_enabled else "OFF")
	if not _settlement_animating:
		_update_hp_bars()


func _update_hp_bars() -> void:
	player_hp_bar.max_value = RunState.player_max_hp
	enemy_hp_bar.max_value = enemy_max_hp
	if _last_player_hp != RunState.player_hp:
		_tween_bar(player_hp_bar, RunState.player_hp)
		_last_player_hp = RunState.player_hp
	if _last_enemy_hp != enemy_hp:
		_tween_bar(enemy_hp_bar, enemy_hp)
		_last_enemy_hp = enemy_hp


func _tween_bar(bar: ProgressBar, value: int) -> void:
	var duration := float(feel_config["hp_tween_duration"])
	var tween := create_tween()
	tween.tween_property(bar, "value", value, duration)


func _round_heat_ratio() -> float:
	var config: Dictionary = feel_config.get("round_heat", {})
	if not bool(config.get("enabled", true)):
		return 0.0
	var reference: float = max(1.0, float(enemy_max_hp) * float(config.get("reference_ratio", 1.0)))
	return clamp(float(round_context.damage_accumulator) / reference, 0.0, 1.0)


func _on_sfx_toggle_pressed() -> void:
	sfx_enabled = not sfx_enabled
	battle_fx.set_sfx_enabled(sfx_enabled)
	_update_ui()


func _on_restart_pressed() -> void:
	RunState.reset_new_run()
	SceneTransition.reload_current_scene()


func _on_menu_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/MainMenu.tscn")


func _wait_pacing(key: String) -> void:
	var pacing: Dictionary = feel_config.get("turn_pacing", {})
	var seconds := float(pacing.get(key, 0.0))
	if seconds > 0.0:
		await get_tree().create_timer(seconds).timeout


func _overload_weight_multiplier() -> Dictionary:
	if RunState.is_overload_active():
		return overload_config.get("overload_weight_multiplier", {})
	return {}


func _overload_damage_multiplier() -> float:
	if RunState.is_overload_active():
		return float(overload_config.get("overload_damage_multiplier", 1.0))
	return 1.0


func _apply_overload_charge(peg_id: String) -> void:
	if _overload_triggered_this_round or RunState.is_overload_active():
		return
	var charge_per_hit: Dictionary = overload_config.get("charge_per_hit", {})
	var charge := int(charge_per_hit.get(peg_id, 0))
	var reached := RunState.add_overload_charge(charge, overload_config)
	var ratio := RunState.get_overload_charge_ratio(overload_config)
	battle_fx.show_overload_tier_feedback(ratio)
	if reached:
		_trigger_overload(false)


func _trigger_overload(forced: bool) -> void:
	if RunState.trigger_overload(overload_config):
		_overload_triggered_this_round = true
		_overload_active_this_round = true
		status_label.text = "OVERCLOCK 啟動"
		battle_fx.set_overload_active_visual(true)
		battle_fx.show_overload_trigger(forced)


func _finish_overload_round() -> void:
	if not _overload_active_this_round:
		return
	var ended := RunState.consume_overload_round()
	if ended:
		_overload_active_this_round = false
		battle_fx.set_overload_active_visual(false)

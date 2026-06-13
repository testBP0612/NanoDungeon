extends Node2D

enum BattleState { INIT, ROUND_START, AIMING, LAUNCHED, SETTLE, ENEMY_TURN, CHECK, ENDED }

const BALL_SCENE := preload("res://Scenes/Ball.tscn")
const PEG_SCENE := preload("res://Scenes/Peg.tscn")

var state := BattleState.INIT
var player_config: Dictionary = {}
var normal_peg_def: Dictionary = {}
var normal_ball_def: Dictionary = {}
var enemy_def: Dictionary = {}
var enemy_hp := 0
var enemy_max_hp := 0
var round_index := 0
var round_damage := 0
var last_settled_damage := 0
var enemy_acted_this_settlement := false
var balls_remaining := 0
var balls_in_play := 0
var launcher_position := Vector2(512, 118)

var field: Node2D
var peg_container: Node2D
var ball_container: Node2D
var bottom_sensor: Area2D
var ui_root: Control
var player_hp_label: Label
var enemy_hp_label: Label
var round_label: Label
var damage_label: Label
var balls_label: Label
var status_label: Label
var restart_button: Button
var menu_button: Button


func _ready() -> void:
	RunState.ensure_run_started()
	_load_definitions()
	_build_field()
	_build_ui()
	_spawn_pegs()
	enemy_hp = int(enemy_def["hp"])
	enemy_max_hp = enemy_hp
	_transition_to(BattleState.ROUND_START)


func _process(_delta: float) -> void:
	_update_ui()
	queue_redraw()


func _input(event: InputEvent) -> void:
	if state != BattleState.AIMING:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_fire_ball()


func _draw() -> void:
	draw_rect(Rect2(Vector2(196, 72), Vector2(632, 608)), Color(0.055, 0.065, 0.095), true)
	draw_rect(Rect2(Vector2(196, 72), Vector2(632, 608)), Color(0.25, 0.95, 1.0), false, 2.0)
	draw_circle(launcher_position, 13.0, Color(0.9, 0.25, 1.0))

	if state == BattleState.AIMING:
		var direction := _aim_direction()
		draw_line(launcher_position, launcher_position + direction * 115.0, Color(1.0, 0.9, 0.35), 3.0)


func _load_definitions() -> void:
	if not DataLoader.loaded:
		DataLoader.load_all()
	player_config = DataLoader.get_player_config()
	normal_peg_def = DataLoader.get_peg("normal_peg")
	normal_ball_def = DataLoader.get_ball(String(player_config["starting_ball_id"]))
	enemy_def = DataLoader.get_enemy(RunState.current_battle_index)


func _build_field() -> void:
	field = Node2D.new()
	field.name = "PinballField"
	add_child(field)

	var walls := Node2D.new()
	walls.name = "Walls"
	field.add_child(walls)
	_add_wall(walls, "LeftWall", Vector2(176, 376), Vector2(40, 608))
	_add_wall(walls, "RightWall", Vector2(848, 376), Vector2(40, 608))
	_add_wall(walls, "TopWall", Vector2(512, 52), Vector2(672, 40))

	peg_container = Node2D.new()
	peg_container.name = "PegContainer"
	field.add_child(peg_container)

	bottom_sensor = Area2D.new()
	bottom_sensor.name = "BottomSensor"
	bottom_sensor.position = Vector2(512, 706)
	var bottom_shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(632, 52)
	bottom_shape.shape = rect
	bottom_sensor.add_child(bottom_shape)
	bottom_sensor.body_entered.connect(_on_bottom_sensor_body_entered)
	field.add_child(bottom_sensor)

	var launcher := Node2D.new()
	launcher.name = "Launcher"
	launcher.position = launcher_position
	field.add_child(launcher)

	ball_container = Node2D.new()
	ball_container.name = "BallContainer"
	field.add_child(ball_container)


func _build_ui() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "BattleUI"
	add_child(canvas)

	ui_root = Control.new()
	ui_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(ui_root)

	player_hp_label = _make_label(Vector2(24, 24), Vector2(240, 28), 18)
	enemy_hp_label = _make_label(Vector2(24, 56), Vector2(360, 28), 18)
	round_label = _make_label(Vector2(24, 88), Vector2(220, 28), 18)
	damage_label = _make_label(Vector2(24, 120), Vector2(260, 28), 18)
	balls_label = _make_label(Vector2(24, 152), Vector2(260, 28), 18)
	status_label = _make_label(Vector2(260, 698), Vector2(504, 36), 20)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	restart_button = Button.new()
	restart_button.text = "重來"
	restart_button.position = Vector2(382, 356)
	restart_button.size = Vector2(120, 42)
	restart_button.mouse_filter = Control.MOUSE_FILTER_STOP
	restart_button.visible = false
	restart_button.pressed.connect(_on_restart_pressed)
	ui_root.add_child(restart_button)

	menu_button = Button.new()
	menu_button.text = "主選單"
	menu_button.position = Vector2(522, 356)
	menu_button.size = Vector2(120, 42)
	menu_button.mouse_filter = Control.MOUSE_FILTER_STOP
	menu_button.visible = false
	menu_button.pressed.connect(_on_menu_pressed)
	ui_root.add_child(menu_button)


func _make_label(position: Vector2, size: Vector2, font_size: int) -> Label:
	var label := Label.new()
	label.position = position
	label.size = size
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	ui_root.add_child(label)
	return label


func _add_wall(parent: Node, wall_name: String, position: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.name = wall_name
	body.position = position

	var collision := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	collision.shape = rect
	body.add_child(collision)

	var visual := Polygon2D.new()
	visual.color = Color(0.09, 0.14, 0.2)
	visual.polygon = PackedVector2Array([
		Vector2(-size.x * 0.5, -size.y * 0.5),
		Vector2(size.x * 0.5, -size.y * 0.5),
		Vector2(size.x * 0.5, size.y * 0.5),
		Vector2(-size.x * 0.5, size.y * 0.5),
	])
	body.add_child(visual)
	parent.add_child(body)


func _spawn_pegs() -> void:
	var positions := [
		Vector2(370, 230),
		Vector2(512, 230),
		Vector2(654, 230),
		Vector2(440, 340),
		Vector2(584, 340),
		Vector2(370, 455),
		Vector2(512, 455),
		Vector2(654, 455),
	]

	for peg_position in positions:
		var peg := PEG_SCENE.instantiate()
		peg_container.add_child(peg)
		peg.position = peg_position
		peg.configure("normal_peg", normal_peg_def)


func _transition_to(next_state: BattleState) -> void:
	state = next_state
	match state:
		BattleState.ROUND_START:
			_begin_round()
		BattleState.SETTLE:
			_settle_round()
		BattleState.ENEMY_TURN:
			_enemy_turn()
		BattleState.CHECK:
			_check_battle_end()


func _begin_round() -> void:
	round_index += 1
	round_damage = 0
	last_settled_damage = 0
	balls_remaining = RunState.balls_per_round
	balls_in_play = 0
	status_label.text = "瞄準後點擊發射"
	_transition_to(BattleState.AIMING)


func _fire_ball() -> void:
	if balls_remaining <= 0:
		return

	var ball := BALL_SCENE.instantiate()
	ball_container.add_child(ball)
	ball.position = launcher_position
	ball.configure(String(player_config["starting_ball_id"]), normal_ball_def, player_config)
	ball.peg_hit.connect(_on_ball_peg_hit)
	ball.recovered.connect(_on_ball_recovered)

	balls_remaining -= 1
	balls_in_play += 1
	status_label.text = "球飛行中"
	state = BattleState.LAUNCHED
	ball.launch(_aim_direction())
	_update_ui()


func _aim_direction() -> Vector2:
	var direction := get_global_mouse_position() - launcher_position
	if direction.length() <= 0.01:
		return Vector2.DOWN
	if direction.y < 0.2:
		direction.y = 0.2
	return direction.normalized()


func _on_ball_peg_hit(peg_id: String) -> void:
	var peg_def := DataLoader.get_peg(peg_id)
	if String(peg_def.get("effect_type", "")) != "damage":
		return
	var hit_damage := int(peg_def["base_damage"])
	round_damage += hit_damage
	status_label.text = "命中 %s，+%s 傷害" % [String(peg_def["name"]), hit_damage]
	_update_ui()


func _on_ball_recovered(_ball: RigidBody2D, reason: String) -> void:
	balls_in_play = max(0, balls_in_play - 1)
	status_label.text = "球已回收：%s" % reason
	if balls_in_play > 0:
		return
	if balls_remaining > 0:
		_transition_to(BattleState.AIMING)
	else:
		_transition_to(BattleState.SETTLE)


func _on_bottom_sensor_body_entered(body: Node) -> void:
	if body.has_method("recover"):
		body.recover("bottom")


func _settle_round() -> void:
	last_settled_damage = round_damage
	enemy_acted_this_settlement = false
	enemy_hp = max(0, enemy_hp - round_damage)
	status_label.text = "結算 %s 傷害" % round_damage
	_transition_to(BattleState.CHECK)


func _enemy_turn() -> void:
	var attack := int(enemy_def["attack"])
	RunState.damage_player(attack)
	enemy_acted_this_settlement = true
	status_label.text = "%s 反擊，玩家 -%s HP" % [String(enemy_def["name"]), attack]
	_transition_to(BattleState.CHECK)


func _check_battle_end() -> void:
	if enemy_hp <= 0:
		RunState.kills += 1
		_end_battle("敵人已擊破")
		return
	if RunState.is_player_dead():
		_end_battle("玩家 HP 歸零")
		return
	if not enemy_acted_this_settlement:
		_transition_to(BattleState.ENEMY_TURN)
	else:
		_transition_to(BattleState.ROUND_START)


func _end_battle(message: String) -> void:
	state = BattleState.ENDED
	status_label.text = message
	restart_button.visible = true
	menu_button.visible = true


func _update_ui() -> void:
	if player_hp_label == null:
		return
	player_hp_label.text = "玩家 HP：%s / %s" % [RunState.player_hp, RunState.player_max_hp]
	enemy_hp_label.text = "敵人 HP：%s / %s  %s" % [enemy_hp, enemy_max_hp, String(enemy_def.get("name", ""))]
	round_label.text = "回合：%s" % round_index
	damage_label.text = "本回合傷害：%s" % round_damage
	balls_label.text = "剩餘球：%s｜場上球：%s" % [balls_remaining, balls_in_play]


func _on_restart_pressed() -> void:
	RunState.reset_new_run()
	get_tree().reload_current_scene()


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

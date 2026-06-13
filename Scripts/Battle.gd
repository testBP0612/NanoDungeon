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
var round_context: RefCounted = ROUND_CONTEXT_SCRIPT.new()
var effect_resolver: RefCounted = EFFECT_RESOLVER_SCRIPT.new()

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


func _process(_delta: float) -> void:
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
	enemy_def = DataLoader.get_enemy(RunState.current_battle_index)


func _connect_scene_nodes() -> void:
	bottom_sensor.body_entered.connect(_on_bottom_sensor_body_entered)
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	launcher_visual.position = launcher_position


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
	ball_container.add_child(ball)
	ball.position = launcher_position
	ball.configure(String(player_config["starting_ball_id"]), normal_ball_def, player_config)
	ball.peg_hit.connect(_on_ball_peg_hit)
	ball.recovered.connect(_on_ball_recovered)

	round_context.balls_remaining -= 1
	round_context.balls_in_play += 1
	status_label.text = "球飛行中"
	_transition_to(BattleState.LAUNCHED)
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


func _on_ball_peg_hit(peg_id: String) -> void:
	var peg_def := DataLoader.get_peg(peg_id)
	var result: Dictionary = effect_resolver.apply_peg_effect(peg_def, round_context)
	var message := String(result.get("message", ""))
	if not message.is_empty():
		status_label.text = message
	_update_ui()


func _on_ball_recovered(_ball: RigidBody2D, reason: String) -> void:
	round_context.balls_in_play = max(0, round_context.balls_in_play - 1)
	status_label.text = "球已回收：%s" % reason
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
	round_context.mark_settled()
	enemy_hp = max(0, enemy_hp - round_context.damage_accumulator)
	status_label.text = "結算 %s 傷害" % round_context.damage_accumulator
	_transition_to(BattleState.CHECK)


func _enemy_turn() -> void:
	var attack := int(enemy_def["attack"])
	RunState.damage_player(attack)
	round_context.enemy_acted_this_settlement = true
	status_label.text = "%s 反擊，玩家 -%s HP" % [String(enemy_def["name"]), attack]
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


func _on_restart_pressed() -> void:
	RunState.reset_new_run()
	get_tree().reload_current_scene()


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

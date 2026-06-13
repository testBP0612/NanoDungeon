extends Node2D

enum BattleState { INIT, ROUND_START, AIMING, LAUNCHED, SETTLE, ENEMY_TURN, CHECK, REWARD, GAME_OVER, VICTORY }

const BALL_SCENE := preload("res://Scenes/Ball.tscn")
const PEG_SCENE := preload("res://Scenes/Peg.tscn")
const ROUND_CONTEXT_SCRIPT := preload("res://Scripts/RoundContext.gd")
const EFFECT_RESOLVER_SCRIPT := preload("res://Scripts/EffectResolver.gd")
const FIELD_GENERATOR_SCRIPT := preload("res://Scripts/FieldGenerator.gd")

var state := BattleState.INIT
var player_config: Dictionary = {}
var feel_config: Dictionary = {}
var enemy_def: Dictionary = {}
var enemy_hp := 0
var enemy_max_hp := 0
var round_index := 0
var launcher_position := Vector2(512, 118)
var sfx_enabled := true
var _last_player_hp := -1
var _last_enemy_hp := -1
var field_config: Dictionary = {}
var dynamic_peg_slots: Array = []
var dynamic_peg_nodes: Array[Node] = []
var bottom_peg_nodes: Array[Node] = []
var round_context: RefCounted = ROUND_CONTEXT_SCRIPT.new()
var effect_resolver: RefCounted = EFFECT_RESOLVER_SCRIPT.new()
var field_generator: RefCounted = FIELD_GENERATOR_SCRIPT.new()

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
@onready var floor_label: Label = $BattleUI/UIRoot/FloorLabel
@onready var enemy_type_label: Label = $BattleUI/UIRoot/EnemyTypeLabel
@onready var enemy_dialogue_label: Label = $BattleUI/UIRoot/EnemyDialogueLabel
@onready var enemy_portrait: ColorRect = $BattleUI/UIRoot/EnemyPortrait
@onready var status_label: Label = $BattleUI/UIRoot/StatusLabel
@onready var sfx_toggle_button: Button = $BattleUI/UIRoot/SfxToggleButton
@onready var restart_button: Button = $BattleUI/UIRoot/RestartButton
@onready var menu_button: Button = $BattleUI/UIRoot/MenuButton


func _ready() -> void:
	RunState.ensure_run_started()
	_load_definitions()
	_connect_scene_nodes()
	_spawn_pegs()
	_load_enemy_from_run_state()
	_transition_to(BattleState.ROUND_START)


func _process(delta: float) -> void:
	battle_fx.update(delta)
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
	feel_config = DataLoader.get_feel_config()
	field_config = DataLoader.get_field_config()
	sfx_enabled = bool(feel_config["sfx"]["enabled"])


func _connect_scene_nodes() -> void:
	battle_fx.configure(battle_camera, $BattleUI/UIRoot, feel_config)
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
	match enemy_type:
		"boss":
			enemy_portrait.color = Color(0.8, 0.05, 0.08, 0.55)
		"elite":
			enemy_portrait.color = Color(1.0, 0.42, 0.12, 0.55)
		_:
			enemy_portrait.color = Color(1.0, 0.18, 0.58, 0.45)


func _spawn_pegs() -> void:
	field_generator.configure(field_config["generator"])
	dynamic_peg_slots = field_generator.build_dynamic_slots(field_config)
	for slot in dynamic_peg_slots:
		var peg := PEG_SCENE.instantiate()
		peg_container.add_child(peg)
		peg.position = Vector2(float(slot["x"]), float(slot["y"]))
		dynamic_peg_nodes.append(peg)

	for slot in field_generator.build_bottom_slots(field_config):
		var peg_id := String((slot as Dictionary)["id"])
		var peg := PEG_SCENE.instantiate()
		peg_container.add_child(peg)
		peg.position = Vector2(float((slot as Dictionary)["x"]), float((slot as Dictionary)["y"]))
		peg.configure(peg_id, DataLoader.get_peg(peg_id), float(slot["radius"]))
		bottom_peg_nodes.append(peg)


func _reroll_dynamic_pegs() -> void:
	var rolled_slots: Array = field_generator.roll_dynamic_types(field_config, dynamic_peg_slots)
	for index in range(min(dynamic_peg_nodes.size(), rolled_slots.size())):
		var slot := rolled_slots[index] as Dictionary
		var peg := dynamic_peg_nodes[index]
		var peg_id := String(slot["id"])
		peg.configure(peg_id, DataLoader.get_peg(peg_id), float(slot["radius"]))


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
		BattleState.REWARD:
			_advance_to_next_battle()
		BattleState.GAME_OVER:
			get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")
		BattleState.VICTORY:
			get_tree().change_scene_to_file("res://Scenes/Victory.tscn")


func _begin_round() -> void:
	round_index += 1
	if bool(field_config["generator"].get("reroll_each_round", true)) or round_index == 1:
		_reroll_dynamic_pegs()
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
	ball.configure(ball_id, ball_def, player_config, feel_config)
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
	battle_fx.play_sfx("launch")
	ball.launch(_aim_direction())
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
	launcher_visual.visible = true
	aim_line.visible = state == BattleState.AIMING
	if aim_line.visible:
		var direction := _aim_direction()
		aim_line.points = PackedVector2Array([
			launcher_position,
			launcher_position + direction * 115.0,
		])


func _on_ball_peg_hit(peg_id: String, hit_position: Vector2, hit_color: Color) -> void:
	var peg_def := RunState.get_modified_peg_def(DataLoader.get_peg(peg_id))
	var result: Dictionary = effect_resolver.apply_peg_effect(peg_def, round_context)
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
	battle_fx.spawn_hit_particles(hit_position, hit_color)
	battle_fx.start_hit_shake()
	battle_fx.play_sfx("hit")
	_update_ui()


func _on_ball_wall_hit(_hit_position: Vector2) -> void:
	battle_fx.play_sfx("wall")


func _on_ball_recovered(_ball: RigidBody2D, reason: String) -> void:
	round_context.balls_in_play = max(0, round_context.balls_in_play - 1)
	status_label.text = "球已回收：%s" % reason
	battle_fx.play_sfx("drop")
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
	battle_fx.show_floating_text("TOTAL %s" % round_context.damage_accumulator, Vector2(512, 610), Color(1.0, 0.9, 0.35))
	battle_fx.play_sfx("settle")
	_transition_to(BattleState.CHECK)


func _enemy_turn() -> void:
	var attack_info := _enemy_attack_value()
	var base_attack := int(attack_info["attack"])
	var attack: int = effect_resolver.resolve_enemy_attack(base_attack, round_context)
	RunState.damage_player(attack)
	round_context.enemy_acted_this_settlement = true
	status_label.text = "%s，玩家 -%s HP" % [String(attack_info["message"]), attack]
	if attack < base_attack:
		status_label.text += "（Shield 減免）"
	battle_fx.show_floating_text("-%s HP" % attack, Vector2(132, 48), Color(1.0, 0.2, 0.2))
	battle_fx.start_enemy_attack_shake()
	battle_fx.play_sfx("enemy_attack")
	_transition_to(BattleState.CHECK)


func _enemy_attack_value() -> Dictionary:
	if String(enemy_def.get("type", "")) == "boss" and enemy_def.has("special"):
		var special: Dictionary = enemy_def["special"]
		var every_n_rounds := int(special.get("every_n_rounds", 3))
		if every_n_rounds > 0 and round_index % every_n_rounds == 0:
			return {
				"attack": RunState.get_modified_enemy_attack(int(special.get("attack", enemy_def["attack"]))),
				"message": "%s 施放 %s" % [String(enemy_def["name"]), String(special.get("name", "強攻擊"))],
			}
	return {
		"attack": RunState.get_modified_enemy_attack(int(enemy_def["attack"])),
		"message": "%s 反擊" % String(enemy_def["name"]),
	}


func _check_battle_end() -> void:
	if RunState.is_player_dead():
		_transition_to(BattleState.GAME_OVER)
		return
	if enemy_hp <= 0:
		RunState.kills += 1
		if String(enemy_def.get("type", "")) == "boss" or RunState.current_battle_index >= DataLoader.enemies.size() - 1:
			_transition_to(BattleState.VICTORY)
		else:
			_transition_to(BattleState.REWARD)
		return
	if not round_context.enemy_acted_this_settlement:
		_transition_to(BattleState.ENEMY_TURN)
	else:
		_transition_to(BattleState.ROUND_START)


func _advance_to_next_battle() -> void:
	RunState.pending_upgrade_enemy_type = String(enemy_def.get("type", "normal"))
	status_label.text = "選擇升級"
	get_tree().change_scene_to_file("res://Scenes/UpgradeScreen.tscn")


func _update_ui() -> void:
	if player_hp_label == null:
		return
	player_hp_label.text = "玩家 HP：%s / %s" % [RunState.player_hp, RunState.player_max_hp]
	enemy_hp_label.text = "敵人 HP：%s / %s  %s" % [enemy_hp, enemy_max_hp, String(enemy_def.get("name", ""))]
	round_label.text = "回合：%s" % round_index
	damage_label.text = "本回合傷害：%s" % round_context.damage_accumulator
	balls_label.text = "剩餘球：%s｜場上球：%s" % [round_context.balls_remaining, round_context.balls_in_play]
	sfx_toggle_button.text = "SFX: %s" % ("ON" if sfx_enabled else "OFF")
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


func _on_sfx_toggle_pressed() -> void:
	sfx_enabled = not sfx_enabled
	battle_fx.set_sfx_enabled(sfx_enabled)
	_update_ui()


func _on_restart_pressed() -> void:
	RunState.reset_new_run()
	get_tree().reload_current_scene()


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

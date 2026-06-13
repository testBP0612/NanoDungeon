extends Node

var player_max_hp := 0
var player_hp := 0
var balls_per_round := 0
var current_battle_index := 0
var kills := 0
var unlocked_balls: Array[String] = []


func reset_new_run() -> void:
	if not DataLoader.loaded:
		DataLoader.load_all()
	var player_config := DataLoader.get_player_config()
	player_max_hp = int(player_config["max_hp"])
	player_hp = player_max_hp
	balls_per_round = int(player_config["balls_per_round"])
	current_battle_index = 0
	kills = 0
	unlocked_balls.clear()
	unlocked_balls.append(String(player_config["starting_ball_id"]))


func ensure_run_started() -> void:
	if player_max_hp <= 0 or player_hp <= 0 or balls_per_round <= 0:
		reset_new_run()


func damage_player(amount: int) -> void:
	player_hp = max(0, player_hp - amount)


func heal_player(amount: int) -> void:
	player_hp = min(player_max_hp, player_hp + amount)


func is_player_dead() -> bool:
	return player_hp <= 0

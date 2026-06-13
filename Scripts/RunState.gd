extends Node

var player_max_hp := 0
var player_hp := 0
var balls_per_round := 0
var current_battle_index := 0
var kills := 0
var started_at_msec := 0
var unlocked_balls: Array[String] = []
var peg_damage_mods: Dictionary = {}
var peg_effect_mods: Dictionary = {}
var peg_trigger_mods: Dictionary = {}
var enemy_attack_down := 0
var guaranteed_double_peg_count := 0
var max_guaranteed_double_peg_count := 0
var overload_charge := 0
var overload_rounds_without_trigger := 0
var overload_rounds_remaining := 0
var applied_upgrades: Array[String] = []
var pending_upgrade_enemy_type := "normal"

const MAX_BALLS_PER_ROUND := 6


func reset_new_run() -> void:
	if not DataLoader.loaded:
		DataLoader.load_all()
	var player_config := DataLoader.get_player_config()
	var field_config := DataLoader.get_field_config()
	var generator_config: Dictionary = field_config.get("generator", {})
	player_max_hp = int(player_config["max_hp"])
	player_hp = player_max_hp
	balls_per_round = int(player_config["balls_per_round"])
	guaranteed_double_peg_count = int(generator_config.get("guaranteed_double_peg_count", 0))
	max_guaranteed_double_peg_count = int(generator_config.get("max_guaranteed_double_peg_count", guaranteed_double_peg_count))
	overload_charge = 0
	overload_rounds_without_trigger = 0
	overload_rounds_remaining = 0
	current_battle_index = 0
	kills = 0
	started_at_msec = Time.get_ticks_msec()
	enemy_attack_down = 0
	pending_upgrade_enemy_type = "normal"
	peg_damage_mods.clear()
	peg_effect_mods.clear()
	peg_trigger_mods.clear()
	applied_upgrades.clear()
	unlocked_balls.clear()
	for ball_id in DataLoader.get_default_unlocked_balls():
		unlocked_balls.append(ball_id)
	if unlocked_balls.is_empty():
		unlocked_balls.append(String(player_config["starting_ball_id"]))


func ensure_run_started() -> void:
	if player_max_hp <= 0 or player_hp <= 0 or balls_per_round <= 0 or max_guaranteed_double_peg_count <= 0:
		reset_new_run()


func is_overload_enabled(overload_config: Dictionary) -> bool:
	return bool(overload_config.get("enabled", true))


func is_overload_active() -> bool:
	return overload_rounds_remaining > 0


func get_overload_charge_ratio(overload_config: Dictionary) -> float:
	var threshold: int = max(1, int(overload_config.get("trigger_threshold", 100)))
	return clamp(float(overload_charge) / float(threshold), 0.0, 1.0)


func add_overload_charge(amount: int, overload_config: Dictionary) -> bool:
	if not is_overload_enabled(overload_config) or is_overload_active() or amount <= 0:
		return false
	var threshold: int = max(1, int(overload_config.get("trigger_threshold", 100)))
	overload_charge = min(threshold, overload_charge + amount)
	return overload_charge >= threshold


func trigger_overload(overload_config: Dictionary) -> bool:
	if not is_overload_enabled(overload_config):
		return false
	overload_rounds_remaining = max(1, int(overload_config.get("overload_duration_rounds", 1)))
	overload_charge = max(1, int(overload_config.get("trigger_threshold", 100)))
	overload_rounds_without_trigger = 0
	return true


func record_overload_miss_round(overload_config: Dictionary) -> void:
	if not is_overload_enabled(overload_config) or is_overload_active():
		return
	overload_rounds_without_trigger += 1


func should_force_overload(overload_config: Dictionary) -> bool:
	if not is_overload_enabled(overload_config) or is_overload_active():
		return false
	var pity_rounds := int(overload_config.get("pity_rounds", 0))
	return pity_rounds > 0 and overload_rounds_without_trigger >= pity_rounds


func consume_overload_round() -> bool:
	if overload_rounds_remaining <= 0:
		return false
	overload_rounds_remaining -= 1
	if overload_rounds_remaining <= 0:
		overload_charge = 0
		overload_rounds_without_trigger = 0
		return true
	return false


func damage_player(amount: int) -> void:
	player_hp = max(0, player_hp - amount)


func heal_player(amount: int) -> void:
	player_hp = min(player_max_hp, player_hp + amount)


func increase_max_hp(amount: int) -> void:
	player_max_hp += amount
	player_hp = min(player_max_hp, player_hp + int(ceil(float(amount) * 0.5)))


func increase_balls_per_round(amount: int) -> void:
	balls_per_round = min(MAX_BALLS_PER_ROUND, balls_per_round + amount)


func add_enemy_attack_down(amount: int) -> void:
	enemy_attack_down += amount


func increase_guaranteed_double_peg(amount: int) -> void:
	guaranteed_double_peg_count = min(max_guaranteed_double_peg_count, guaranteed_double_peg_count + amount)


func unlock_ball(ball_id: String) -> void:
	if not unlocked_balls.has(ball_id):
		unlocked_balls.append(ball_id)


func add_peg_damage_mod(peg_id: String, amount: float) -> void:
	peg_damage_mods[peg_id] = float(peg_damage_mods.get(peg_id, 0.0)) + amount


func add_peg_effect_mod(peg_id: String, amount: float) -> void:
	peg_effect_mods[peg_id] = float(peg_effect_mods.get(peg_id, 0.0)) + amount


func add_peg_trigger_mod(peg_id: String, amount: int) -> void:
	peg_trigger_mods[peg_id] = int(peg_trigger_mods.get(peg_id, 0)) + amount


func get_modified_peg_def(peg_def: Dictionary) -> Dictionary:
	var modified := peg_def.duplicate(true)
	var peg_id := String(modified["id"])
	if peg_damage_mods.has(peg_id):
		modified["base_damage"] = float(modified["base_damage"]) + float(peg_damage_mods[peg_id])
	if peg_effect_mods.has(peg_id):
		modified["effect_value"] = float(modified["effect_value"]) + float(peg_effect_mods[peg_id])
	if peg_trigger_mods.has(peg_id):
		modified["max_triggers_per_round"] = int(modified.get("max_triggers_per_round", 1)) + int(peg_trigger_mods[peg_id])
	return modified


func get_modified_enemy_attack(base_attack: int) -> int:
	return max(1, base_attack - enemy_attack_down)


func record_upgrade(upgrade_id: String) -> void:
	applied_upgrades.append(upgrade_id)


func build_summary() -> String:
	var ball_summary := ""
	for ball_id in unlocked_balls:
		if not ball_summary.is_empty():
			ball_summary += ", "
		ball_summary += DataLoader.get_ball_name(ball_id)
	if applied_upgrades.is_empty():
		return "升級：無｜球池：%s" % ball_summary
	var upgrade_names := ""
	for upgrade_id in applied_upgrades:
		if not upgrade_names.is_empty():
			upgrade_names += "、"
		upgrade_names += DataLoader.get_upgrade_name(upgrade_id)
	return "升級：%s｜球池：%s" % [upgrade_names, ball_summary]


func is_player_dead() -> bool:
	return player_hp <= 0


func get_elapsed_seconds() -> float:
	if started_at_msec <= 0:
		return 0.0
	return float(Time.get_ticks_msec() - started_at_msec) / 1000.0

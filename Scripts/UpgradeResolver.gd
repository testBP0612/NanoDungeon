extends RefCounted

const RARITY_WEIGHTS := {
	"common": 60,
	"rare": 30,
	"legendary": 10,
}

var _rng := RandomNumberGenerator.new()


func _init() -> void:
	_rng.randomize()


func draw_upgrade_options(enemy_type: String) -> Array:
	var options := []
	if enemy_type == "elite":
		var premium_pool := _eligible_upgrades(["rare", "legendary"], [])
		if not premium_pool.is_empty():
			var first_pick := _weighted_pick(premium_pool)
			options.append(first_pick)

	while options.size() < 3:
		var excluded_ids := _option_ids(options)
		var pool := _eligible_upgrades([], excluded_ids)
		if pool.is_empty():
			break
		options.append(_weighted_pick(pool))

	return options


func apply_upgrade(upgrade: Dictionary) -> void:
	var target_type := String(upgrade["target_type"])
	var target_id := String(upgrade["target_id"])
	var effect_type := String(upgrade["effect_type"])
	var effect_value: Variant = upgrade["effect_value"]

	match target_type:
		"peg":
			_apply_peg_upgrade(target_id, effect_type, effect_value)
		"ball":
			if effect_type == "unlock":
				RunState.unlock_ball(target_id)
		"stat":
			_apply_stat_upgrade(target_id, effect_type, effect_value)

	RunState.record_upgrade(String(upgrade["id"]))


func _apply_peg_upgrade(target_id: String, effect_type: String, effect_value: Variant) -> void:
	var peg_def := DataLoader.get_peg(target_id)
	match effect_type:
		"add":
			if String(peg_def.get("effect_type", "")) == "damage":
				RunState.add_peg_damage_mod(target_id, float(effect_value))
			else:
				RunState.add_peg_effect_mod(target_id, float(effect_value))
		"multiply":
			RunState.add_peg_effect_mod(target_id, float(peg_def["effect_value"]) * (float(effect_value) - 1.0))
		"add_trigger":
			RunState.add_peg_trigger_mod(target_id, int(effect_value))


func _apply_stat_upgrade(target_id: String, effect_type: String, effect_value: Variant) -> void:
	if effect_type != "add":
		return
	match target_id:
		"max_hp":
			RunState.increase_max_hp(int(effect_value))
		"balls_per_round":
			RunState.increase_balls_per_round(int(effect_value))
		"enemy_attack_down":
			RunState.add_enemy_attack_down(int(effect_value))


func _eligible_upgrades(allowed_rarities: Array, excluded_ids: Array) -> Array:
	var eligible := []
	for item in DataLoader.get_upgrades():
		var upgrade := item as Dictionary
		if excluded_ids.has(String(upgrade["id"])):
			continue
		if not allowed_rarities.is_empty() and not allowed_rarities.has(String(upgrade["rarity"])):
			continue
		if _is_upgrade_excluded(upgrade):
			continue
		eligible.append(upgrade)
	return eligible


func _is_upgrade_excluded(upgrade: Dictionary) -> bool:
	var target_type := String(upgrade["target_type"])
	var target_id := String(upgrade["target_id"])
	var effect_type := String(upgrade["effect_type"])
	if target_type == "ball" and effect_type == "unlock":
		return RunState.unlocked_balls.has(target_id)
	if target_type == "stat" and target_id == "balls_per_round":
		return RunState.balls_per_round >= RunState.MAX_BALLS_PER_ROUND
	return false


func _weighted_pick(pool: Array) -> Dictionary:
	var total_weight := 0
	for item in pool:
		var upgrade := item as Dictionary
		total_weight += int(RARITY_WEIGHTS.get(String(upgrade["rarity"]), 0))

	if total_weight <= 0:
		return (pool[0] as Dictionary).duplicate(true)

	var roll := _rng.randi_range(1, total_weight)
	var running := 0
	for item in pool:
		var upgrade := item as Dictionary
		running += int(RARITY_WEIGHTS.get(String(upgrade["rarity"]), 0))
		if roll <= running:
			return upgrade.duplicate(true)

	return (pool.back() as Dictionary).duplicate(true)


func _option_ids(options: Array) -> Array:
	var ids := []
	for option in options:
		ids.append(String((option as Dictionary)["id"]))
	return ids

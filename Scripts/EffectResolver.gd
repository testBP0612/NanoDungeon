extends RefCounted


func apply_peg_effect(peg_def: Dictionary, round_context: RefCounted) -> Dictionary:
	match String(peg_def.get("effect_type", "")):
		"none":
			return _empty_peg_result()
		"damage":
			return _apply_damage_peg(peg_def, round_context)
		"heal":
			return _apply_heal_peg(peg_def, round_context)
		"damage_multiplier":
			return _apply_damage_multiplier_peg(peg_def, round_context)
		_:
			return _empty_peg_result()


func _empty_peg_result() -> Dictionary:
	return {
		"damage_added": 0,
		"heal_added": 0,
		"multiplier_applied": false,
		"feedback_text": "",
		"message": "",
	}


func _apply_damage_peg(peg_def: Dictionary, round_context: RefCounted) -> Dictionary:
	var hit_damage := int(round(float(peg_def["base_damage"]) * round_context.round_multiplier))
	round_context.add_damage(hit_damage)
	return {
		"damage_added": hit_damage,
		"heal_added": 0,
		"multiplier_applied": false,
		"feedback_text": "+%s" % hit_damage,
		"message": "命中 %s，+%s 傷害" % [String(peg_def["name"]), hit_damage],
	}


func _apply_heal_peg(peg_def: Dictionary, round_context: RefCounted) -> Dictionary:
	var heal_amount := int(peg_def["effect_value"])
	round_context.add_heal(heal_amount)
	return {
		"damage_added": 0,
		"heal_added": heal_amount,
		"multiplier_applied": false,
		"feedback_text": "+%s HP" % heal_amount,
		"message": "命中 %s，結算時 +%s HP" % [String(peg_def["name"]), heal_amount],
	}


func _apply_damage_multiplier_peg(peg_def: Dictionary, round_context: RefCounted) -> Dictionary:
	var multiplier := float(peg_def["effect_value"])
	var max_triggers := int(peg_def.get("max_triggers_per_round", 1))
	var applied: bool = round_context.try_apply_multiplier(multiplier, max_triggers)
	return {
		"damage_added": 0,
		"heal_added": 0,
		"multiplier_applied": applied,
		"feedback_text": "x%s" % multiplier,
		"message": "命中 %s，倍率 x%s%s" % [
			String(peg_def["name"]),
			multiplier,
			"" if applied else " 已達上限",
		],
	}


func apply_ball_launch_effect(ball_def: Dictionary, round_context: RefCounted) -> Dictionary:
	match String(ball_def.get("effect_type", "")):
		"on_drop_bonus":
			round_context.add_drop_bonus_multiplier(float(ball_def["effect_value"]))
			return {"message": "Blast Ball 已充能：結算加成最高單次傷害"}
		"damage_reduction":
			round_context.apply_damage_reduction(float(ball_def["effect_value"]))
			return {"message": "Shield Ball 已啟動：本回合敵人攻擊減免"}
		_:
			return {"message": ""}


func apply_settlement_effects(round_context: RefCounted) -> Dictionary:
	var bonus_damage := int(round(float(round_context.highest_single_hit) * round_context.pending_drop_bonus_multiplier))
	if bonus_damage > 0:
		round_context.add_settlement_bonus(bonus_damage)

	return {
		"bonus_damage": bonus_damage,
		"heal_amount": round_context.pending_heal,
	}


func resolve_enemy_attack(base_attack: int, round_context: RefCounted) -> int:
	var reduced_attack := int(round(float(base_attack) * (1.0 - round_context.incoming_damage_reduction)))
	return max(0, reduced_attack)

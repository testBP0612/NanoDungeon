extends RefCounted


func apply_peg_effect(peg_def: Dictionary, round_context: RefCounted) -> Dictionary:
	match String(peg_def.get("effect_type", "")):
		"damage":
			return _apply_damage_peg(peg_def, round_context)
		_:
			return {
				"damage_added": 0,
				"message": "",
			}


func _apply_damage_peg(peg_def: Dictionary, round_context: RefCounted) -> Dictionary:
	var hit_damage := int(peg_def["base_damage"])
	round_context.add_damage(hit_damage)
	return {
		"damage_added": hit_damage,
		"message": "命中 %s，+%s 傷害" % [String(peg_def["name"]), hit_damage],
	}

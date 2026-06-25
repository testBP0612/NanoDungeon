extends Node

var pegs_by_id: Dictionary = {}
var balls: Array = []
var balls_by_id: Dictionary = {}
var enemies: Array = []
var upgrades: Array = []
var player_config: Dictionary = {}
var feel_config: Dictionary = {}
var field_config: Dictionary = {}
var overload_config: Dictionary = {}
var loaded := false


func _ready() -> void:
	load_all()


func load_all() -> void:
	var pegs_data := _load_json("res://Data/pegs.json")
	var balls_data := _load_json("res://Data/balls.json")
	var enemies_data := _load_json("res://Data/enemies.json")
	var upgrades_data := _load_json("res://Data/upgrades.json")
	var player_data := _load_json("res://Data/player.json")
	var feel_data := _load_json("res://Data/feel.json")
	var field_data := _load_json("res://Data/field.json")
	var overload_data := _load_json("res://Data/overload.json")

	pegs_by_id = _index_collection(pegs_data, "pegs", ["id", "name", "base_damage", "effect_type", "effect_value"])
	balls = _validate_collection(balls_data, "balls", ["id", "name", "effect_type", "effect_value", "unlocked_by_default"])
	balls_by_id = _index_array(balls, "balls")
	enemies = _validate_collection(enemies_data, "enemies", ["id", "name", "type", "hp", "attack", "description", "dialogue"])
	upgrades = _validate_collection(upgrades_data, "upgrades", ["id", "name", "target_type", "target_id", "effect_type", "effect_value", "rarity"])
	player_config = _validate_player_config(player_data)
	feel_config = _validate_feel_config(feel_data)
	field_config = _validate_field_config(field_data)
	overload_config = _validate_overload_config(overload_data)
	_validate_upgrades(upgrades_data)
	loaded = true


func get_peg(peg_id: String) -> Dictionary:
	return pegs_by_id.get(peg_id, {}).duplicate(true)


func get_ball(ball_id: String) -> Dictionary:
	return balls_by_id.get(ball_id, {}).duplicate(true)


func get_ball_name(ball_id: String) -> String:
	return String(balls_by_id.get(ball_id, {}).get("name", ball_id))


func get_enemy(index: int) -> Dictionary:
	if index < 0 or index >= enemies.size():
		push_error("Enemy index out of range: %s" % index)
		return {}
	return (enemies[index] as Dictionary).duplicate(true)


func get_upgrades() -> Array:
	return _duplicate_dictionary_array(upgrades)


func get_upgrade_name(upgrade_id: String) -> String:
	for item in upgrades:
		var upgrade := item as Dictionary
		if String(upgrade["id"]) == upgrade_id:
			return String(upgrade["name"])
	return upgrade_id


func get_default_unlocked_balls() -> Array[String]:
	var default_balls: Array[String] = []
	for ball in balls:
		var ball_def := ball as Dictionary
		if bool(ball_def.get("unlocked_by_default", false)):
			default_balls.append(String(ball_def["id"]))
	return default_balls


func get_player_config() -> Dictionary:
	return player_config.duplicate(true)


func get_feel_config() -> Dictionary:
	return feel_config.duplicate(true)


func get_field_config() -> Dictionary:
	return field_config.duplicate(true)


func get_overload_config() -> Dictionary:
	return overload_config.duplicate(true)


func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Missing JSON file: %s" % path)
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Unable to open JSON file: %s" % path)
		return {}

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid JSON object: %s" % path)
		return {}

	return parsed as Dictionary


func _index_collection(data: Dictionary, key: String, required_fields: Array) -> Dictionary:
	return _index_array(_validate_collection(data, key, required_fields), key)


func _index_array(collection: Array, key: String) -> Dictionary:
	var indexed := {}
	for item in collection:
		var item_id := String(item["id"])
		if indexed.has(item_id):
			push_error("Duplicate id in %s: %s" % [key, item_id])
		indexed[item_id] = item
	return indexed


func _validate_collection(data: Dictionary, key: String, required_fields: Array) -> Array:
	var collection: Array = data.get(key, [])
	if typeof(collection) != TYPE_ARRAY:
		push_error("Missing or invalid collection: %s" % key)
		return []

	for item in collection:
		if typeof(item) != TYPE_DICTIONARY:
			push_error("Invalid item in %s" % key)
			continue
		for field in required_fields:
			if not (item as Dictionary).has(field):
				push_error("Missing field '%s' in %s item" % [field, key])

	return collection


func _duplicate_dictionary_array(collection: Array) -> Array:
	var duplicated := []
	for item in collection:
		duplicated.append((item as Dictionary).duplicate(true))
	return duplicated


func _vector2_from_array(value: Variant, fallback: Vector2) -> Vector2:
	if typeof(value) != TYPE_ARRAY:
		return fallback
	var array: Array = value
	if array.size() < 2:
		return fallback
	return Vector2(float(array[0]), float(array[1]))


func _validate_player_config(data: Dictionary) -> Dictionary:
	var config: Dictionary = data.get("player", {})
	var required_fields := [
		"max_hp",
		"balls_per_round",
		"starting_ball_id",
		"ball_timeout_seconds",
		"launch_speed",
		"plunger_launch_speed",
		"launch_speed_min",
		"launch_speed_max",
		"charge_cycle_seconds",
		"ball_radius",
		"ball_gravity_scale",
		"ball_bounce",
		"ball_friction",
		"peg_bounce_boost",
		"max_ball_speed",
		"peg_hit_physics",
		"wall_hit_physics",
		"execute",
	]

	if typeof(config) != TYPE_DICTIONARY:
		push_error("Missing player config in Data/player.json")
		return {}

	for field in required_fields:
		if not (config as Dictionary).has(field):
			push_error("Missing player config field: %s" % field)
	if float(config.get("launch_speed", 0.0)) <= 0.0:
		push_error("Player launch_speed must be > 0")
	if float(config.get("plunger_launch_speed", 0.0)) <= 0.0:
		push_error("Player plunger_launch_speed must be > 0")
	if float(config.get("launch_speed_min", 0.0)) <= 0.0 or float(config.get("launch_speed_max", 0.0)) <= 0.0:
		push_error("Player launch_speed_min/max must be > 0")
	if float(config.get("launch_speed_max", 0.0)) < float(config.get("launch_speed_min", 0.0)):
		push_error("Player launch_speed_max must be >= launch_speed_min")
	if float(config.get("charge_cycle_seconds", 0.0)) <= 0.0:
		push_error("Player charge_cycle_seconds must be > 0")
	if float(config.get("peg_bounce_boost", 0.0)) <= 0.0:
		push_error("Player peg_bounce_boost must be > 0")
	if float(config.get("max_ball_speed", 0.0)) <= 0.0:
		push_error("Player max_ball_speed must be > 0")
	var peg_hit_physics: Dictionary = config.get("peg_hit_physics", {})
	if typeof(peg_hit_physics) != TYPE_DICTIONARY:
		push_error("Player peg_hit_physics must be a dictionary")
	else:
		if float(peg_hit_physics.get("exit_speed_multiplier", 0.0)) <= 0.0:
			push_error("Player peg_hit_physics.exit_speed_multiplier must be > 0")
		if float(peg_hit_physics.get("min_exit_speed", 0.0)) <= 0.0:
			push_error("Player peg_hit_physics.min_exit_speed must be > 0")
		if float(peg_hit_physics.get("min_outward_speed", 0.0)) <= 0.0:
			push_error("Player peg_hit_physics.min_outward_speed must be > 0")
		if float(peg_hit_physics.get("tangent_retention", -1.0)) < 0.0 or float(peg_hit_physics.get("tangent_retention", 2.0)) > 1.0:
			push_error("Player peg_hit_physics.tangent_retention must be between 0 and 1")
		if float(peg_hit_physics.get("unstick_distance", -1.0)) < 0.0:
			push_error("Player peg_hit_physics.unstick_distance must be >= 0")
		if float(peg_hit_physics.get("exit_cooldown_seconds", -1.0)) < 0.0:
			push_error("Player peg_hit_physics.exit_cooldown_seconds must be >= 0")
	var wall_hit_physics: Dictionary = config.get("wall_hit_physics", {})
	if typeof(wall_hit_physics) != TYPE_DICTIONARY:
		push_error("Player wall_hit_physics must be a dictionary")
	else:
		_validate_wall_hit_profile(wall_hit_physics.get("default_profile", {}), "default_profile")
		var wall_profiles: Dictionary = wall_hit_physics.get("profiles", {})
		if typeof(wall_profiles) != TYPE_DICTIONARY:
			push_error("Player wall_hit_physics.profiles must be a dictionary")
		else:
			for profile_name in wall_profiles.keys():
				_validate_wall_hit_profile(wall_profiles[profile_name], "profiles.%s" % String(profile_name))
	var execute: Dictionary = config.get("execute", {})
	if typeof(execute) != TYPE_DICTIONARY:
		push_error("Player execute config must be a dictionary")
	if float(execute.get("margin", 0.0)) < 0.0:
		push_error("Player execute.margin must be >= 0")

	return (config as Dictionary).duplicate(true)


func _validate_wall_hit_profile(profile: Variant, label: String) -> void:
	if typeof(profile) != TYPE_DICTIONARY:
		push_error("Player wall_hit_physics.%s must be a dictionary" % label)
		return
	var profile_dict: Dictionary = profile
	if float(profile_dict.get("speed_multiplier", 0.0)) <= 0.0:
		push_error("Player wall_hit_physics.%s.speed_multiplier must be > 0" % label)
	if float(profile_dict.get("min_exit_speed", -1.0)) < 0.0:
		push_error("Player wall_hit_physics.%s.min_exit_speed must be >= 0" % label)
	if float(profile_dict.get("exit_cooldown_seconds", -1.0)) < 0.0:
		push_error("Player wall_hit_physics.%s.exit_cooldown_seconds must be >= 0" % label)


func _validate_feel_config(data: Dictionary) -> Dictionary:
	var config: Dictionary = data.get("feel", {})
	var required_fields := [
		"peg_rehit_cooldown_seconds",
		"shake",
		"particles",
		"trail",
		"aim_preview",
		"floating_text",
		"transitions",
		"turn_pacing",
		"enemy_attack",
		"combo",
		"hitstop",
		"peg_feel",
		"round_heat",
		"ball_squash",
		"telegraph",
		"low_hp",
		"charge",
		"launcher",
		"drain",
		"reroll_flash",
		"upgrade_card",
		"settlement",
		"overkill_cutin",
		"player_attack",
		"sfx",
		"hp_tween_duration",
	]

	if typeof(config) != TYPE_DICTIONARY:
		push_error("Missing feel config in Data/feel.json")
		return {}

	for field in required_fields:
		if not config.has(field):
			push_error("Missing feel config field: %s" % field)
	var aim_preview: Dictionary = config.get("aim_preview", {})
	if int(aim_preview.get("point_count", 0)) < 2:
		push_error("feel.aim_preview.point_count must be >= 2")
	if float(aim_preview.get("time_step", 0.0)) <= 0.0:
		push_error("feel.aim_preview.time_step must be > 0")
	if float(aim_preview.get("line_width", 0.0)) <= 0.0:
		push_error("feel.aim_preview.line_width must be > 0")
	if float(aim_preview.get("end_marker_radius", 0.0)) <= 0.0:
		push_error("feel.aim_preview.end_marker_radius must be > 0")
	var launcher: Dictionary = config.get("launcher", {})
	if float(launcher.get("launcher_recoil_pixels", 0.0)) < 0.0:
		push_error("feel.launcher.launcher_recoil_pixels must be >= 0")
	if float(launcher.get("launcher_recoil_seconds", 0.0)) <= 0.0:
		push_error("feel.launcher.launcher_recoil_seconds must be > 0")
	var overkill_cutin: Dictionary = config.get("overkill_cutin", {})
	if float(overkill_cutin.get("flash_seconds", 0.0)) <= 0.0:
		push_error("feel.overkill_cutin.flash_seconds must be > 0")
	if float(overkill_cutin.get("cut_in_seconds", 0.0)) <= 0.0:
		push_error("feel.overkill_cutin.cut_in_seconds must be > 0")
	var player_attack: Dictionary = config.get("player_attack", {})
	if float(player_attack.get("gather_seconds", 0.0)) < 0.0:
		push_error("feel.player_attack.gather_seconds must be >= 0")
	if float(player_attack.get("travel_seconds", 0.0)) <= 0.0:
		push_error("feel.player_attack.travel_seconds must be > 0")
	if float(player_attack.get("damage_scale_reference", 0.0)) <= 0.0:
		push_error("feel.player_attack.damage_scale_reference must be > 0")
	if float(player_attack.get("max_width", 0.0)) < float(player_attack.get("base_width", 0.0)):
		push_error("feel.player_attack.max_width must be >= base_width")
	var hitstop: Dictionary = config.get("hitstop", {})
	if float(hitstop.get("base_seconds", 0.0)) < 0.0:
		push_error("feel.hitstop.base_seconds must be >= 0")
	if float(hitstop.get("max_seconds", 0.0)) < float(hitstop.get("base_seconds", 0.0)):
		push_error("feel.hitstop.max_seconds must be >= base_seconds")
	if float(hitstop.get("time_scale", 1.0)) <= 0.0 or float(hitstop.get("time_scale", 1.0)) > 1.0:
		push_error("feel.hitstop.time_scale must be in (0, 1]")
	var peg_feel: Dictionary = config.get("peg_feel", {})
	if typeof(peg_feel.get("default", {})) != TYPE_DICTIONARY:
		push_error("feel.peg_feel.default must be a dictionary")
	var round_heat: Dictionary = config.get("round_heat", {})
	if float(round_heat.get("reference_ratio", 0.0)) <= 0.0:
		push_error("feel.round_heat.reference_ratio must be > 0")
	if float(round_heat.get("lerp_speed", 0.0)) < 0.0:
		push_error("feel.round_heat.lerp_speed must be >= 0")
	var ball_squash: Dictionary = config.get("ball_squash", {})
	if float(ball_squash.get("squash_seconds", 0.0)) < 0.0:
		push_error("feel.ball_squash.squash_seconds must be >= 0")
	if float(ball_squash.get("stretch_seconds", 0.0)) < 0.0:
		push_error("feel.ball_squash.stretch_seconds must be >= 0")
	if float(ball_squash.get("recover_seconds", 0.0)) < 0.0:
		push_error("feel.ball_squash.recover_seconds must be >= 0")
	for scale_field in ["squash_scale", "stretch_scale"]:
		var scale_value: Variant = ball_squash.get(scale_field, [])
		if typeof(scale_value) != TYPE_ARRAY or (scale_value as Array).size() < 2:
			push_error("feel.ball_squash.%s must be an array with 2 numbers" % scale_field)

	return config.duplicate(true)


func _validate_field_config(data: Dictionary) -> Dictionary:
	var config: Dictionary = data.get("field", {})
	if typeof(config) != TYPE_DICTIONARY:
		push_error("Missing field config in Data/field.json")
		return {}

	var bounds: Dictionary = config.get("bounds", {})
	var default_radius := float(config.get("default_peg_radius", 0.0))
	var generator: Dictionary = config.get("generator", {})
	var bottom_row: Dictionary = config.get("bottom_row", {})
	var plunger: Dictionary = config.get("plunger", {})
	var launch_lane: Dictionary = config.get("launch_lane", {})
	var required_bounds := ["left", "right", "top", "bottom"]

	if typeof(bounds) != TYPE_DICTIONARY:
		push_error("Missing field bounds in Data/field.json")
	if typeof(generator) != TYPE_DICTIONARY:
		push_error("Missing field generator in Data/field.json")
	if typeof(bottom_row) != TYPE_DICTIONARY:
		push_error("Missing field bottom_row in Data/field.json")
	if typeof(plunger) != TYPE_DICTIONARY:
		push_error("Missing field plunger in Data/field.json")
	if typeof(launch_lane) != TYPE_DICTIONARY:
		push_error("Missing field launch_lane in Data/field.json")
	for field in required_bounds:
		if not bounds.has(field):
			push_error("Missing field bounds value: %s" % field)
	if default_radius <= 0.0:
		push_error("Field default_peg_radius must be > 0")

	var left := float(bounds.get("left", 0.0))
	var right := float(bounds.get("right", 0.0))
	var top := float(bounds.get("top", 0.0))
	var bottom := float(bounds.get("bottom", 0.0))
	if float(config.get("wall_thickness", 0.0)) <= 0.0:
		push_error("Field wall_thickness must be > 0")
	if float(config.get("bottom_sensor_height", 0.0)) <= 0.0:
		push_error("Field bottom_sensor_height must be > 0")
	_validate_plunger(plunger, left, right, top, bottom)
	_validate_launch_lane(launch_lane, left, right, top, bottom)
	_validate_field_generator(generator, left, right, top, bottom, default_radius, launch_lane)
	_validate_bottom_row(bottom_row, left, right, top, bottom)

	var normalized := config.duplicate(true)
	return normalized


func _validate_plunger(plunger: Dictionary, left: float, right: float, top: float, bottom: float) -> void:
	var position := _vector2_from_array(plunger.get("position", []), Vector2(INF, INF))
	var launch_direction := _vector2_from_array(plunger.get("launch_direction", []), Vector2.ZERO)
	if position.x < left or position.x > right or position.y < top or position.y > bottom:
		push_error("Field plunger.position must be inside bounds")
	if launch_direction.length() <= 0.01:
		push_error("Field plunger.launch_direction must be non-zero")


func _validate_launch_lane(launch_lane: Dictionary, left: float, right: float, top: float, bottom: float) -> void:
	var lane_left := float(launch_lane.get("left", INF))
	var lane_right := float(launch_lane.get("right", -INF))
	var lane_top := float(launch_lane.get("top", INF))
	var lane_bottom := float(launch_lane.get("bottom", -INF))
	var wall_thickness := float(launch_lane.get("wall_thickness", 0.0))
	var peg_clearance := float(launch_lane.get("peg_clearance", -1.0))
	var inner_wall: Dictionary = launch_lane.get("inner_wall", {})
	var deflector: Dictionary = launch_lane.get("deflector", {})
	if lane_left <= left or lane_right > right or lane_right <= lane_left:
		push_error("Field launch_lane horizontal bounds are invalid")
	if lane_top < top or lane_bottom > bottom or lane_bottom <= lane_top:
		push_error("Field launch_lane vertical bounds are invalid")
	if wall_thickness <= 0.0:
		push_error("Field launch_lane.wall_thickness must be > 0")
	if peg_clearance < 0.0:
		push_error("Field launch_lane.peg_clearance must be >= 0")
	if typeof(inner_wall) != TYPE_DICTIONARY:
		push_error("Field launch_lane.inner_wall must be a dictionary")
	else:
		var inner_x := float(inner_wall.get("x", NAN))
		var inner_top := float(inner_wall.get("top", NAN))
		var inner_bottom := float(inner_wall.get("bottom", NAN))
		if is_nan(inner_x) or inner_x < lane_left or inner_x > lane_right:
			push_error("Field launch_lane.inner_wall.x must be inside lane")
		if is_nan(inner_top) or is_nan(inner_bottom) or inner_top < lane_top or inner_bottom > lane_bottom or inner_bottom <= inner_top:
			push_error("Field launch_lane.inner_wall vertical range is invalid")
	if typeof(deflector) != TYPE_DICTIONARY:
		push_error("Field launch_lane.deflector must be a dictionary")
	else:
		var deflector_position := _vector2_from_array(deflector.get("position", []), Vector2(INF, INF))
		var deflector_size := _vector2_from_array(deflector.get("size", []), Vector2.ZERO)
		if deflector_position.x < left or deflector_position.x > right or deflector_position.y < top or deflector_position.y > bottom:
			push_error("Field launch_lane.deflector.position must be inside bounds")
		if deflector_size.x <= 0.0 or deflector_size.y <= 0.0:
			push_error("Field launch_lane.deflector.size must be > 0")


func _validate_field_generator(generator: Dictionary, left: float, right: float, top: float, bottom: float, default_peg_radius: float, launch_lane: Dictionary) -> void:
	var required_fields := [
		"top_y",
		"row_count",
		"row_spacing",
		"wide_cols",
		"narrow_cols",
		"col_spacing",
		"center_x",
		"type_weights",
		"special_radius",
		"guaranteed_double_peg_count",
		"max_guaranteed_double_peg_count",
		"reroll_each_round",
		"seed",
	]
	for field in required_fields:
		if not generator.has(field):
			push_error("Missing field generator value: %s" % field)

	var type_weights: Dictionary = generator.get("type_weights", {})
	for peg_id in type_weights.keys():
		var id := String(peg_id)
		if id == "bounce_peg":
			push_error("bounce_peg must not be in generator type_weights")
		if not pegs_by_id.has(id):
			push_error("Field generator peg id not found: %s" % id)
		if int(type_weights[peg_id]) <= 0:
			push_error("Field generator weight must be > 0: %s" % id)

	var special_radius: Dictionary = generator.get("special_radius", {})
	for peg_id in special_radius.keys():
		if not pegs_by_id.has(String(peg_id)):
			push_error("Field special_radius peg id not found: %s" % String(peg_id))
		if float(special_radius[peg_id]) <= 0.0:
			push_error("Field special_radius must be > 0: %s" % String(peg_id))

	var top_y := float(generator.get("top_y", 0.0))
	var row_count := int(generator.get("row_count", 0))
	var row_spacing := float(generator.get("row_spacing", 0.0))
	var wide_cols := int(generator.get("wide_cols", 0))
	var narrow_cols := int(generator.get("narrow_cols", 0))
	var col_spacing := float(generator.get("col_spacing", 0.0))
	var center_x := float(generator.get("center_x", 0.0))
	if row_count <= 0 or wide_cols <= 0 or narrow_cols <= 0:
		push_error("Field generator rows and columns must be > 0")
	if row_spacing <= 0.0 or col_spacing <= 0.0:
		push_error("Field generator spacing must be > 0")
	var guaranteed_double := int(generator.get("guaranteed_double_peg_count", 0))
	var max_guaranteed_double := int(generator.get("max_guaranteed_double_peg_count", 0))
	var cell_count := 0
	for row in range(row_count):
		var columns := int(wide_cols if row % 2 == 0 else narrow_cols)
		for column in range(columns):
			var cell_x := center_x + (float(column) - (float(columns - 1) * 0.5)) * col_spacing
			var cell_y := top_y + float(row) * row_spacing
			if not _point_inside_launch_lane(launch_lane, cell_x, cell_y, default_peg_radius):
				cell_count += 1
	if guaranteed_double < 0:
		push_error("Field guaranteed_double_peg_count must be >= 0")
	if max_guaranteed_double < guaranteed_double:
		push_error("Field max_guaranteed_double_peg_count must be >= guaranteed_double_peg_count")
	if max_guaranteed_double > cell_count:
		push_error("Field max_guaranteed_double_peg_count must not exceed dynamic cell count")
	if top_y < top or top_y + float(max(0, row_count - 1)) * row_spacing > bottom:
		push_error("Field generator y range out of bounds")
	for columns in [wide_cols, narrow_cols]:
		var min_x := center_x - float(columns - 1) * 0.5 * col_spacing
		var max_x := center_x + float(columns - 1) * 0.5 * col_spacing
		if min_x < left or max_x > right:
			push_error("Field generator x range out of bounds")


func _point_inside_launch_lane(launch_lane: Dictionary, x: float, y: float, radius: float) -> bool:
	if launch_lane.is_empty():
		return false
	var clearance := float(launch_lane.get("peg_clearance", 0.0))
	var left := float(launch_lane.get("left", INF)) - radius - clearance
	var right := float(launch_lane.get("right", -INF)) + radius + clearance
	var top := float(launch_lane.get("top", INF)) - radius - clearance
	var bottom := float(launch_lane.get("bottom", -INF)) + radius + clearance
	return x >= left and x <= right and y >= top and y <= bottom


func _validate_bottom_row(bottom_row: Dictionary, left: float, right: float, top: float, bottom: float) -> void:
	var peg_id := String(bottom_row.get("id", ""))
	var count := int(bottom_row.get("count", 0))
	var y := float(bottom_row.get("y", NAN))
	var radius := float(bottom_row.get("radius", 0.0))
	var bounce_multiplier := float(bottom_row.get("bounce_multiplier", 0.0))
	var max_ball_speed := float(bottom_row.get("max_ball_speed", 0.0))
	if peg_id != "bounce_peg":
		push_error("Field bottom_row must use bounce_peg")
	if not pegs_by_id.has(peg_id):
		push_error("Field bottom_row peg id not found: %s" % peg_id)
	if count <= 0:
		push_error("Field bottom_row count must be > 0")
	if is_nan(y) or y < top or y > bottom:
		push_error("Field bottom_row y out of bounds")
	if radius <= 0.0:
		push_error("Field bottom_row radius must be > 0")
	if bounce_multiplier <= 0.0:
		push_error("Field bottom_row bounce_multiplier must be > 0")
	if max_ball_speed <= 0.0:
		push_error("Field bottom_row max_ball_speed must be > 0")
	if count > 1 and right <= left:
		push_error("Field bottom_row bounds are invalid")


func _validate_overload_config(data: Dictionary) -> Dictionary:
	var config: Dictionary = data.get("overload", {})
	var required_fields := [
		"enabled",
		"trigger_threshold",
		"pity_rounds",
		"overload_duration_rounds",
		"charge_per_hit",
		"overload_weight_multiplier",
		"overload_damage_multiplier",
		"gauge",
		"presentation",
		"sfx",
	]
	if typeof(config) != TYPE_DICTIONARY:
		push_error("Missing overload config in Data/overload.json")
		return {}
	for field in required_fields:
		if not config.has(field):
			push_error("Missing overload config field: %s" % field)

	var threshold := int(config.get("trigger_threshold", 0))
	var pity_rounds := int(config.get("pity_rounds", 0))
	var duration_rounds := int(config.get("overload_duration_rounds", 0))
	if threshold <= 0:
		push_error("overload.trigger_threshold must be > 0")
	if pity_rounds < 0:
		push_error("overload.pity_rounds must be >= 0")
	if duration_rounds <= 0:
		push_error("overload.overload_duration_rounds must be > 0")
	if float(config.get("overload_damage_multiplier", 0.0)) <= 0.0:
		push_error("overload.overload_damage_multiplier must be > 0")

	var charge_per_hit: Dictionary = config.get("charge_per_hit", {})
	for peg_id in charge_per_hit.keys():
		var id := String(peg_id)
		if not pegs_by_id.has(id):
			push_error("overload charge peg id not found: %s" % id)
		if int(charge_per_hit[peg_id]) < 0:
			push_error("overload charge must be >= 0: %s" % id)

	var weight_multiplier: Dictionary = config.get("overload_weight_multiplier", {})
	for peg_id in weight_multiplier.keys():
		var id := String(peg_id)
		if not pegs_by_id.has(id):
			push_error("overload weight peg id not found: %s" % id)
		if float(weight_multiplier[peg_id]) <= 0.0:
			push_error("overload weight multiplier must be > 0: %s" % id)

	var gauge: Dictionary = config.get("gauge", {})
	if float(gauge.get("tier1_ratio", 0.0)) <= 0.0 or float(gauge.get("tier1_ratio", 0.0)) >= 1.0:
		push_error("overload.gauge.tier1_ratio must be between 0 and 1")
	if float(gauge.get("tier2_ratio", 0.0)) <= float(gauge.get("tier1_ratio", 0.0)) or float(gauge.get("tier2_ratio", 0.0)) >= 1.0:
		push_error("overload.gauge.tier2_ratio must be above tier1 and below 1")

	return config.duplicate(true)


func _validate_upgrades(data: Dictionary) -> void:
	var meta: Dictionary = data.get("_meta", {})
	var stat_targets: Array = meta.get("stat_targets", [])
	for item in upgrades:
		var upgrade := item as Dictionary
		var target_type := String(upgrade["target_type"])
		var target_id := String(upgrade["target_id"])
		match target_type:
			"peg":
				if not pegs_by_id.has(target_id):
					push_error("Upgrade target peg not found: %s" % target_id)
			"ball":
				if not balls_by_id.has(target_id):
					push_error("Upgrade target ball not found: %s" % target_id)
			"stat":
				if not stat_targets.has(target_id):
					push_error("Upgrade target stat not allowed: %s" % target_id)
			_:
				push_error("Unknown upgrade target_type: %s" % target_type)

extends Node

var pegs_by_id: Dictionary = {}
var balls: Array = []
var balls_by_id: Dictionary = {}
var enemies: Array = []
var upgrades: Array = []
var player_config: Dictionary = {}
var feel_config: Dictionary = {}
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

	pegs_by_id = _index_collection(pegs_data, "pegs", ["id", "name", "base_damage", "effect_type", "effect_value"])
	balls = _validate_collection(balls_data, "balls", ["id", "name", "effect_type", "effect_value", "unlocked_by_default"])
	balls_by_id = _index_array(balls, "balls")
	enemies = _validate_collection(enemies_data, "enemies", ["id", "name", "type", "hp", "attack", "description", "dialogue"])
	upgrades = _validate_collection(upgrades_data, "upgrades", ["id", "name", "target_type", "target_id", "effect_type", "effect_value", "rarity"])
	player_config = _validate_player_config(player_data)
	feel_config = _validate_feel_config(feel_data)
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


func _validate_player_config(data: Dictionary) -> Dictionary:
	var config: Dictionary = data.get("player", {})
	var required_fields := [
		"max_hp",
		"balls_per_round",
		"starting_ball_id",
		"ball_timeout_seconds",
		"launch_speed",
		"ball_radius",
		"ball_gravity_scale",
		"ball_bounce",
		"ball_friction",
	]

	if typeof(config) != TYPE_DICTIONARY:
		push_error("Missing player config in Data/player.json")
		return {}

	for field in required_fields:
		if not (config as Dictionary).has(field):
			push_error("Missing player config field: %s" % field)

	return (config as Dictionary).duplicate(true)


func _validate_feel_config(data: Dictionary) -> Dictionary:
	var config: Dictionary = data.get("feel", {})
	var required_fields := [
		"peg_rehit_cooldown_seconds",
		"shake",
		"particles",
		"trail",
		"floating_text",
		"sfx",
		"hp_tween_duration",
	]

	if typeof(config) != TYPE_DICTIONARY:
		push_error("Missing feel config in Data/feel.json")
		return {}

	for field in required_fields:
		if not config.has(field):
			push_error("Missing feel config field: %s" % field)

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

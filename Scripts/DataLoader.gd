extends Node

var pegs_by_id: Dictionary = {}
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
	balls_by_id = _index_collection(balls_data, "balls", ["id", "name", "effect_type", "effect_value"])
	enemies = _validate_collection(enemies_data, "enemies", ["id", "name", "type", "hp", "attack", "description", "dialogue"])
	upgrades = _validate_collection(upgrades_data, "upgrades", ["id", "name", "target_type", "target_id", "effect_type", "effect_value", "rarity"])
	player_config = _validate_player_config(player_data)
	feel_config = _validate_feel_config(feel_data)
	loaded = true


func get_peg(peg_id: String) -> Dictionary:
	return pegs_by_id.get(peg_id, {}).duplicate(true)


func get_ball(ball_id: String) -> Dictionary:
	return balls_by_id.get(ball_id, {}).duplicate(true)


func get_enemy(index: int) -> Dictionary:
	if index < 0 or index >= enemies.size():
		push_error("Enemy index out of range: %s" % index)
		return {}
	return (enemies[index] as Dictionary).duplicate(true)


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
	var indexed := {}
	for item in _validate_collection(data, key, required_fields):
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
		"reward_advance_delay_seconds",
	]

	if typeof(config) != TYPE_DICTIONARY:
		push_error("Missing feel config in Data/feel.json")
		return {}

	for field in required_fields:
		if not config.has(field):
			push_error("Missing feel config field: %s" % field)

	return config.duplicate(true)

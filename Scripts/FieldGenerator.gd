extends RefCounted

var _rng := RandomNumberGenerator.new()
var _seeded := false


func configure(generator_config: Dictionary) -> void:
	var seed_value: Variant = generator_config.get("seed", null)
	if seed_value == null:
		_rng.randomize()
		_seeded = false
	else:
		_rng.seed = int(seed_value)
		_seeded = true


func build_dynamic_slots(field_config: Dictionary) -> Array:
	var generator: Dictionary = field_config["generator"]
	var slots := []
	var row_count := int(generator["row_count"])
	var top_y := float(generator["top_y"])
	var row_spacing := float(generator["row_spacing"])
	for row in range(row_count):
		var is_wide := row % 2 == 0
		var column_count := int(generator["wide_cols"] if is_wide else generator["narrow_cols"])
		for column in range(column_count):
			slots.append({
				"x": _column_x(generator, column, column_count),
				"y": top_y + float(row) * row_spacing,
			})
	return slots


func build_bottom_slots(field_config: Dictionary) -> Array:
	var bounds: Dictionary = field_config["bounds"]
	var bottom_row: Dictionary = field_config["bottom_row"]
	var slots := []
	var count := int(bottom_row["count"])
	var left := float(bounds["left"])
	var right := float(bounds["right"])
	var y := float(bottom_row["y"])
	var spacing := 0.0
	if count > 1:
		spacing = (right - left) / float(count - 1)
	for index in range(count):
		slots.append({
			"id": String(bottom_row["id"]),
			"x": left + spacing * float(index),
			"y": y,
			"radius": float(bottom_row["radius"]),
			"fixed": true,
		})
	return slots


func roll_dynamic_types(field_config: Dictionary, dynamic_slots: Array, guaranteed_double_count := -1) -> Array:
	var generator: Dictionary = field_config["generator"]
	var default_radius := float(field_config["default_peg_radius"])
	var special_radius: Dictionary = generator.get("special_radius", {})
	var rolled := []
	var guaranteed_indices := _guaranteed_double_indices(dynamic_slots.size(), int(generator.get("guaranteed_double_peg_count", 0)) if guaranteed_double_count < 0 else guaranteed_double_count)
	for index in range(dynamic_slots.size()):
		var slot := dynamic_slots[index] as Dictionary
		var peg_id := "double_peg" if guaranteed_indices.has(index) else _weighted_peg_id(generator["type_weights"])
		rolled.append({
			"id": peg_id,
			"x": float(slot["x"]),
			"y": float(slot["y"]),
			"radius": float(special_radius.get(peg_id, default_radius)),
			"fixed": false,
		})
	return rolled


func _column_x(generator: Dictionary, column: int, column_count: int) -> float:
	var center_x := float(generator["center_x"])
	var col_spacing := float(generator["col_spacing"])
	return center_x + (float(column) - (float(column_count - 1) * 0.5)) * col_spacing


func _weighted_peg_id(type_weights: Dictionary) -> String:
	var total_weight := 0
	for peg_id in type_weights.keys():
		total_weight += int(type_weights[peg_id])
	var roll := _rng.randi_range(1, total_weight)
	var running := 0
	for peg_id in type_weights.keys():
		running += int(type_weights[peg_id])
		if roll <= running:
			return String(peg_id)
	return String(type_weights.keys()[0])


func _guaranteed_double_indices(slot_count: int, requested_count: int) -> Dictionary:
	var indices := {}
	var target_count = clamp(requested_count, 0, slot_count)
	while indices.size() < target_count:
		indices[_rng.randi_range(0, slot_count - 1)] = true
	return indices

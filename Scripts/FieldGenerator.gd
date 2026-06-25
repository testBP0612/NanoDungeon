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


func build_dynamic_cells(field_config: Dictionary) -> Array:
	var generator: Dictionary = field_config["generator"]
	var cells := []
	var row_count := int(generator["row_count"])
	var top_y := float(generator["top_y"])
	var row_spacing := float(generator["row_spacing"])
	var default_radius := float(field_config["default_peg_radius"])
	for row in range(row_count):
		var is_wide := row % 2 == 0
		var column_count := int(generator["wide_cols"] if is_wide else generator["narrow_cols"])
		for column in range(column_count):
			var x := _column_x(generator, column, column_count)
			var y := top_y + float(row) * row_spacing
			if _is_inside_launch_lane(field_config, x, y, default_radius):
				continue
			cells.append({
				"x": x,
				"y": y,
			})
	return cells


func build_bottom_cells(field_config: Dictionary) -> Array:
	var bounds: Dictionary = field_config["bounds"]
	var bottom_row: Dictionary = field_config["bottom_row"]
	var cells := []
	var count := int(bottom_row["count"])
	var left := float(bounds["left"])
	var radius := float(bottom_row["radius"])
	var right := _peg_generation_right(field_config, radius)
	var y := float(bottom_row["y"])
	var spacing := 0.0
	if count > 1:
		spacing = (right - left) / float(count - 1)
	for index in range(count):
		cells.append({
			"id": String(bottom_row["id"]),
			"x": left + spacing * float(index),
			"y": y,
			"radius": radius,
			"fixed": true,
		})
	return cells


func roll_dynamic_types(field_config: Dictionary, dynamic_cells: Array, guaranteed_double_count := -1, weight_multiplier := {}) -> Array:
	var generator: Dictionary = field_config["generator"]
	var default_radius := float(field_config["default_peg_radius"])
	var special_radius: Dictionary = generator.get("special_radius", {})
	var type_weights := _weighted_type_pool(generator["type_weights"], weight_multiplier)
	var rolled := []
	var guaranteed_indices := _guaranteed_double_indices(dynamic_cells.size(), int(generator.get("guaranteed_double_peg_count", 0)) if guaranteed_double_count < 0 else guaranteed_double_count)
	for index in range(dynamic_cells.size()):
		var cell := dynamic_cells[index] as Dictionary
		var peg_id := "double_peg" if guaranteed_indices.has(index) else _weighted_peg_id(type_weights)
		rolled.append({
			"id": peg_id,
			"x": float(cell["x"]),
			"y": float(cell["y"]),
			"radius": float(special_radius.get(peg_id, default_radius)),
			"fixed": false,
		})
	return rolled


func _weighted_type_pool(type_weights: Dictionary, weight_multiplier: Dictionary) -> Dictionary:
	var weighted := {}
	for peg_id in type_weights.keys():
		var id := String(peg_id)
		var multiplier := float(weight_multiplier.get(id, 1.0))
		weighted[id] = max(1, int(round(float(type_weights[peg_id]) * multiplier)))
	return weighted


func _column_x(generator: Dictionary, column: int, column_count: int) -> float:
	var center_x := float(generator["center_x"])
	var col_spacing := float(generator["col_spacing"])
	return center_x + (float(column) - (float(column_count - 1) * 0.5)) * col_spacing


func _peg_generation_right(field_config: Dictionary, radius: float) -> float:
	var bounds: Dictionary = field_config["bounds"]
	var right := float(bounds["right"])
	var launch_lane: Dictionary = field_config.get("launch_lane", {})
	if launch_lane.is_empty():
		return right
	var clearance := float(launch_lane.get("peg_clearance", 0.0))
	return min(right, float(launch_lane["left"]) - radius - clearance)


func _is_inside_launch_lane(field_config: Dictionary, x: float, y: float, radius: float) -> bool:
	var launch_lane: Dictionary = field_config.get("launch_lane", {})
	if launch_lane.is_empty():
		return false
	var clearance := float(launch_lane.get("peg_clearance", 0.0))
	var left := float(launch_lane["left"]) - radius - clearance
	var right := float(launch_lane["right"]) + radius + clearance
	var top := float(launch_lane["top"]) - radius - clearance
	var bottom := float(launch_lane["bottom"]) + radius + clearance
	return x >= left and x <= right and y >= top and y <= bottom


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


func _guaranteed_double_indices(cell_count: int, requested_count: int) -> Dictionary:
	var indices := {}
	var target_count = clamp(requested_count, 0, cell_count)
	while indices.size() < target_count:
		indices[_rng.randi_range(0, cell_count - 1)] = true
	return indices

extends RefCounted

const FONT_PATH := "res://assets/fonts/JiangChengJianRenHei.ttf"


static func apply_to(root: Control, config: Dictionary = {}) -> void:
	if root == null:
		return
	if not ResourceLoader.exists(FONT_PATH):
		return
	var font := load(FONT_PATH) as FontFile
	if font == null:
		return
	_apply_font_recursive(root, font, int(config.get("default_font_size", 20)))


static func _apply_font_recursive(node: Node, font: FontFile, default_size: int) -> void:
	if node is Label or node is Button or node is ProgressBar or node is RichTextLabel:
		var control := node as Control
		control.add_theme_font_override("font", font)
		if not control.has_theme_font_size_override("font_size"):
			control.add_theme_font_size_override("font_size", default_size)
	for child in node.get_children():
		_apply_font_recursive(child, font, default_size)

extends Control

const UPGRADE_RESOLVER_SCRIPT := preload("res://Scripts/UpgradeResolver.gd")

var upgrade_resolver: RefCounted = UPGRADE_RESOLVER_SCRIPT.new()
var options: Array = []
var feel_config: Dictionary = {}

@onready var subtitle_label: Label = $Root/SubtitleLabel
@onready var card_0: Button = $Root/CardRow/Card0
@onready var card_1: Button = $Root/CardRow/Card1
@onready var card_2: Button = $Root/CardRow/Card2
@onready var continue_button: Button = $Root/ContinueButton


func _ready() -> void:
	RunState.ensure_run_started()
	feel_config = DataLoader.get_feel_config()
	options = upgrade_resolver.draw_upgrade_options(RunState.pending_upgrade_enemy_type)
	_connect_buttons()
	_refresh_ui()
	await get_tree().process_frame
	for card in [card_0, card_1, card_2]:
		(card as Button).pivot_offset = (card as Button).size * 0.5


func _connect_buttons() -> void:
	card_0.pressed.connect(_choose_option.bind(0))
	card_1.pressed.connect(_choose_option.bind(1))
	card_2.pressed.connect(_choose_option.bind(2))
	for card in [card_0, card_1, card_2]:
		(card as Button).mouse_entered.connect(_animate_card_hover.bind(card, true))
		(card as Button).mouse_exited.connect(_animate_card_hover.bind(card, false))
	continue_button.pressed.connect(_go_next_battle)
	continue_button.visible = false


func _refresh_ui() -> void:
	subtitle_label.text = "擊敗 %s 敵人，選擇 1 個升級" % RunState.pending_upgrade_enemy_type.to_upper()
	var cards := [card_0, card_1, card_2]
	for index in cards.size():
		var card := cards[index] as Button
		if index >= options.size():
			card.visible = false
			continue
		var upgrade := options[index] as Dictionary
		card.visible = true
		card.disabled = false
		_apply_card_style(card, String(upgrade["rarity"]))
		card.text = "%s\n[%s]\n%s" % [
			String(upgrade["name"]),
			String(upgrade["rarity"]).to_upper(),
			String(upgrade["description"]),
		]


func _choose_option(index: int) -> void:
	if index < 0 or index >= options.size():
		return
	upgrade_resolver.apply_upgrade(options[index] as Dictionary)
	var selected := options[index] as Dictionary
	subtitle_label.text = "已選擇：%s" % String(selected["name"])
	_animate_card_selected(([card_0, card_1, card_2][index] as Button))
	for card in [card_0, card_1, card_2]:
		(card as Button).disabled = true
	continue_button.visible = true


func _apply_card_style(card: Button, rarity: String) -> void:
	var rarity_color := _rarity_color(rarity)
	card.add_theme_color_override("font_color", Color(0.94, 0.98, 1.0))
	card.add_theme_color_override("font_hover_color", rarity_color)
	card.add_theme_color_override("font_pressed_color", Color.WHITE)
	card.add_theme_color_override("font_disabled_color", rarity_color)
	for state in ["normal", "hover", "pressed", "disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.025, 0.035, 0.06, 0.96)
		style.border_color = rarity_color
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		style.corner_radius_top_left = 6
		style.corner_radius_top_right = 6
		style.corner_radius_bottom_left = 6
		style.corner_radius_bottom_right = 6
		if state == "hover":
			style.bg_color = Color(0.04, 0.06, 0.09, 1.0)
		if state == "pressed":
			style.bg_color = Color(0.06, 0.08, 0.11, 1.0)
		if state == "disabled":
			style.bg_color = Color(0.02, 0.03, 0.045, 0.86)
		card.add_theme_stylebox_override(state, style)


func _rarity_color(rarity: String) -> Color:
	match rarity:
		"legendary":
			return Color(1.0, 0.78, 0.24)
		"rare":
			return Color(0.18, 0.75, 1.0)
		_:
			return Color(0.22, 1.0, 0.55)


func _go_next_battle() -> void:
	RunState.current_battle_index = min(RunState.current_battle_index + 1, DataLoader.enemies.size() - 1)
	SceneTransition.change_scene("res://Scenes/Battle.tscn")


func _animate_card_hover(card: Button, hovered: bool) -> void:
	if card.disabled:
		return
	var config: Dictionary = feel_config.get("upgrade_card", {})
	var target_scale := Vector2.ONE * (float(config.get("hover_scale", 1.04)) if hovered else 1.0)
	var tween := create_tween()
	tween.tween_property(card, "scale", target_scale, float(config.get("hover_seconds", 0.1)))


func _animate_card_selected(card: Button) -> void:
	var config: Dictionary = feel_config.get("upgrade_card", {})
	var pulse_scale := Vector2.ONE * float(config.get("select_pulse_scale", 1.08))
	var pulse_seconds := float(config.get("select_pulse_seconds", 0.16))
	var tween := create_tween()
	tween.tween_property(card, "scale", pulse_scale, pulse_seconds)
	tween.tween_property(card, "scale", Vector2.ONE, pulse_seconds)

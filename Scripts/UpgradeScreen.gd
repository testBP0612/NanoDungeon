extends Control

const UPGRADE_RESOLVER_SCRIPT := preload("res://Scripts/UpgradeResolver.gd")

var upgrade_resolver: RefCounted = UPGRADE_RESOLVER_SCRIPT.new()
var options: Array = []

@onready var subtitle_label: Label = $Root/SubtitleLabel
@onready var card_0: Button = $Root/CardRow/Card0
@onready var card_1: Button = $Root/CardRow/Card1
@onready var card_2: Button = $Root/CardRow/Card2
@onready var continue_button: Button = $Root/ContinueButton


func _ready() -> void:
	RunState.ensure_run_started()
	options = upgrade_resolver.draw_upgrade_options(RunState.pending_upgrade_enemy_type)
	_connect_buttons()
	_refresh_ui()


func _connect_buttons() -> void:
	card_0.pressed.connect(_choose_option.bind(0))
	card_1.pressed.connect(_choose_option.bind(1))
	card_2.pressed.connect(_choose_option.bind(2))
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
	for card in [card_0, card_1, card_2]:
		(card as Button).disabled = true
	continue_button.visible = true


func _go_next_battle() -> void:
	RunState.current_battle_index = min(RunState.current_battle_index + 1, DataLoader.enemies.size() - 1)
	get_tree().change_scene_to_file("res://Scenes/Battle.tscn")

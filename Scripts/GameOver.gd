extends Control

@onready var summary_label: Label = $Root/SummaryLabel
@onready var restart_button: Button = $Root/RestartButton
@onready var menu_button: Button = $Root/MenuButton


func _ready() -> void:
	summary_label.text = "到達場次：%s / %s\n擊殺數：%s\n最終 HP：%s / %s\n%s" % [
		RunState.current_battle_index + 1,
		DataLoader.enemies.size(),
		RunState.kills,
		RunState.player_hp,
		RunState.player_max_hp,
		RunState.build_summary(),
	]
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)


func _on_restart_pressed() -> void:
	RunState.reset_new_run()
	get_tree().change_scene_to_file("res://Scenes/Battle.tscn")


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

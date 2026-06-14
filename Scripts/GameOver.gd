extends Control

const UI_THEME_SCRIPT := preload("res://Scripts/UITheme.gd")

@onready var summary_label: Label = $Root/SummaryLabel
@onready var restart_button: Button = $Root/RestartButton
@onready var menu_button: Button = $Root/MenuButton


func _ready() -> void:
	UI_THEME_SCRIPT.apply_to($Root)
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
	SceneTransition.change_scene("res://Scenes/Battle.tscn")


func _on_menu_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/MainMenu.tscn")

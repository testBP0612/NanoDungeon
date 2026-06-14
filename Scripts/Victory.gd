extends Control

const UI_THEME_SCRIPT := preload("res://Scripts/UITheme.gd")

@onready var summary_label: Label = $Root/SummaryLabel
@onready var restart_button: Button = $Root/RestartButton
@onready var menu_button: Button = $Root/MenuButton

func _ready() -> void:
	UI_THEME_SCRIPT.apply_to($Root)
	summary_label.text = "剩餘 HP：%s / %s\n擊殺數：%s\n用時：%s 秒\n%s" % [
		RunState.player_hp,
		RunState.player_max_hp,
		RunState.kills,
		int(RunState.get_elapsed_seconds()),
		RunState.build_summary(),
	]
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)


func _on_restart_pressed() -> void:
	RunState.reset_new_run()
	SceneTransition.change_scene("res://Scenes/Battle.tscn")


func _on_menu_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/MainMenu.tscn")

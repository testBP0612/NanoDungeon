extends Control

@onready var summary_label: Label = $Root/SummaryLabel
@onready var restart_button: Button = $Root/RestartButton
@onready var menu_button: Button = $Root/MenuButton

func _ready() -> void:
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
	get_tree().change_scene_to_file("res://Scenes/Battle.tscn")


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

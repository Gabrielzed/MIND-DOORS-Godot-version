extends Control

@onready var options_panel = $OptionsPanel

func _ready():
	$VBoxContainer/StartButton.pressed.connect(start_game)
	$VBoxContainer/OptionsButton.pressed.connect(open_options)
	$VBoxContainer/ExitButton.pressed.connect(exit_game)

func start_game():
	get_tree().change_scene_to_file("res://cenas/Teste.tscn")

func open_options():
	options_panel.visible = true

func exit_game():
	get_tree().quit()

extends Control

@onready var animation_player = $AnimationPlayer
@onready var hover_sound = $HoverSound
@onready var click_sound = $ClickSound

func _ready():
	# Sons de hover e clique
	for button in $VBoxContainer.get_children():
		button.mouse_entered.connect(_on_button_hover)
		button.pressed.connect(_on_button_click)

	# Funções específicas dos botões
	$VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$VBoxContainer/ExitButton.pressed.connect(_on_exit_pressed)

func _on_button_hover():
	hover_sound.play()

func _on_button_click():
	click_sound.play()

func _on_start_pressed():
	# Espera o som de clique tocar um pouco
	await get_tree().create_timer(0.1).timeout

	animation_player.play("fade_out")

	await animation_player.animation_finished

	get_tree().change_scene_to_file("res://cenas/Teste.tscn")

func _on_exit_pressed():
	await get_tree().create_timer(0.1).timeout
	get_tree().quit()

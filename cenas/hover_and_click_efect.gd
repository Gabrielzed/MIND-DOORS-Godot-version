extends Control

@onready var hover_sound = $HoverSound
@onready var click_sound = $ClickSound

func _ready():

	for button in $VBoxContainer.get_children():

		button.mouse_entered.connect(_on_button_hover)

		button.pressed.connect(_on_button_click)

func _on_button_hover():
	hover_sound.play()

func _on_button_click():
	click_sound.play()

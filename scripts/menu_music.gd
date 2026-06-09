extends AudioStreamPlayer2D


func _ready():
	volume_db = -20
	play()

	var tween = create_tween()
	tween.tween_property(self, "volume_db", 2, 3.0)

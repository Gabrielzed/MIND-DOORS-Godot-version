extends Label

func _process(_delta):
	text = "FPS: %d\nMemória: %.2f MB" % [
		Engine.get_frames_per_second(),
		Performance.get_monitor(Performance.MEMORY_STATIC) / 1024.0 / 1024.0
	]

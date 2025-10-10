extends AudioStreamPlayer

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("space") and not self.playing:
		play(0)

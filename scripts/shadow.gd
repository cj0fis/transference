extends MeshInstance3D

func _physics_process(delta: float) -> void:
	global_position = get_parent().global_position
	global_position.y = 0.1

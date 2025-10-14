extends BTAction

func _tick(_delta: float) -> Status:
	if CharacterController.active_char:
		blackboard.set_var("target_position", CharacterController.active_char.global_position)
		return SUCCESS
	return FAILURE

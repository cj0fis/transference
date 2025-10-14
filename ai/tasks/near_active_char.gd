extends BTAction

@export var distance: int = 16

func _tick(delta: float) -> Status:
	if CharacterController.active_char and CharacterController.active_char.global_position.distance_to(agent.global_position) <= distance:
		return SUCCESS
	return FAILURE

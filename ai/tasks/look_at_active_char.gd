extends BTAction

func _tick(delta: float) -> Status:
	if agent is not Character3D:
		return FAILURE
	var movement_component: MovementComponent = agent.get_component(MovementComponent)
	movement_component.look_mode = MovementComponent.LookMode.NODE
	movement_component.target_node = CharacterController.active_char
	
	return SUCCESS

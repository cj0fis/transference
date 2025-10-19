extends BTAction

func _tick(delta: float) -> Status:
	if agent is not Character3D:
		return FAILURE
	var state_component: StateComponent = agent.get_component(StateComponent)
	if state_component == null:
		return FAILURE
		
	state_component.enter_normal_stance()
	return SUCCESS

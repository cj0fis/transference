extends BTAction
var move_component: MovementComponent

func _enter() -> void:
	if agent is not Character3D:
		move_component = null
		return
	move_component = agent.get_component(MovementComponent)

func _tick(_delta: float) -> Status:
	if move_component.target_reached == false:
		return RUNNING
	return SUCCESS

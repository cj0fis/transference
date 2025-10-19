extends BTAction
@export var position_var: StringName
var move_component: MovementComponent

func _enter() -> void:
	if agent is not Character3D:
		move_component = null
		return
	move_component = agent.get_component(MovementComponent)


func _tick(delta: float) -> Status:
	if not move_component:
		return FAILURE
	move_component.move_to_pos(blackboard.get_var(position_var), 0.1)
	return SUCCESS

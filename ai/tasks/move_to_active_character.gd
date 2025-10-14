extends BTAction
@export var distance: float
var move_component: MovementComponent

func _enter() -> void:
	if agent is not Character3D:
		move_component = null
		return
	move_component = agent.get_component(MovementComponent)


func _tick(delta: float) -> Status:
	if not move_component:
		return FAILURE
	move_component.follow_target(CharacterController.active_char, distance)
	return SUCCESS

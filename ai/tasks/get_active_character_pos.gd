extends BTAction
@export var output_var: StringName

func _tick(_delta: float) -> Status:
	if CharacterController.active_char:
		blackboard.set_var(output_var, CharacterController.active_char.global_position)
		return SUCCESS
	return FAILURE

extends BTAction

@export var output_var: StringName

func _tick(_delta: float) -> Status:
	blackboard.set_var(output_var, agent.global_position)
	return SUCCESS

extends BTAction

@export var min_distance: float = 2.0
@export var max_distance: float = 4.0
@export var origin_var: StringName	##if null, the origin will be the agent's position
@export var output_var: StringName

func _tick(_delta: float) -> Status:
	var origin_pos = blackboard.get_var(origin_var) if origin_var else (agent.global_position if agent is Character3D else Vector3.ZERO)
	
	var angle = randf_range(0, PI)
	var target_pos = origin_pos + Vector3(cos(angle), 0, sin(angle)) * randf_range(min_distance,max_distance)
	blackboard.set_var(output_var, target_pos)
	return SUCCESS

extends State

@export var move_state: State

func enter(_old_state: State = null) -> void:
	super()
	#parent.velocity = Vector3.ZERO
	#parent.animation_tree.get("parameters/playback").travel("idle")
	parent.animation_tree.set("parameters/movement/transition_request", "idle")

func process_physics(_delta: float) -> State:
	if parent.velocity.x != 0 or parent.velocity.z != 0:
		return move_state
	return null

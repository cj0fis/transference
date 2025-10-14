extends State

@export var idle_state: State

func enter(_old_state: State = null) -> void:
	super()
	#parent.velocity = Vector3.ZERO
	#parent.animation_tree.get("parameters/playback").travel("run")
	parent.animation_tree.set("parameters/movement/transition_request", "move")

func process_physics(_delta: float) -> State:
	if parent.velocity.x == 0 and parent.velocity.z == 0:
		return idle_state
		
	return null

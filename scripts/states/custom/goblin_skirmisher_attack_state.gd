extends State

@export var idle_state: State

var previous_state: State
var left = true
var queue_next_state: bool = false

var left_cooldown: float = 0.0
var right_cooldown: float = 0.0
var time_left: float
var cooldown = 0.25
var attack_duration = 0.75

func enter(_old_state: State = null) -> void:
	super()
	parent.get_component(MovementComponent).move_lock = true
	#print(parent.animation_tree.tree_root.get_node_list())
	if _old_state != self:
		previous_state = _old_state
	time_left = attack_duration
	parent.velocity = Vector3.ZERO
	parent.animation_tree.set("parameters/stance/transition_request", "attack")
	#parent.animation_tree.get("parameters/playback").travel("attack")
	#parent.animation_tree.set("parameters/")
	#if left and not parent.animation_tree.get("parameters/attack/left/active"):
		#parent.animation_tree.set("parameters/attack/left/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		#parent.animation_tree.set("parameters/", AnimationNodeOneShot)
		#left = false
		#left_cooldown = cooldown
		#time_left = attack_duration
	#elif not left and not parent.animation_tree.get("parameters/attack/right/active"):
		#parent.animation_tree.set("parameters/attack/right/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		#left = true
		#right_cooldown = cooldown
		#time_left = attack_duration
		
func exit() -> void:
	parent.get_component(MovementComponent).move_lock = false
	parent.animation_tree.set("parameters/stance/transition_request", "normal")

	
func process_physics(_delta: float) -> State:
	if time_left > 0:
		time_left -= _delta
	if left_cooldown > 0:
		left_cooldown -= _delta
	if right_cooldown > 0:
		right_cooldown -= _delta
	if time_left <= 0:
		return previous_state
	return null

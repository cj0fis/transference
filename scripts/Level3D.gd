class_name Level3D extends Node3D

@export var game_state_persists: bool = true	#if true, the state of this Level3D will persist after loading


##this function is called when a scene is exited and it won't persist
func exit() -> void:
	pass
	
func enter() -> void:
	pass

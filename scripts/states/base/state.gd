@icon("res://assets/icons/State.svg")
class_name State extends Node


var parent: Character3D = null

##like the _ready() function, but will be called by the state machine
func init() -> void:
	pass

func enter(_old_state: State = null) -> void:
	pass
	
func exit() -> void:
	pass
	
func process_input(_event: InputEvent) -> State:
	return null
	
func process_frame(_delta: float) -> State:
	return null
	
func process_physics(_delta: float) -> State:
	return null

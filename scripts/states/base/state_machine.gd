@icon("res://assets/icons/StateMachine.svg")
class_name StateMachine extends Node

@export var starting_state: State = null
@export var enter_state_on_start: bool = true

var current_state: State = null

var movement_lock: bool = false

func _ready() -> void:
	var parent: Character3D
	if get_parent() is Character3D:
		parent = get_parent()
	else:
		GlobalManager.log_error("StateMachine must be a child of a Character3D")
		return
	for child in get_children():
		if child is State:
			child.parent = get_parent()
			child.init()
		else:
			GlobalManager.log_error("child '" + child.name + "' is not of type State")
	change_state(starting_state)
	
func change_state(new_state: State) -> void:
	if current_state:
		current_state.exit()
	if not new_state:
		GlobalManager.log_error("Cannot change state: new state is null")
		return
	var old_state = current_state
	if old_state:
		GlobalManager.log_state(old_state.name + " -> " + new_state.name)
		
	current_state = new_state
	if old_state or enter_state_on_start:
		current_state.enter(old_state)
		
func get_state_by_name(state_name: String) -> State:
	for child in get_children():
		if child is State and child.name == state_name:
			return child
	GlobalManager.log_error("Could not find state with name: " + state_name)
	return null
		
		
		
func process_physics(delta: float) -> void:
	var new_state = current_state.process_physics(delta)
	if new_state:
		change_state(new_state)

func process_input(event: InputEvent) -> void:
	var new_state = current_state.process_input(event)
	if new_state:
		change_state(new_state)
	
func process_frame(delta: float) -> void:
	var new_state = current_state.process_frame(delta)
	if new_state:
		change_state(new_state)

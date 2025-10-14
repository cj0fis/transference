@tool
class_name Character3D extends CharacterBody3D

@export var mesh: MeshInstance3D = null
@export var animation_tree: AnimationTree
var state_machine: StateMachine
var is_mouse_over: bool = false		#true if the mouse is over this character's mesh

var use_ai: bool = true

func _ready() -> void:
	set_character_effect_material()
	if not Engine.is_editor_hint() and not CharacterController.active_char:
		CharacterController.bodyswap(self)
		CharacterController.enabled = true
	add_to_group("characters")
	for child in get_children():
		if child is StateMachine:
			state_machine = child
	
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if state_machine:
		state_machine.process_physics(delta)
	
	

func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if state_machine:
		state_machine.process_input(event)
		
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if state_machine:
		state_machine.process_frame(delta)


#calling this function makes this character the active character
func make_active_char() -> void:
	CharacterController.bodyswap(self)

	
func get_component(component_class):
	for child in get_children():
		if is_instance_of(child, component_class):
			return child
	return null
	
func set_character_effect_material() -> void:
	if mesh:
		mesh.material_override = preload("uid://bu3h0pgv0m52y").duplicate_deep()

func play_spawn_animation() -> void:
	pass
	
func play_death_animation() -> void:
	pass

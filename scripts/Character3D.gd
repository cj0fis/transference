@tool
class_name Character3D extends CharacterBody3D

@export var speed: float = 4.0
@export var mesh: MeshInstance3D = null


var is_mouse_over: bool = false		#true if the mouse is over this character's mesh

func _ready() -> void:
	set_character_effect_material()
	if not Engine.is_editor_hint() and not CharacterController.active_char:
		CharacterController.bodyswap(self)
		CharacterController.enabled = true
	
	add_to_group("characters")
	
	
func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	#CharacterController handles movement for this
	#apply gravity
	#if not is_on_floor():
		#velocity.y = -5
	#else:
		#velocity.y = 0
	velocity.y = 0
	move_and_slide()
	
#calling this function makes this character the active character
func make_active_char() -> void:
	CharacterController.bodyswap(self)



##TODO: this implementation of an attack state is janky, fix this up to be more robust
var attack_state: bool = false
#set attack_state = true to put this character into attack state
func is_attacking() -> bool:
	
	if attack_state == true:
		attack_state = false
		return true
	return false
	
	
func get_component(component_class):
	for child in get_children():
		if is_instance_of(child, component_class):
			return child
	return null
	
func set_character_effect_material() -> void:
	if mesh:
		mesh.material_override = preload("uid://bu3h0pgv0m52y").duplicate_deep()

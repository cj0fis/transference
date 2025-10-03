
class_name Character3D extends CharacterBody3D

@export var speed: float = 4.0


var is_mouse_over: bool = false		#true if the mouse is over this character's mesh

func _ready() -> void:
	if not CharacterController.active_char:
		CharacterController.bodyswap(self)
		CharacterController.enabled = true
	mouse_entered.connect(_on_mouse_enter)
	mouse_exited.connect(_on_mouse_exit)
	add_to_group("characters")
	
func _physics_process(_delta: float) -> void:
	#CharacterController handles movement for this
	move_and_slide()
	if Input.is_action_just_pressed("left_click") and is_mouse_over:
		make_active_char()
	
		
	
#calling this function makes this character the active character
func make_active_char() -> void:
	CharacterController.bodyswap(self)

func _on_mouse_enter() -> void:
	is_mouse_over = true
	
	
func _on_mouse_exit() -> void:
	is_mouse_over = false

var attack_state: bool = false
#set attack_state = true to put this character into attack state
func is_attacking() -> bool:
	if attack_state == true:
		attack_state = false
		return true
	return false
	

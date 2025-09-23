class_name Character extends CharacterBody2D

@export var move_speed: int = 24

var is_selected: bool = false

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("left_click") and is_selected:
		_on_click()
	
	move_and_slide()
	
func _ready() -> void:
	if not CharacterController.active_char:
		CharacterController.active_char = self
		CharacterController.enabled = true
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	

func _on_mouse_entered() -> void:
	is_selected = true

func _on_mouse_exited() -> void:
	is_selected = false
	
func _on_click() -> void:
	print("character clicked!")
	CharacterController.active_char = self

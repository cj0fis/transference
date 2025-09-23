extends Node2D


@export var active_char: Character = null:
	set(value):
		if active_char:
			active_char.velocity = Vector2.ZERO
		active_char = value
		print("new active char set!")
		
@export var active_cam: SmartCam = null:
	set(value):
		active_cam = value
		print("new active cam set!")


@export var enabled: bool = false:
	set(value):
		if value and not active_char:
			push_error("Cannot enable character controller when character is null!")
		else:
			enabled = value
		

	
	
	
func _physics_process(delta: float) -> void:
	if not active_char or not enabled:
		return
	var x = Input.get_axis("move_west", "move_east")
	var y = Input.get_axis("move_north", "move_south")
	var new_velocity = Vector2(x,y).normalized() * active_char.move_speed
	active_char.velocity = new_velocity
	

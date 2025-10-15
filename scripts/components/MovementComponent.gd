##this component abstracts moving the character for the CharacterController and AI systems
class_name MovementComponent extends Component

var target: Node3D		#the node that the character will look at when targeting is enabled
var move_mode = "none"


var target_position: Vector3
var target_margin: float = 0.0
var face_target: bool = false	#if true, the character will always rotate to face the target. if false, they will only rotate to match their velocity
var move_lock: bool = false
var rotation_lock: bool = false
@onready var target_rotation: float = parent.rotation.y
##Sets this character's target

@export var move_speed: float = 4.0
@export var ai_move_speed: float = 2.5



#STATE VARS
var is_moving: bool = false		#horizontal movement caused by pathfinding
var is_jumping: bool = false	#moving upward and off the ground
var is_falling: bool = false	#moving downward and off the ground
var is_on_floor: bool = true
var is_midair: bool = false		#off the ground
var just_landed: bool = false	#active during the physics frame where a character lands
signal TARGET_REACHED
var target_reached: bool = true
var was_on_floor: bool = true

##makes the character follow another character and face them
func follow_target(_target: Character3D, margin: float) -> void:
	move_mode = "follow"
	face_target = true
	target = _target
	target_margin = margin
	
func stop_following() -> void:
	move_mode = "none"
	face_target = false
	target = null
	
##makes the character move to a position
func move_to_pos(pos: Vector3, margin: float) -> void:
	stop_following()
	move_mode = "position"
	face_target = true
	target_position = pos
	target_margin = margin

func jump() -> void:
	if is_midair:
		return
	var jump_direction = -parent.global_transform.basis.z
	move_mode = "none"
	parent.velocity = jump_direction * 4
	parent.velocity.y  = 1.5

	
func jump_backwards() -> void:
	if is_midair:
		return
	var jump_direction = parent.global_transform.basis.z
	move_mode = "none"
	target_position = parent.global_position
	face_target = true
	parent.velocity = jump_direction * 4
	parent.velocity.y  = 1.5



func look_at() -> void:
	pass

func _physics_process(delta: float) -> void:
	var speed = ai_move_speed if parent.use_ai else move_speed
	is_on_floor = parent.is_on_floor()
	
	if move_mode == "follow":
		target_position = target.global_position
		
	if move_mode != "none":
		if parent.position.distance_to(target_position) > target_margin and not move_lock:
			parent.velocity = (target_position - parent.global_position).normalized() * speed * Vector3(1,0,1) #dont move in the y direction
		else:
			parent.velocity = Vector3.ZERO
			TARGET_REACHED.emit()
			move_mode = "none"
		#if parent.velocity.length() < speed/2.0:
			#parent.velocity = Vector3.ZERO
			#TARGET_REACHED.emit()
			#target_reached = true
			#target = null
	
	if face_target:
		target_rotation = atan2(target_position.x-parent.global_position.x, target_position.z-parent.global_position.z) + PI
	
	elif is_moving:
		target_rotation = atan2(parent.velocity.x, parent.velocity.z) + PI
		
	if parent.position.distance_to(target_position) > 0.1:
		parent.rotation.y = lerp_angle(parent.rotation.y, target_rotation, 0.2)


	#apply gravity
	#var just_landed = false
	if not is_on_floor:
		parent.velocity.y -= delta * 5
	else:
		if parent.velocity.y < 0:		#y is only negative on the floor if the character just landed. it is safe to set all velocity to 0
			parent.velocity.y = 0

	parent.move_and_slide()
	
	#set state vars
	
	if is_on_floor and not was_on_floor:
		just_landed = true
		
		parent.velocity = Vector3.ZERO;
	else:
		just_landed = false
	was_on_floor = is_on_floor
	
	
	is_moving = parent.velocity.x != 0 or parent.velocity.y != 0
	is_jumping = parent.velocity.y >= 0 and not is_on_floor
	is_falling = parent.velocity.y < 0 and not is_on_floor
	is_midair = not is_on_floor

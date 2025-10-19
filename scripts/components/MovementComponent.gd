##this component abstracts moving the character for the CharacterController and AI systems
class_name MovementComponent extends Component

#var target: Node3D		#the node that the character will look at when targeting is enabled
#var move_mode = "none"


enum LookMode{
	NONE,		## the MovementComponent will not change the character's rotation
	VELOCITY,	## the character will face in the direction that they are moving
	POSITION,	## the character will always face target_position, regardless of if they are moving
	NODE	## the character will always face target_node, regardless of where they are
}
var look_mode: LookMode = LookMode.NONE

enum MoveMode{
	NONE,		## the MovementComponent will not change the character's velocity
	NODE,	## the character will move towards target_character
	POSITION	## the character will move towards target_position
}
var move_mode: MoveMode = MoveMode.NONE

var target_node: Node3D
var target_position: Vector3	#where the character should move to
var target_margin: float = 0.0	#how close the character has to be before they stop
var look_target: Vector3		#where the character should look if look_mode is POSITION

var move_lock: bool = false		#if true, the MovementComponent will not change the character's velocity
var rotation_lock: bool = false	#if true, the MovementCompnent will not change the character's rotation




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
func move_to_char(target: Character3D, margin: float) -> void:
	move_mode = MoveMode.NODE
	look_mode = LookMode.NODE
	target_node = target
	target_margin = margin
	target_reached = false
	
##makes the character move to a position
func move_to_pos(pos: Vector3, margin: float) -> void:
	stop()
	move_mode = MoveMode.POSITION
	look_mode = LookMode.POSITION
	target_position = pos
	target_margin = margin
	target_reached = false

func stop() -> void:
	move_mode = MoveMode.NONE
	look_mode = LookMode.NONE
	target_position = parent.global_position
	target_node = null
	target_reached = true
	
func jump() -> void:
	if is_midair:
		return
	
	move_mode = MoveMode.NONE
	look_mode = LookMode.VELOCITY
	
	var jump_direction = -parent.global_transform.basis.z
	parent.velocity = jump_direction * 4
	parent.velocity.y  = 1.5

	
func jump_backwards() -> void:
	if is_midair:
		return
	
	move_mode = MoveMode.NONE
	var jump_direction = parent.global_transform.basis.z
	parent.velocity = jump_direction * 4
	parent.velocity.y  = 1.5


func _physics_process(delta: float) -> void:
	var speed = ai_move_speed if parent.use_ai else move_speed
	is_on_floor = parent.is_on_floor()
	
	match move_mode:
		MoveMode.NONE:
			pass
		MoveMode.NODE:
			parent.velocity = (target_node.global_position - parent.global_position).normalized() * speed * Vector3(1,0,1)
		MoveMode.POSITION:
			if parent.position.distance_to(target_position) > target_margin and not move_lock:
				parent.velocity = (target_position - parent.global_position).normalized() * speed * Vector3(1,0,1) #dont move in the y direction
			
			else:
				parent.velocity = Vector3.ZERO
				TARGET_REACHED.emit()
				target_reached = true
				stop()
				
			##FIXME: fix this code to detect when a character collides with something and stops moving, and then set the move mode to none
			#if parent.get_real_velocity().length() == 0.0 and parent.velocity.length() != 0:
				#parent.velocity = Vector3.ZERO
				#TARGET_REACHED.emit()
				#target_reached = true
				#move_mode = MoveMode.NONE
			
	
	
	match look_mode:
		LookMode.VELOCITY:
			if parent.velocity.x != 0 or parent.velocity.z != 0:
				var target_rotation = atan2(parent.velocity.x, parent.velocity.z) + PI
				parent.rotation.y = lerp_angle(parent.rotation.y, target_rotation, 0.2)
		LookMode.NODE:
			if target_node:
				var target_rotation = atan2(target_node.global_position.x-parent.global_position.x, target_node.global_position.z-parent.global_position.z) + PI
				parent.rotation.y = lerp_angle(parent.rotation.y, target_rotation, 0.2)
		LookMode.POSITION:
			var target_rotation = atan2(target_position.x-parent.global_position.x, target_position.z-parent.global_position.z) + PI
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
	
	

##this component abstracts moving the character for the CharacterController and AI systems
class_name MovementComponent extends Component

var target: Node3D		#the node that the character will look at when targeting is enabled
var follow_target: bool = false
var target_position: Vector3
var target_margin: float = 0.0
@onready var target_rotation: float = parent.rotation.y
##Sets this character's target

signal TARGET_REACHED


func lock_target(_target: Node3D) -> void:
	target = _target
	parent.look_at(target.global_position)
	
func move_to(position: Vector3, margin: float) -> void:
	follow_target = true
	target_position = position
	target_margin = margin
	
func _physics_process(delta: float) -> void:
	if follow_target:
		if parent.position.distance_to(target_position) > target_margin:
			parent.velocity = (target_position - parent.global_position).normalized() * parent.speed
		else:
			follow_target = false
			parent.velocity = Vector3.ZERO
			TARGET_REACHED.emit()
		if parent.velocity.length() < parent.speed/2.0:
			follow_target = false
			parent.velocity = Vector3.ZERO
			TARGET_REACHED.emit()
			
	#turn the character to face ther direction they are moving in
	if parent.velocity.x != 0 or parent.velocity.z != 0:
		target_rotation = atan2(parent.velocity.x, parent.velocity.z) + PI
	if parent.position.distance_to(target_position) > 0.1:
		parent.rotation.y = lerp_angle(parent.rotation.y, target_rotation, 0.2)
	
##allows the character to move freely
func unlock_target() -> void:
	pass

func move_forward() -> void:
	pass
	
func move_backward() -> void:
	pass
	
func strafe_left() -> void:
	pass
	
func strafe_right() -> void:
	pass
	

	

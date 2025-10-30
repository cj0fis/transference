
class_name SmartCam3D extends Camera3D

enum SmartCamMode{
	TOPDOWN,
	TRADITIONAL_3D
}

@export var mode:= SmartCamMode.TOPDOWN:
	set(value):
		mode = value
		match value:
			SmartCamMode.TOPDOWN:
				projection = Camera3D.PROJECTION_ORTHOGONAL
				distance = 7.5
				vertical_angle = 30.0
			SmartCamMode.TRADITIONAL_3D:
				projection = Camera3D.PROJECTION_PERSPECTIVE
				distance = 7.5
				vertical_angle = 20.0

				
@export var target: Node3D
@export var smooth_speed: float = 5.0

@export var match_target_rotation: bool = false

@export_range(0.0,90.0,0.5) var vertical_angle: float = 30.0
@export_range(-180.0, 180.0, 5.0) var horizontal_angle: float = 0.0

@export var position_offset: Vector3 = Vector3.ZERO
@export var rotation_offset: Vector3 = Vector3.ZERO

var distance_from_target: float

@export var distance: float = 15.0:
	set(value):
		distance = value
		match mode:
			SmartCamMode.TOPDOWN:
				size = distance
				distance_from_target = 15.0
			SmartCamMode.TRADITIONAL_3D:
				distance_from_target = distance
			
var target_position: Vector3

func _ready() -> void:
	if CharacterController and not CharacterController.active_cam:
		CharacterController.set_active_cam(self)
	rotation.y = horizontal_angle * PI/180.0 + PI


func _physics_process(delta: float) -> void:
	if CharacterController.active_cam == self:
		if Input.is_action_pressed("left_arrow"):
			horizontal_angle -= 90.0 * delta
		if Input.is_action_pressed("right_arrow"):
			horizontal_angle += 90.0 * delta
	if Input.is_action_just_pressed("p"):
		mode = (mode + 1) % SmartCamMode.keys().size()
		
		##allows switching between perspective and orthogonal for the camera
		#if Input.is_action_just_pressed("middle_click") or Input.is_action_just_pressed("p"):
			#if projection == PROJECTION_ORTHOGONAL:
				#projection = PROJECTION_PERSPECTIVE
			#else:
				#projection = PROJECTION_ORTHOGONAL
				
	##Z locks the camera's rotation to the player's rotation
	if match_target_rotation and target:
		horizontal_angle = rad_to_deg(target.rotation.y + PI)

	
	var lerp_weight = clampf(delta * smooth_speed, 0.0, 1.0)
	#if abs(fmod(target.rotation_degrees.y + 180, 360) - horizontal_angle) > 45.0:
		#horizontal_angle = lerp_angle(horizontal_angle, target.rotation.y /PI * 180.0 + 180.0, 1.0)
	#lerp the rotation to face the target. This is used when the vertical/horizontal angle changes
	
	rotation.x = lerp_angle(rotation.x - rotation_offset.x, -PI/180.0 * vertical_angle, lerp_weight) + rotation_offset.x
	rotation.y = lerp_angle(rotation.y - rotation_offset.y, PI/180.0 * horizontal_angle + PI, lerp_weight) + rotation_offset.y
	var offset := Vector3(0, distance_from_target * sin(PI/180.0 * vertical_angle), -distance_from_target * cos(PI/180.0 * vertical_angle)) + position_offset
	offset = offset.rotated(Vector3.UP, rotation.y - PI)
	
	if target:
		#lerp the target position to the target character's global position. This is used when the character moves
		target_position = lerp(target_position, target.global_position, lerp_weight)
		
		#adjust camera position to account for lerped rotation and offset
		global_position = target_position + offset
		

func _unhandled_input(event: InputEvent) -> void:
	if CharacterController.controller_type != CharacterController.ControllerType.WASD or CharacterController.char_state.attack_stance:
		return
	if event is InputEventMouseMotion:
		target.rotation.y -= event.relative.x * 0.002
		#vertical_angle = clampf(vertical_angle - event.relative.y * 0.02, 15.0, 75.0)
	

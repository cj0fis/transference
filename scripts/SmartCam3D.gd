
class_name SmartCam3D extends Camera3D

@export var target: Node3D
@export var smooth_speed: float = 5.0

@export_range(0.0,90.0,0.5) var vertical_angle: float = 30.0
@export_range(-180.0, 180.0, 5.0) var horizontal_angle: float = 0.0
@export var distance: float = 5.0
var target_position: Vector3

func _ready() -> void:
	if CharacterController and not CharacterController.active_cam:
		CharacterController.set_active_cam(self)
	rotation.y = horizontal_angle * PI/180.0 + PI

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not CharacterController.paused:
		horizontal_angle -= event.relative.x * 0.15


func _physics_process(delta: float) -> void:
	if CharacterController.active_cam == self:
		if Input.is_action_pressed("left_arrow"):
			horizontal_angle -= 90.0 * delta
		if Input.is_action_pressed("right_arrow"):
			horizontal_angle += 90.0 * delta
		
		##allows switching between perspective and orthogonal for the camera
		#if Input.is_action_just_pressed("middle_click") or Input.is_action_just_pressed("p"):
			#if projection == PROJECTION_ORTHOGONAL:
				#projection = PROJECTION_PERSPECTIVE
			#else:
				#projection = PROJECTION_ORTHOGONAL
				
	##Z locks the camera's rotation to the player's rotation
	if CharacterController.paused:
		if Input.is_key_pressed(KEY_Z):
			horizontal_angle = rad_to_deg(lerp_angle(deg_to_rad(horizontal_angle), target.rotation.y + PI, 0.5))
			print("rotating")
	
	var lerp_weight = clampf(delta * smooth_speed, 0.0, 1.0)
	#if abs(fmod(target.rotation_degrees.y + 180, 360) - horizontal_angle) > 45.0:
		#horizontal_angle = lerp_angle(horizontal_angle, target.rotation.y /PI * 180.0 + 180.0, 1.0)
	#lerp the rotation to face the target. This is used when the vertical/horizontal angle changes
	
	rotation.x = lerp_angle(rotation.x, -PI/180.0 * vertical_angle, lerp_weight)
	rotation.y = lerp_angle(rotation.y, PI/180.0 * horizontal_angle + PI, lerp_weight)
	var offset := Vector3(0, distance * sin(PI/180.0 * vertical_angle), -distance * cos(PI/180.0 * vertical_angle))
	offset = offset.rotated(Vector3.UP, rotation.y - PI)
	
	if target:
		#lerp the target position to the target character's global position. This is used when the character moves
		target_position = lerp(target_position, target.global_position, lerp_weight)
		
		#adjust camera position to account for lerped rotation and offset
		global_position = target_position + offset
		
		
		
	

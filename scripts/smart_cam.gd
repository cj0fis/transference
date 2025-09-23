class_name SmartCam extends Camera2D

var target_position: Vector2i
@export var smooth_speed: float = 5.0
func _ready() -> void:
	CharacterController.active_cam = self

func _process(delta: float) -> void:
	if CharacterController.active_char:
		target_position = CharacterController.active_char.global_position
		global_position = global_position.lerp(target_position, delta * smooth_speed)
	

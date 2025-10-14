##holds title and subtitle info for a character
class_name NameComponent extends RichTextLabel

@onready var parent: Character3D = get_parent() if get_parent() is Character3D else null

func _physics_process(delta: float) -> void:
	if not parent:
		return
	
	if CharacterController.active_cam:
		var screen_pos = CharacterController.active_cam.unproject_position(parent.global_position + Vector3(0,1.75,0))
		global_position = lerp(global_position, screen_pos + Vector2(-get_rect().size.x / 2.0, 0), 0.8)

	

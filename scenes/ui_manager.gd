extends Control



@onready var pause_screen: Control = $"Pause Screen"
@onready var sub_viewport_container: SubViewportContainer = $SubViewportContainer
@onready var pause_panel: Panel = $"Pause Screen/pause panel"
@onready var blur_effect: ColorRect = $"Pause Screen/blur effect"
@onready var smart_cam: SmartCam3D = $SubViewportContainer/SubViewport/World3D/smart_cam
@onready var hud: Control = $HUD

@onready var screen_size: Vector2

var pause_animation_time: float = 0.2

func _ready() -> void:
	screen_size = sub_viewport_container.size
	pause_panel.position.x -= pause_panel.size.x
	#pause_panel.modulate.a = 0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()

var can_toggle: bool = true

var camera_settings: Dictionary

func pause() -> void:
	if not can_toggle:
		return
		
	camera_settings["horizontal_angle"] = smart_cam.horizontal_angle
	camera_settings["distance"] = smart_cam.distance
	camera_settings["vertical_angle"] = smart_cam.vertical_angle
	camera_settings["mouse_mode"] = Input.mouse_mode
		
		
	can_toggle = false
	get_tree().paused = true
	hud.visible = false
	smart_cam.match_target_rotation = false
	var t = create_tween().set_parallel(true)
	#t.tween_property(sub_viewport_container, "stretch_shrink", 1, pause_animation_time)
	t.tween_property(blur_effect.material, "shader_parameter/amount", 2.5, 0.2)
	t.tween_property(blur_effect.material, "shader_parameter/dim", 0.3, 0.2)
	t.tween_property(sub_viewport_container,"size",  screen_size * Vector2(2.0,1.0), pause_animation_time)
	t.tween_property(sub_viewport_container,"position",  screen_size * Vector2(-0.25,0), pause_animation_time)
	t.tween_property(pause_panel,"position",  Vector2(0,0), pause_animation_time)
	
	#tween camera
	#smart_cam.vertical_angle = 15
	t.tween_property(smart_cam, "horizontal_angle", CharacterController.active_char.rotation.y / PI * 180 + 15, pause_animation_time)
	t.tween_property(smart_cam, "vertical_angle", 25.0, pause_animation_time)
	t.tween_property(smart_cam, "distance", 1.5, pause_animation_time)
	
	await t.finished
	can_toggle = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func unpause() -> void:
	if not can_toggle:
		return
	
	can_toggle = false
	smart_cam.match_target_rotation = true
	var t = create_tween().set_parallel(true)
	#t.tween_property(sub_viewport_container, "stretch_shrink", 1, pause_animation_time)
	t.tween_property(blur_effect.material, "shader_parameter/amount", 0.0, 0.2)
	t.tween_property(blur_effect.material, "shader_parameter/dim", 0.0, 0.2)
	t.tween_property(sub_viewport_container,"size",  screen_size, pause_animation_time)
	t.tween_property(sub_viewport_container,"position",  Vector2(0,0), pause_animation_time)
	t.tween_property(pause_panel,"position",  Vector2(-pause_panel.size.x,0), pause_animation_time)
	
	#tween camera
	#smart_cam.vertical_angle = 30
	t.tween_property(smart_cam, "horizontal_angle", camera_settings["horizontal_angle"], pause_animation_time)
	t.tween_property(smart_cam, "vertical_angle", camera_settings["vertical_angle"], pause_animation_time)
	t.tween_property(smart_cam, "distance", camera_settings["distance"], pause_animation_time)
	
	await t.finished
	can_toggle = true
	get_tree().paused = false
	hud.visible = true
	Input.mouse_mode = camera_settings["mouse_mode"]
	
func toggle_pause() -> void:
	if get_tree().paused:
		unpause()
	else:
		pause()

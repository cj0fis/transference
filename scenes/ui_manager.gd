extends Control



@onready var pause_screen: Control = $"Pause Screen"
@onready var sub_viewport_container: SubViewportContainer = $"../SubViewportContainer"
@onready var pause_panel: Panel = $"Pause Screen/pause panel"
@onready var blur_effect: ColorRect = $"Pause Screen/blur effect"
@onready var smart_cam: SmartCam3D = $"../SubViewportContainer/SubViewport/World3D/smart_cam"
@onready var controls_display: HBoxContainer = $"Controls Display"

@onready var screen_size: Vector2

var pause_animation_time: float = 0.2

func _ready() -> void:
	screen_size = sub_viewport_container.size


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()

var can_toggle: bool = true

func pause() -> void:
	if not can_toggle:
		return
	can_toggle = false
	get_tree().paused = true
	controls_display.visible = false
	var t = create_tween().set_parallel(true)
	t.tween_property(blur_effect.material, "shader_parameter/amount", 1.0, 0.2)
	t.tween_property(sub_viewport_container,"size",  screen_size * Vector2(0.5,1.0), pause_animation_time)
	t.tween_property(sub_viewport_container,"position",  screen_size * Vector2(0.5,0), pause_animation_time)
	t.tween_property(pause_panel,"position",  screen_size * Vector2(0,0), pause_animation_time)
	
	#tween camera
	#smart_cam.vertical_angle = 15
	t.tween_property(smart_cam, "horizontal_angle", CharacterController.active_char.rotation.y / PI * 180 + 30, pause_animation_time)
	t.tween_property(smart_cam, "size", 2.5, pause_animation_time)
	
	await t.finished
	can_toggle = true
	
	
func unpause() -> void:
	if not can_toggle:
		return
	
	can_toggle = false
	
	var t = create_tween().set_parallel(true)
	t.tween_property(blur_effect.material, "shader_parameter/amount", 0.0, 0.2)
	t.tween_property(sub_viewport_container,"size",  screen_size, pause_animation_time)
	t.tween_property(sub_viewport_container,"position",  Vector2(0,0), pause_animation_time)
	t.tween_property(pause_panel,"position",  screen_size  * Vector2(-0.5,0), pause_animation_time)
	
	#tween camera
	#smart_cam.vertical_angle = 30
	t.tween_property(smart_cam, "horizontal_angle", 45.0, pause_animation_time)
	t.tween_property(smart_cam, "size", 7.5, pause_animation_time)
	await t.finished
	can_toggle = true
	get_tree().paused = false
	controls_display.visible = true
	
func toggle_pause() -> void:
	if get_tree().paused:
		unpause()
	else:
		pause()

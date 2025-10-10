class_name OutlineComponent extends Component

@export var outline_mesh: MeshInstance3D = null

var is_mouse_over: bool
var health_component: HealthComponent = null

var hover_timer: float = 0.0
var hover_timeout: float = 0.0	#seconds before the mouse updates
	


func _ready() -> void:
	health_component = parent.get_component(HealthComponent)
	health_component.IS_DEAD.connect(_on_death)
	parent.mouse_entered.connect(_on_mouse_enter)
	parent.mouse_exited.connect(_on_mouse_exit)
	
func _on_mouse_enter() -> void:
	if not is_mouse_over and parent != CharacterController.active_char:
		is_mouse_over = true
		hover_timer = hover_timeout
		CharacterController.selected_character = parent
	
func _on_mouse_exit() -> void:
	if is_mouse_over and parent != CharacterController.active_char:
		is_mouse_over = false
		hover_timer = hover_timeout
		if CharacterController.selected_character == parent:
			CharacterController.selected_character = null
		
func _on_death() -> void:
	print("die")
	var t = create_tween()
	t.tween_property(outline_mesh, "transparency", 1.0, 1.5)
	#outline_mesh.visible = false
		
var outline_color = Color.WHITE
func _process(delta: float) -> void:
	#if hover_timer > 0.0:
		#hover_timer -= delta
		#is_mouse_over = true
	#else:
		#is_mouse_over = false
	if is_mouse_over:	#we set this in the process function because signals may be sent inbetween frames and cause flickering

		outline_mesh.material_override.set("albedo_color", Color.WHITE)
	else:

		outline_mesh.material_override.set("albedo_color", Color.BLACK)
	#if Input.is_action_just_pressed("left_click") and is_mouse_over:
		#parent.make_active_char()
	if Input.is_action_just_pressed("right_click") and is_mouse_over:
		CharacterController.selected_character = parent
	

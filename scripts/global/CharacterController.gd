extends Node3D

#constants 
const CURSOR = preload("uid://i6ktuqbtofuq")

enum ControllerType{
	CLICK_TO_MOVE,
	WASD
}

@export var look_at_mouse: bool = true

@export var controller_type: ControllerType = ControllerType.CLICK_TO_MOVE:
	set(value):
		controller_type = value
		match value:
			ControllerType.WASD:
				if movement:
					movement.move_mode = MovementComponent.MoveMode.NONE
					movement.look_mode = MovementComponent.LookMode.NONE
					Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				if active_cam:
					active_cam.match_target_rotation = true
				if is_node_ready():
					$mouse_highlight.visible = false
			ControllerType.CLICK_TO_MOVE:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				if active_cam:
					active_cam.match_target_rotation = false
					


var active_char: Character3D = null
var movement: MovementComponent
var char_state: StateComponent
var next_active_char: Character3D = null	#holds a reference to the set char during soul transition
var soul_mode: bool = false
var active_cam: SmartCam3D = null


var selected_character: Character3D

var z_target: Node3D = null:
	set(value):
		z_target = value
		if active_char:
			active_char.get_component(MovementComponent).lock_target(z_target)





@export var enabled: bool = false:
	set(value):
		if value and not active_char:
			push_error("Cannot enable character controller when character is null!")
		else:
			enabled = value
		
		if enabled:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			process_mode = Node.PROCESS_MODE_PAUSABLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			process_mode = Node.PROCESS_MODE_DISABLED

func reset() -> void:
	active_char = null
	active_cam = null
	movement = null
	char_state = null
	next_active_char = null
	enabled = false
	soul_mode = false
	selected_character = null
	active_cam = null
	set("controller_type", controller_type)
	
func set_active_cam(cam: SmartCam3D) -> void:
	active_cam = cam
	if active_char:
		active_cam.target = active_char
	
var soul_mesh: MeshInstance3D
func _ready() -> void:
	#instances soul mesh
	soul_mesh = MeshInstance3D.new()
	soul_mesh.mesh = SphereMesh.new()
	soul_mesh.mesh.radius = 0.2
	soul_mesh.mesh.height = 0.4
	soul_mesh.top_level = true
	soul_mesh.visible = false
	add_child(soul_mesh)
	reset()
	
	#controller_type = controller_type	#call the setter function again, as it effects some other nodes
	
#handles everything involved in swapping bodies
func bodyswap(character: Character3D) -> void:
	if character:
		next_active_char = character
		if active_char:
			enter_soul_mode()
		else:	#this is for first-time setting of the character, and ensures that it is setup the same as 2nd or 3rd characters
			exit_soul_mode()
		
	
	
func enter_soul_mode() -> void:
	
	#Engine.time_scale = 0.2
	#print("slowing time to 0.2x")
	if active_cam:
		active_cam.target = soul_mesh
	soul_mesh.global_position = active_char.global_position + Vector3(0,1,0)
	soul_mode = true
	soul_mesh.visible = true
	#var health_bar = active_char.get_node_or_null("HealthBarComponent")
	#if health_bar:
		#health_bar.fade_out()
		
func exit_soul_mode() -> void:
	#Engine.time_scale = 1.0
	#print("speeding time to 1.0x")
	if active_char:		#only stop the character once body swap is complete. this looks cooler in slomo
		active_char.velocity = Vector3.ZERO
		active_char.use_ai = true
		active_char.state_machine.enabled = true
	active_char = next_active_char
	active_char.state_machine.enabled = false
	active_char.use_ai = false
	movement = active_char.get_component(MovementComponent)
	if controller_type == ControllerType.WASD:
		#movement.look_mode = MovementComponent.LookMode.NODE
		#movement.target_node = $mouse_highlight
		movement.move_mode = MovementComponent.MoveMode.NONE
	char_state = active_char.get_component(StateComponent)
	if active_cam:
		active_cam.target = active_char
	soul_mode = false
	soul_mesh.visible = false
	#var health_bar = active_char.get_node_or_null("HealthBarComponent")
	#if health_bar:
		#health_bar.fade_in()




func handle_movement_inputs() -> void:
	match controller_type:
		ControllerType.CLICK_TO_MOVE:
			var mouse_world_pos = get_mouse_world_hit()
			if mouse_world_pos != null and mouse_world_pos.distance_to(active_char.global_position) > 0.1:
				$mouse_highlight.visible = not selected_character		#invisible if selected_character is not null
				$mouse_highlight.global_position = mouse_world_pos + Vector3(0,0.1,0)
			else:
				$mouse_highlight.visible = false
			
			if Input.is_action_pressed("right_click"):
				if selected_character and selected_character != active_char:
					movement.move_to_pos(selected_character.global_position, 1.0)
				elif mouse_world_pos:
					movement.move_to_pos(mouse_world_pos, 0.05)

		ControllerType.WASD:
			if not active_char.is_on_floor():
				return
			var input_dir = Vector3(
				Input.get_axis("move_west", "move_east"), 
				0, Input.get_axis("move_north", 
				"move_south")
			)
			if input_dir.length() > 0.01:
				var move_vec
				if char_state.attack_stance and selected_character:
					var to_target = (selected_character.global_position - active_char.global_position).normalized()
					var right = to_target.cross(Vector3.UP).normalized()
					
					move_vec = (to_target * -input_dir.z + right * input_dir.x).normalized() * movement.move_speed
					
				else:
					move_vec = input_dir.rotated(Vector3.UP, active_char.rotation.y) * movement.move_speed
				active_char.velocity.x = move_vec.x
				active_char.velocity.z = move_vec.z
			else:
				active_char.velocity.x = lerp(active_char.velocity.x, 0.0, 0.4)
				active_char.velocity.z = lerp(active_char.velocity.z, 0.0, 0.4)
			
			#if Input.is_action_pressed("move_north") or Input.is_action_just_released("move_north") \
			#or Input.is_action_pressed("move_south") or Input.is_action_just_released("move_south") \
			#or Input.is_action_pressed("move_west") or Input.is_action_just_released("move_west") \
			#or Input.is_action_pressed("move_east") or Input.is_action_just_released("move_east"):
				#pass
				
				

func handle_inputs() -> void:
	if Input.is_action_just_pressed("o"):
		controller_type = (controller_type + 1) % ControllerType.keys().size()

	if Input.is_action_just_pressed("space"):
		var input_dir = Vector3.ZERO
		if not char_state.attack_stance:
			input_dir = Vector3(
					Input.get_axis("move_west", "move_east"), 
					0, Input.get_axis("move_north", 
					"move_south")
				)
		elif selected_character:
			if selected_character.global_position.distance_to(active_char.global_position) > 1:
				input_dir = Vector3.FORWARD
			else:
				input_dir = Vector3.BACK
		movement.jump(input_dir, 10.0, 7.0)
	
	if Input.is_action_just_pressed("right_click") and selected_character:
		char_state.toggle_stance()
		if char_state.attack_stance and selected_character:
			movement.look_mode = MovementComponent.LookMode.NODE
			movement.target_node = selected_character
			active_cam.smooth_speed *= 3.0
		else:
			movement.look_mode = MovementComponent.LookMode.NONE
			active_cam.smooth_speed = 15.0

	if char_state.attack_stance:
		if Input.is_action_just_pressed("left_click"):
			char_state.attack()
		$mouse_highlight.visible = false
	
func _physics_process(delta: float) -> void:
	if not active_char or not enabled:
		return
		
	if char_state and char_state.attack_stance and not selected_character:
		char_state.toggle_stance()
		movement.look_mode = MovementComponent.LookMode.NONE
		active_cam.smooth_speed = 15.0
	
	if soul_mode:
		soul_mesh.global_position = lerp(soul_mesh.global_position, next_active_char.global_position + Vector3(0,1,0), delta * 10.0 / Engine.time_scale)
		if soul_mesh.global_position.distance_to(next_active_char.global_position + Vector3(0,1,0)) < 0.5:
			exit_soul_mode()
		else:
			return

	#if Input.is_action_just_pressed("space"):
		#var rand_char = get_tree().get_nodes_in_group("characters").pick_random()
		#print("swap random")
		#bodyswap(rand_char)
		
	handle_movement_inputs()
	
	handle_inputs()
	
	
	var health_component = active_char.get_node_or_null("HealthComponent")
	if Input.is_action_just_pressed("up_arrow"):
		health_component.apply_health(10, 1.0)
	if Input.is_action_just_pressed("down_arrow"):
		health_component.apply_health(-10, 1.0)
	
		

func get_mouse_world_hit():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = active_cam.project_ray_origin(mouse_pos)
	var ray_dir = active_cam.project_ray_normal(mouse_pos)
	var ray_length = 1000.0
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_dir * ray_length)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.collision_mask = 1 << 2
	
	var result = space_state.intersect_ray(query)
	if "position" in result:
		return result.position
	return null
	

	
	

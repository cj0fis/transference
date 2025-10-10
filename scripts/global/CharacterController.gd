extends Node3D


var active_char: Character3D = null
var movement_controller: MovementComponent
var next_active_char: Character3D = null	#holds a reference to the set char during soul transition
var soul_mode: bool = false
var paused = true

var selected_character: Character3D

var z_target: Node3D = null:
	set(value):
		z_target = value
		if active_char:
			active_char.get_component(MovementComponent).lock_target(z_target)

@export var active_cam: SmartCam3D = null:
	set(value):
		active_cam = value
		print("new active cam set!")


@export var enabled: bool = false:
	set(value):
		if value and not active_char:
			push_error("Cannot enable character controller when character is null!")
		else:
			enabled = value
		
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
	active_char = next_active_char
	movement_controller = active_char.get_component(MovementComponent)
	if active_cam:
		active_cam.target = active_char
	soul_mode = false
	soul_mesh.visible = false
	#var health_bar = active_char.get_node_or_null("HealthBarComponent")
	#if health_bar:
		#health_bar.fade_in()


	
	
func _physics_process(delta: float) -> void:
	if not active_char or not enabled:
		return
	
	if soul_mode:
		soul_mesh.global_position = lerp(soul_mesh.global_position, next_active_char.global_position + Vector3(0,1,0), delta * 10.0 / Engine.time_scale)
		if soul_mesh.global_position.distance_to(next_active_char.global_position + Vector3(0,1,0)) < 0.5:
			exit_soul_mode()
		else:
			return
	
	if Input.is_action_just_pressed("space"):
		var rand_char = get_tree().get_nodes_in_group("characters").pick_random()
		print("swap random")
		bodyswap(rand_char)
	
	var mouse_world_pos = get_mouse_world_hit()

	if mouse_world_pos != null and mouse_world_pos.distance_to(active_char.global_position) > 0.5:
		$mouse_highlight.visible = not selected_character		#invisible if selected_character is not null
		$mouse_highlight.global_position = mouse_world_pos + Vector3(0,0.1,0)
		
		if Input.is_action_pressed("right_click"):
			if selected_character:
				movement_controller.move_to(selected_character.global_position, 1.0)
			else:
				#active_char.attack_state = true
				movement_controller.move_to(mouse_world_pos, 0.1)
		if Input.is_action_just_pressed("left_click"):
			if selected_character:
				movement_controller.move_to(selected_character.global_position, 1.0)
				await movement_controller.TARGET_REACHED
				active_char.attack_state = true
	else:
		$mouse_highlight.visible = false
	
	
	
	var health_component = active_char.get_node_or_null("HealthComponent")
	if Input.is_action_just_pressed("up_arrow"):
		health_component.apply_health(10, 1.0)
	if Input.is_action_just_pressed("down_arrow"):
		health_component.apply_health(-10, 1.0)
	
	#if Input.is_action_just_pressed("scroll_up"):
		#active_cam.size *= 0.9
	#if Input.is_action_just_pressed("scroll_down"):
		#active_cam.size /= 0.9
		
	if Input.is_action_just_pressed("pause"):
		if paused == true:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			paused = false
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			paused = true
		
	



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
	

	
	

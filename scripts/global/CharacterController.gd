extends Node2D


var active_char: Character3D = null
var next_active_char: Character3D = null	#holds a reference to the set char during soul transition
var soul_mode: bool = false

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
	soul_mesh.global_position = active_char.global_position
	#soul_mesh.reparent(active_char)
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
		
	if Input.is_action_just_pressed("right_click"):
		active_char.attack_state = true
	
	var health_component = active_char.get_node_or_null("HealthComponent")
	if Input.is_action_just_pressed("up_arrow"):
		health_component.apply_health(10, 1.0)
	if Input.is_action_just_pressed("down_arrow"):
		health_component.apply_health(-10, 1.0)
	
	if Input.is_action_just_pressed("scroll_up"):
		active_cam.size *= 0.9
	if Input.is_action_just_pressed("scroll_down"):
		active_cam.size /= 0.9
		
		
		
	var z = Input.get_axis("move_forward", "move_backward")
	var x = Input.get_axis("move_left", "move_right")
	var vel = Vector3(x,0,z).normalized()
	vel = vel.rotated(Vector3.UP, active_cam.rotation.y - PI)
	
	active_char.velocity = vel * -active_char.speed
	if vel != Vector3.ZERO:
		var target_rotation = atan2(vel.x, vel.z)
		active_char.rotation.y = lerp_angle(active_char.rotation.y, target_rotation, 0.2)

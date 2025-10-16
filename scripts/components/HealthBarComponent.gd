class_name HealthBarComponent extends TextureProgressBar

@onready var parent: Character3D

var health_component: HealthComponent
		
var time_since_health_update: float = 0

@export var fade_out_time: float = 0.0

const UI_TEX = preload("uid://ch5ikt3ve8n1l")

func init_texture_progress_bar() -> void:
	var tex = AtlasTexture.new()
	tex.atlas = UI_TEX
	tex.region = Rect2(67,1821,42,6)
	texture_progress = tex
	max_value = tex.region.size.x
	value = max_value
	rounded = true

func assign_components() -> void:
	if get_parent() is Character3D:
		parent = get_parent()
		health_component = parent.get_component(HealthComponent)
		health_component.connect("HEALTH_UPDATE", update_health)

func _ready() -> void:
	assign_components()
	
	#initialize health bar. This is done with code because the component will be added as a node, not a scene
	init_texture_progress_bar()
	modulate.a = 0.0	#health bars should be transparent initially

	
func _physics_process(delta: float) -> void:
	if not parent:
		return
	
	if CharacterController.active_cam:
		var screen_pos = CharacterController.active_cam.unproject_position(parent.global_position + Vector3(0,1.75,0))
		global_position = lerp(global_position, screen_pos + Vector2(-get_rect().size.x / 2.0, 0), 0.8)
	
	time_since_health_update += delta
	if time_since_health_update >= fade_out_time:
		fade_out()
	
func update_health(_delta) -> void:
	var percent: float = health_component.current_health / health_component.max_health
	value = max_value * percent
	time_since_health_update = 0.0
	fade_in()

func fade_in() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.2)
	
func fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	

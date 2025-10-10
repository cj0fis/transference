class_name DeathEffectComponent extends Component

@export var health_component: HealthComponent

func assign_components() -> void:
	health_component = parent.get_component(HealthComponent)


func _ready() -> void:
	assign_components()
	health_component.IS_DEAD.connect(_on_death)

func _on_death() -> void:
	if not parent.mesh:
		return
	if not parent.mesh.material_override:
		parent.set_character_effect_material()
	
	var t1 = create_tween()
	t1.tween_property(parent.mesh.material_override, "shader_parameter/amount", 1.0, 2.0)
	t1.tween_callback(parent.queue_free)
	#var t2 = create_tween()
	#t2.tween_property($"../Character Lights/Front light", "light_energy", 0.0, 2.0)
	#var t3 = create_tween()
	#t3.tween_property($"../Character Lights/Back light", "light_energy", 0.0, 2.0)

class_name HitEffectComponent extends Component

@onready var hurtbox: HurtBoxComponent = null

func assign_components() -> void:
	hurtbox = parent.get_component(HurtBoxComponent)
	hurtbox.TAKE_DAMAGE.connect(_on_hit)
	parent.get_component(NameComponent)
	
func _ready() -> void:
	assign_components()

func set_flash(enabled) -> void:
	parent.mesh.material_override.set("shader_parameter/show_hit_color", enabled)

func _on_hit(_damage) -> void:
	if not parent.mesh.material_override:
		parent.set_character_effect_material()
	if parent.mesh.material_override.get("shader_parameter/show_hit_color"):		#dont set or create timer if character is already flashed
		return
	set_flash(true)
	get_tree().create_timer(0.15).timeout.connect(set_flash.bind(false))		#after 0.1 seconds, turn the flash off

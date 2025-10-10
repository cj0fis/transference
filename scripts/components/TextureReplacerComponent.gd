@tool
##this component allows for a character to randomly choose a texture to apply to its mesh
class_name TextureReplacerComponent extends Component

@export_tool_button("change texture") var b1 = set_texture
		
#@export var mesh: MeshInstance3D = null:
	#set(value):
		#mesh = value
		#update_configuration_warnings()
@export var textures: Array[Texture2D] = []


func _get_configuration_warnings() -> PackedStringArray:
	var warnings:= []
	#if mesh == null:
		#warnings.append("Must set mesh to apply textures!D")
	return warnings



func set_texture() -> void:
	if not parent.mesh:
		return
	if not parent.mesh.material_override:
		parent.set_character_effect_material()
		
	if textures.size() > 0:
		var tex = textures.pick_random()
		parent.mesh.material_override.set("shader_parameter/albedo", tex)
		
	
func _ready() -> void:
	await parent.ready
	set_texture()

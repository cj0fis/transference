@tool
##this component allows for a character to randomly choose a texture to apply to its mesh
class_name TextureReplacerComponent extends Component


@export_tool_button("change texture") var b1 = set_texture
		
@export var root_node: Node3D = null:
	set(value):
		root_node = value
		update_configuration_warnings()

@export var textures: Array[Texture2D] = []


func _get_configuration_warnings() -> PackedStringArray:
	var warnings:= []
	if root_node == null:
		warnings.append("Must set root node to apply textures! Note: Character mesh must be a single MeshInstance3D")
	return warnings

func get_children_recursive(node: Node) -> Array[Node]:
	var result: Array[Node] = []
	for child in node.get_children():
		result.append(child)
		result += get_children_recursive(child)
	return result

func set_texture() -> void:
	if not root_node:
		return
	if textures.size() > 0:
		var tex = textures.pick_random()
		var mat: StandardMaterial3D = null

		for node in get_children_recursive(root_node):
			if node is MeshInstance3D:
				if mat == null:
					mat = node.get_active_material(0).duplicate()
					mat.albedo_texture = tex
				node.material_override = mat
	
func _ready() -> void:
	set_texture()

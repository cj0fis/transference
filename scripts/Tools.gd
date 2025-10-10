extends Node


func get_children_recursive(node: Node) -> Array[Node]:
	var result: Array[Node] = []
	for child in node.get_children():
		result.append(child)
		result += get_children_recursive(child)
	return result

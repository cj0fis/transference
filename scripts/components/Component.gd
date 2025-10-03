##Base component class. Other components will inherit from this
class_name Component extends Node

var parent: Character3D = null

func _ready() -> void:
	if get_parent() is Character3D:
		parent = get_parent()

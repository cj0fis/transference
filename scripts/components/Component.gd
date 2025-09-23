##Base component class. Other components will inherit from this
class_name Component extends Node

var parent: Character = null

func _ready() -> void:
	if get_parent() is Character:
		parent = get_parent()

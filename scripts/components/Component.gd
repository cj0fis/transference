##Base component class. Other components will inherit from this
class_name Component extends Node

## The Character3D that owns this component
@onready var parent: Character3D = get_parent() if get_parent() is Character3D else null
# note: I don't assign this in _ready() because often times the _ready() function is overriden by extended components


## override this if your component requires a connection to other components.
## this will be called at _ready(), and may be called again later
func assign_components() -> void:
	pass

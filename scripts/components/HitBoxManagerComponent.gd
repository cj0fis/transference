
## this component manages all hitboxes a character has. It determines the damage, as well as disables hitboxes when not attacking
class_name HitBoxManagerComponent extends Component
@export var animation_tree: AnimationTree	#detects state changes to selectively enable or change damage for hitboxes

@export var state_damage: Dictionary[String, float]	#the state keys should match the states in the animation tree state machine

func get_children_recursive(node: Node) -> Array[Node]:
	var result: Array[Node] = []
	for child in node.get_children():
		result.append(child)
		result += get_children_recursive(child)
	return result


var hitboxes: Array[HitBox]

func _ready() -> void:
	super()	#get parent
	for child in get_children_recursive(parent):
		if child is HitBox:
			hitboxes.append(child)
			print(child)
	set_hitboxes(0.0)	#disable hitboxes on initialization
	
	if animation_tree:
		animation_tree.get("parameters/playback").state_started.connect(_on_state_changed)
	
	
func _on_state_changed(state: StringName) -> void:
	if state in state_damage:
		set_hitboxes(state_damage[state])
		print("setting hitbox damage to: ", state_damage[state])

func set_hitboxes(dmg: float):
	for hitbox in hitboxes:
		hitbox.damage = dmg

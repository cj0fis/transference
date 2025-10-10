@tool
##A character with the hurtbox will take damage if the hurtbox overlaps another character's hitbox
class_name HurtBoxComponent extends Area3D
@export var damage_cooldown: float = 0.5
var cooldown = 0.0

##emitted when the character recieves damage
signal TAKE_DAMAGE(value: int)


func _ready() -> void:
	collision_layer = 2
	collision_mask = 2
	input_ray_pickable = false


func _physics_process(delta: float) -> void:
	if cooldown > 0:
		cooldown -= delta
	elif cooldown < 0:
		cooldown = 0

##notifies the character of damage taken
func damage(value: int) -> void:
	if cooldown > 0:
		return
	TAKE_DAMAGE.emit(value)
	cooldown = damage_cooldown

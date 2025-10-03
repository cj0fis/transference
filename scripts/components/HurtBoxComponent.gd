@tool
##A character with the hurtbox will take damage if the hurtbox overlaps another character's hitbox
class_name HurtBoxComponent extends Area3D


##emitted when the character recieves damage
signal TAKE_DAMAGE(value: int)

#@export var hurtbox: Area3D:
	#set(value):
		#hurtbox = value
		#update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	#if not hurtbox:
		#warnings.append("Must assign an Area3D for the hurtbox!")
	return warnings



##notifies the character of damage taken
func damage(value: int) -> void:
	TAKE_DAMAGE.emit(value)
	print("Take damage: ", value)

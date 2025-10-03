##put as many of these within a scene as necessary, they will deal damage to hurtboxes belonging to characters that do not own this hitbox.
class_name HitBox extends Area3D


@export var damage: float = 10.0	#setting this to 0 will prevent this from emitting signals


func _ready() -> void:
	area_entered.connect(_on_area_entered)

	
func _on_area_entered(area: Area3D):
	if area is HurtBoxComponent and area.owner != self.owner and damage != 0.0:
		area.damage(-damage)
		

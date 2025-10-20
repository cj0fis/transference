extends BTState

@export var aggro_range: float = 4.0

func _update(delta: float) -> void:
	if CharacterController.active_char.global_position.distance_to(agent.global_position) > aggro_range:
		dispatch("player_lost")

func _enter() -> void:
	print("entering aggro")
	
func _exit() -> void:
	print("exiting aggro")

extends BTState

@export var player_detection_range: float = 4.0
func _enter() -> void:
	blackboard_plan.set("spawn_position", agent.global_position)
func _update(delta: float) -> void:
	if CharacterController.active_char.global_position.distance_to(agent.global_position) <= player_detection_range:
		dispatch("player_detected")

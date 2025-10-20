class_name AudioComponent
extends Component

@onready var walkingAudioStream: AudioStreamPlayer = get_parent().get_node("Footsteps")

func _process(_delta: float) -> void:
	is_walking()

func is_walking() -> void:
	var character = get_parent()
	if character is Character3D:
		var velocity = character.velocity
		# print("Velocity: ", velocity)

		if (velocity.x != 0 or velocity.z != 0) and velocity.y == 0:
			if not walkingAudioStream.playing:
				walkingAudioStream.play()
				print("Footsteps are playing")
		else:
			if walkingAudioStream.playing:
				walkingAudioStream.stop()
				print("Footsteps have stopped") 


 

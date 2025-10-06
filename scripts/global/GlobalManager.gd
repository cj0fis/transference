extends Node
##Autoload script that handles singletons

@export var error_logging = true
@export var state_logging = true
@export var init_logging = true
@export var debug_logging = true

signal PLAYER_INITIATED

var game_controller: GameController	#global referene to the game controller




#instantiates the player and adds it to the world_2d
#func spawn_player(position: Vector2 = Vector2.ZERO) -> void:
	#var player_scene = load("res://characters/player/player_base.tscn").instantiate()	#when the scene is ready, it will call set_player()
	#game_controller.world_2d.add_child(player_scene)

#optional logging

func log_error(msg: String) -> void:
	if error_logging:
		print_rich("[color=red] [ERROR] " + msg)

func log_init(msg: String) -> void:
	if init_logging:
		print_rich("[color=yellow] [INIT] " + msg)
	
func log_state(msg: String) -> void:
	if state_logging:
		print_rich("[color=orange] [STATE] " + msg)
	
func log_debug(msg: String) -> void:
	if debug_logging:
		print_rich("[color=green] [DEBUG] " + msg)

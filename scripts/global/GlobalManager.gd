extends Node
##Autoload script that handles singletons

@export var error_logging = true
@export var state_logging = true
@export var init_logging = true
@export var debug_logging = true

signal PLAYER_INITIATED

var game_controller: GameController	#global referene to the game controller


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

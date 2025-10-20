class_name HSM extends LimboHSM

@onready var parent: Character3D = get_parent() if get_parent() is Character3D else null

@export var starting_state: LimboState
@export var enabled: bool = true:
	set(value):
		enabled = value
		if enabled:
			process_mode = Node.PROCESS_MODE_INHERIT
		else:
			process_mode = Node.PROCESS_MODE_DISABLED

func init() -> void:
	if not parent:
		GlobalManager.log_error("Cannot initialize HSM, parent is not Character3D")
		return
	initial_state = starting_state
	initialize(parent)
	set_active(true)
	


func _ready() -> void:
	init()
	add_transition(ANYSTATE, $Seeking, "player_detected")
	add_transition($Seeking, $"Attack mode", "success")
	add_transition(ANYSTATE, $Idle, "player_lost")
	
	
	#$Idle.set("spawn_position", agent.global_position)
	#add_event_handler("SEEK_SUCCESS", func(cargo=null):
		#change_active_state($Idle)
		#print("SEEK_SUCCESS")
		#return true
	#)

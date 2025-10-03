class_name HealthComponent
extends Component

##health over time class. positive amounts heal, negative amounts damage
class HOT: 
	var _amount: float
	var _time: float
	var _time_remaining: float
	var _hps: float
	var active: bool
	func _init(amount: float, time: float):
		_amount = amount
		_time = time
		_time_remaining = time
		_hps = _amount / _time
		active = true
	func update_timer(delta: float):
		_time_remaining -= delta
		if _time_remaining < 0:
			active = false
#exports
@export var max_health: float = 1.0
@export var hurtbox: HurtBoxComponent:
	set(value):
		hurtbox = value
		update_configuration_warnings()
		
func _ready() -> void:
	hurtbox.TAKE_DAMAGE.connect(apply_health)

#signals
signal IS_DEAD
#signal IS_HEALING
#signal IS_TAKING_DAMAGE
signal HEALTH_UPDATE(delta: float)

#variables
@onready var current_health: float = max_health
var HOTs: Array[HOT] = []

##adds a new HOT instance to apply health over time
func apply_health(amount: float, seconds: float = 0.5) -> void:
	#current_health = clampf(current_health + amount, 0, max_health)
	HOTs.append(HOT.new(amount, seconds))


func _physics_process(delta: float) -> void:
	var delta_health: float = 0.0
	for i in range(HOTs.size()-1, -1, -1):		#iterate backwards so inactive HOTs can be popped
		if HOTs[i].active:
			delta_health += HOTs[i]._hps * delta
			HOTs[i].update_timer(delta)
		else:
			HOTs.pop_at(i)
	
	#update health
	current_health = clamp(current_health + delta_health, 0.0, max_health)
	
	#emit signals
	if delta_health != 0:
		HEALTH_UPDATE.emit(delta_health)
	if current_health <= 0:
		IS_DEAD.emit()

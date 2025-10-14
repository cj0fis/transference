class_name StateComponent extends Component

var move_component: MovementComponent = null

@export var attacks: Array[AttackData]
var combo_num = 0
@export var hitbox: HitBox

func assign_components() -> void:
	move_component = parent.get_component(MovementComponent)

func _ready() -> void:
	assign_components()
	
var attack_stance: bool = false

func toggle_stance() -> void:
	if attack_stance:
		enter_normal_stance()
	else:
		enter_attack_stance()

func enter_attack_stance() -> void:
	parent.animation_tree.set("parameters/stance/transition_request", "attack")
	attack_stance = true
	
func enter_normal_stance() -> void:
	parent.animation_tree.set("parameters/stance/transition_request", "normal")
	attack_stance = false


##plays the attack animation and enables hitboxes
##WARNING: hitbox-based attacks are kinda janky and may not be very reliable

@onready var attack_cooldown = attacks[0].cooldown if attacks.size() > 0 else 0.0
func attack() -> void:
	if attack_cooldown <= 0:
		parent.animation_tree.set("parameters/" + attacks[combo_num].name + "/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		#hitbox.damage = attacks[combo_num].damage
		for area in hitbox.get_overlapping_areas():
			if area is HurtBoxComponent and area.owner != hitbox.owner:
				area.damage(attacks[combo_num].damage)
				break
		combo_num = (combo_num + 1) % attacks.size()
		attack_cooldown = attacks[combo_num].cooldown

##play the attack animation and deal instant damage to the target. does not enable hitboxes
func attack_target(target: Character3D) -> void:
	move_component.move_to_pos(target.global_position, 1.0)
	await move_component.TARGET_REACHED
	if parent.global_position.distance_to(target.global_position) <= 1.5:
		parent.state_machine.change_state(parent.state_machine.get_state_by_name("attack"))

func _physics_process(delta: float) -> void:
	if attack_cooldown > 0:
		attack_cooldown -= delta
	else:
		attack_cooldown = 0
		
	if parent.velocity.x == 0 and parent.velocity.z == 0:
		parent.animation_tree.set("parameters/movement/transition_request", "idle")
	else:
		parent.animation_tree.set("parameters/movement/transition_request", "move")

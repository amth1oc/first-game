extends WeaponStateMachine
class_name WeaponStateMachineForAxe

@export var initial_state_: Node
var current_state_: Node

func _ready() -> void:
	# Khởi tạo các state con
	for child in get_children():
		if child is WeaponState:
			child.state_machine = self
			child.weapon = owner # owner của node này phải là gốc của vũ khí (WeaponEquipped)
	
	if initial_state_:
		change_state(initial_state_)
	elif get_child_count() > 0:
		change_state(get_child(0))

func _physics_process(delta: float) -> void:
	if current_state_:
		current_state_.update(delta)	

func change_state(new_state: Node) -> void:
	if current_state_:
		current_state_.exit()
	
	current_state_ = new_state
	if current_state_.has_method("enter"):
		current_state_.enter()

func send_action(action: String) -> void:
	if current_state_:
		current_state_.handle_action(action)

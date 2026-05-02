extends Node
class_name WeaponStateMachine

@export var initial_state: Node
var current_state: Node

func _ready() -> void:
	# Khởi tạo các state con
	for child in get_children():
		if child is WeaponState:
			child.state_machine = self
			child.weapon = owner # owner của node này phải là gốc của vũ khí (WeaponEquipped)
	
	if initial_state:
		change_state(initial_state)
	elif get_child_count() > 0:
		change_state(get_child(0))

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func change_state(new_state: Node) -> void:
	if current_state:
		current_state.exit()
	
	current_state = new_state
	if current_state.has_method("enter"):
		current_state.enter()

func send_action(action: String) -> void:
	if current_state:
		current_state.handle_action(action)

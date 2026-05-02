extends Node
class_name EnemyStateMachine

@export var initial_state: Node
var current_state: EnemyState

func _ready() -> void:
	# Gán tham chiếu cho tất cả state con
	for child in get_children():
		if child is EnemyState:
			child.state_machine = self
			child.enemy = owner  # owner = EnemyController (root của scene)
	
	# Bắt đầu với state đầu tiên
	#if initial_state and initial_state is EnemyState:
	#	change_state(initial_state)
		
	if initial_state and initial_state is EnemyState:
		change_state.call_deferred(initial_state)


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func change_state(new_state: EnemyState) -> void:
	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.enter()

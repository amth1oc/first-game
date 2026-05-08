extends EnemyState
class_name EnemyWanderState

@export var alert_state: EnemyState
@export var wander_radius: float = 8.0

var wander_timer: float = 0.0
var wander_interval: float = 3.5
var _detect_timer: float = 0.0

func enter() -> void:
	_pick_new_wander_target()

func exit() -> void:
	pass

func update(delta: float) -> void:
	# Di chuyển theo NavigationAgent
	enemy.navigate_to_target(delta)
	
	# Đổi hướng sau mỗi interval
	wander_timer -= delta
	if wander_timer <= 0.0:
		_pick_new_wander_target()
	
	# Nếu phát hiện player → Alert
	_detect_timer -= delta
	if _detect_timer <= 0.0:
		_detect_timer = 0.2  ### tiết kiệm tài nguyên hơn
		if enemy.can_see_player():
			state_machine.change_state(alert_state)


func _pick_new_wander_target() -> void:
	wander_timer = wander_interval
	var random_offset = Vector3(
		randf_range(-wander_radius, wander_radius),
		0.0,
		randf_range(-wander_radius, wander_radius)
	)
	var new_target = enemy.global_position + random_offset
	enemy.navigation_agent.target_position = new_target
	#print("Wander target set: ", new_target)  # debug

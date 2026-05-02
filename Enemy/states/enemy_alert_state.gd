extends EnemyState
class_name EnemyAlertState

@export var combat_state: EnemyState
@export var wander_state: EnemyState

var lose_sight_timer: float = 0.0
const LOSE_SIGHT_DURATION: float = 3.0

func enter() -> void:
	lose_sight_timer = LOSE_SIGHT_DURATION

func exit() -> void:
	pass

func update(delta: float) -> void:
	# Di chuyển về phía player
	if enemy.target_player:
		enemy.navigation_agent.target_position = enemy.target_player.global_position
	enemy.navigate_to_target(delta)
	enemy.look_at_player(delta)
	
	if enemy.can_see_player():
		lose_sight_timer = LOSE_SIGHT_DURATION  # reset khi còn thấy
		
		# Vào tầm bắn → Combat
		var weapon_data = enemy.get_current_weapon_data()
		if weapon_data:
			var dist = enemy.global_position.distance_to(enemy.get_player_position())
			if dist <= weapon_data.ai_attack_range:
				state_machine.change_state(combat_state)
	else:
		# Mất dấu → đếm ngược rồi Wander
		lose_sight_timer -= delta
		if lose_sight_timer <= 0.0:
			state_machine.change_state(wander_state)

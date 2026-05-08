extends EnemyState
class_name EnemyCombatState

@export var reload_state: EnemyState
@export var alert_state: EnemyState

var fire_timer: float = 0.0
var _detect_timer: float = 0.0

func enter() -> void:
	fire_timer = _get_fire_interval()

func exit() -> void:
	pass

func update(delta: float) -> void:
	# Mất tầm nhìn → Alert
	_detect_timer -= delta
	if _detect_timer <= 0.0:
		_detect_timer = 0.15
		if not enemy.can_see_player():
			state_machine.change_state(alert_state)
			return

	
	enemy.look_at_player(delta)
	enemy.strafe_around_player(delta)
	
	# Bắn theo fire_rate
	fire_timer -= delta
	if fire_timer <= 0.0:
		_try_fire()
		fire_timer = _get_fire_interval()

func _try_fire() -> void:
	var weapon_data = enemy.get_current_weapon_data()
	if not weapon_data:
		return
	
	# Hết đạn → Reload
	if weapon_data.current_magazine_ammo <= 0:
		state_machine.change_state(reload_state)
		return
	
	# Nhắm với accuracy rồi bắn
	enemy.aim_at_player_with_accuracy(weapon_data.ai_fire_accuracy)
	enemy.weapons_manager.attack()

func _get_fire_interval() -> float:
	var weapon_data = enemy.get_current_weapon_data()
	if weapon_data and weapon_data.fire_rate > 0:
		return 60.0 / weapon_data.fire_rate
	return 0.5

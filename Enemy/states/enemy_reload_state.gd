extends EnemyState
class_name EnemyReloadState

@export var combat_state: EnemyState
@export var alert_state: EnemyState

func enter() -> void:
	# Dùng lại WeaponManager.reload_current_weapon() — giống player
	enemy.weapons_manager.reload_current_weapon()
	
	# Lùi ra khỏi tầm bắn trong khi reload
	enemy.take_cover_while_reloading()

func exit() -> void:
	pass

func update(_delta: float) -> void:
	# Chờ is_reloading = false (do ReloadState của weapon set)
	var weapon_data = enemy.get_current_weapon_data()
	if weapon_data == null:
		return
	
	if not weapon_data.is_reloading:
		if enemy.can_see_player():
			state_machine.change_state(combat_state)
		else:
			state_machine.change_state(alert_state)

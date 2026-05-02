extends WeaponState
class_name WeaponReloadState

@export var idle_state: Node
var reload_timer: float = 0.0

func enter() -> void:
	reload_timer = weapon.weapon_data.reload_time
	# Có thể gọi weapon.play_reload_animation() ở đây

func update(delta: float) -> void:
	reload_timer -= delta
	if reload_timer <= 0.0:
		weapon.perform_reload_logic()
		state_machine.change_state(idle_state)

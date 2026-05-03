extends WeaponState

@export var idle_state: Node
var cooldown_timer: float = 0.0

func enter() -> void:
	# Gọi hàm chém của dao
	weapon.attack(weapon.current_hit_result)
	cooldown_timer = 60.0 / weapon.weapon_data.fire_rate

func update(delta: float) -> void:
	cooldown_timer -= delta
	if cooldown_timer <= 0.0:
		state_machine.change_state(idle_state)

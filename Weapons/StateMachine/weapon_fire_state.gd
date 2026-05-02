extends WeaponState
class_name WeaponFireState

@export var idle_state: Node
var cooldown_timer: float = 0.0

func enter() -> void:
	# Lấy thông tin hit_result (đã được lưu trước đó bởi WeaponManager)
	var hit_result = weapon.current_hit_result
	weapon.fire_weapon(hit_result)
	
	# Tính toán cooldown (thời gian giữa 2 viên đạn)
	cooldown_timer = 60.0 / weapon.weapon_data.fire_rate

func update(delta: float) -> void:
	cooldown_timer -= delta
	if cooldown_timer <= 0.0:
		state_machine.change_state(idle_state)

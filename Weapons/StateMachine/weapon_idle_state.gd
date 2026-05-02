extends WeaponState
class_name WeaponIdleState

@export var fire_state: Node
@export var reload_state: Node
@export var inspect_state: Node

func handle_action(action: String) -> void:
	if action == "fire" and fire_state:
		# Kiểm tra còn đạn mới cho bắn
		if weapon.weapon_data.current_magazine_ammo > 0:
			state_machine.change_state(fire_state)
		else:
			# Có thể gọi lệnh báo hết đạn (tiếng "cạch cạch") 
			# hoặc tự động nạp đạn luôn
			if reload_state and weapon.weapon_data.total_ammo > 0:
				state_machine.change_state(reload_state)

	elif action == "reload" and reload_state:
		# Chỉ nạp đạn nếu băng đạn chưa đầy và balo còn đạn dự trữ
		var is_mag_full = weapon.weapon_data.current_magazine_ammo >= weapon.weapon_data.max_magazine_capacity
		var has_spare_ammo = weapon.weapon_data.total_ammo > 0
		
		if not is_mag_full and has_spare_ammo:
			state_machine.change_state(reload_state)
			
	elif action == "inspect" and inspect_state:  
		state_machine.change_state(inspect_state)

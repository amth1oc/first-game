extends WeaponState

@export var attack_state: Node

func handle_action(action: String) -> void:
	# Dao thì cứ bấm chuột là chém, không cần check đạn
	if action == "fire" and attack_state:
		state_machine.change_state(attack_state)
		
	# Bấm R (reload) sẽ không làm gì cả, không báo lỗi

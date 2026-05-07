extends WeaponState
class_name FireState

@export var next_state: WeaponState   # thường là IdleState

var _is_firing: bool = false

func enter() -> void:
	if not weapon:
		return
	
	# Chặn spam attack khi animation chưa xong
	if _is_firing:
		return
	
	_is_firing = true
	
	# Play animation chém
	if weapon.anim_player:
		weapon.anim_player.play("attack_swing")
		
		# Chờ animation kết thúc
		weapon.anim_player.animation_finished.connect(_on_anim_finished, CONNECT_ONE_SHOT)

func exit() -> void:
	_is_firing = false

func handle_action(action: String) -> void:
	# Nếu muốn combo sau này thì xử lý ở đây
	pass


func _on_anim_finished(anim_name: String) -> void:
	if anim_name != "attack_swing":
		return
	
	_is_firing = false
	
	# Quay về state tiếp theo (Idle)
	if next_state:
		state_machine.change_state(next_state)

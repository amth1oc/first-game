extends WeaponState
class_name WeaponInspectState

@export var idle_state: Node
var inspect_timer: float = 0.0
const INSPECT_DURATION: float = 3.0

func enter() -> void:
	inspect_timer = INSPECT_DURATION
	if weapon.has_node("AnimationPlayer"):
		weapon.get_node("AnimationPlayer").play("inspect")

func update(delta: float) -> void:
	inspect_timer -= delta
	if inspect_timer <= 0.0:
		state_machine.change_state(idle_state)

func handle_action(action: String) -> void:
	# Cho phép interrupt bằng cách bắn hoặc reload
	if action == "fire" or action == "reload":
		state_machine.change_state(idle_state)

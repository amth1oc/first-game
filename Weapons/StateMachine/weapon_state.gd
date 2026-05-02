extends Node
class_name WeaponState

var state_machine: WeaponStateMachine
var weapon: Node3D # Thay bằng tên class vũ khí của bạn (vd: WeaponEquipped)

func enter() -> void: pass
func exit() -> void: pass
func update(_delta: float) -> void: pass
func handle_action(_action: String) -> void: pass

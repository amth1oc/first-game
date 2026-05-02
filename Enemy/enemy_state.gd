extends Node
class_name EnemyState

# Hai biến này sẽ được gán bởi EnemyStateMachine._ready()
var state_machine  # kiểu EnemyStateMachine
var enemy          # kiểu EnemyController (CharacterBody3D)

func enter() -> void: pass
func exit() -> void: pass
func update(_delta: float) -> void: pass

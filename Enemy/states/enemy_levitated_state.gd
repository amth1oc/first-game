extends EnemyState
class_name EnemyLevitatedState

@export var lift_speed: float = 30.0
@export var return_state: EnemyState 
var timer: float = 0.0

func enter():
	enemy.velocity.y = lift_speed
	if enemy.weapons_manager:
		enemy.weapons_manager.set_physics_process(false)
	timer = 0.5 

func update(delta):
	timer -= delta
	enemy.velocity.y += enemy.GRAVITY * delta
	
	if timer <= 0 and enemy.is_on_floor():
		# Kiểm tra nếu return_state đã được gán trong Inspector
		if return_state:
			state_machine.change_state(return_state)


func exit():
	if enemy.weapons_manager:
		enemy.weapons_manager.set_physics_process(true)

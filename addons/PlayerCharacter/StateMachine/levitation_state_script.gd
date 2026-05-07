extends State

# đặt tên để state machine quản lý
var state_name : String = "Levitation"

@export var skill_scene: PackedScene = preload("res://VFX/LevitationSkill.tscn")
var skill_instance: Node3D
var play_char : CharacterBody3D # Đổi tên cho giống các state khác

# Sửa lại hàm enter cho đúng định dạng của project
func enter(play_char_ref : CharacterBody3D):
	play_char = play_char_ref
	
	play_char.velocity = Vector3.ZERO 
	
	skill_instance = skill_scene.instantiate()
	play_char.get_tree().root.add_child(skill_instance)

func physics_update(_delta: float):
	if not Input.is_action_pressed("skill_levitation"):
		transitioned.emit(self, "IdleState")
		return
	
	var camera = play_char.cam
	var mouse_pos = play_char.get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_direction = camera.project_ray_normal(mouse_pos)
	
	var space_state = play_char.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_direction * 100)
	query.collision_mask = 1 
	
	var result = space_state.intersect_ray(query)
	if result:
		skill_instance.global_position = result.position + Vector3(0, 0.1, 0)

func exit():
	if skill_instance:
		skill_instance.queue_free()

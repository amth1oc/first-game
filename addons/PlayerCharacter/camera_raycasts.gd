extends Node3D
class_name CameraRaycasts

@onready var aim_ray: RayCast3D = $AimRay
@export var hud_ui: CanvasLayer
func _ready() -> void:
	# Bỏ qua va chạm với Player (owner của script này phải là root node Player)
	if owner is PhysicsBody3D:
		aim_ray.add_exception(owner)

func get_hit_result() -> Dictionary:
	# Cập nhật raycast ngay lập tức trước khi lấy kết quả
	aim_ray.force_raycast_update()
	
	if aim_ray.is_colliding():
	
		return {
			"hit": true,
			"collider": aim_ray.get_collider(),
			"point": aim_ray.get_collision_point(),
			"normal": aim_ray.get_collision_normal()
		}
	else:
		# Nếu không trúng gì, trả về điểm xa nhất của Raycast
		var max_point = aim_ray.global_transform.origin + (-aim_ray.global_transform.basis.z * aim_ray.target_position.length())
		return {
			"hit": false,
			"collider": null,
			"point": max_point,
			"normal": Vector3.UP
		}

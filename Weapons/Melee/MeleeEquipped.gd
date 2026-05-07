extends Node3D
class_name MeleeEquipped

@export var weapon_data: WeaponData
@export var muzzle_point: Marker3D
@export var impact_scene: PackedScene
@export var distance_gamage_melee: float

var current_hit_result: Dictionary

var shooter_body: Node3D:
	set(value):
		shooter_body = value
		# Truyền thông tin người chơi xuống cho script weapon_sway để nó bắt đầu lắc
		if has_node("Model_Holder"):
			var model_holder = get_node("Model_Holder")
			if model_holder.has_method("set_player"):
				model_holder.set_player(value)


var anim_player: AnimationPlayer = null

func _ready() -> void:
	if has_node("AnimationPlayer"):
		anim_player = get_node("AnimationPlayer")

func set_weapon_data(data: WeaponData) -> void:
	weapon_data = data

func attack(hit_result: Dictionary) -> void:
	# 1. Chạy Animation chém
	if anim_player and anim_player.has_animation("fire"):
		anim_player.stop()
		anim_player.play("fire")

	# 2. Xử lý sát thương
	if hit_result.hit:
		var distance = muzzle_point.global_position.distance_to(hit_result.point)
		if distance <= distance_gamage_melee:
			if hit_result.collider.has_method("take_damage"):
				hit_result.collider.take_damage(weapon_data.damage, shooter_body)
			
			# Lực đẩy nếu trúng thùng/hộp (RigidBody)
			if hit_result.collider is RigidBody3D:
				var force_dir = (hit_result.point - muzzle_point.global_position).normalized()
				hit_result.collider.apply_impulse(force_dir * 10.0, hit_result.point - hit_result.collider.global_position)
			
			spawn_impact(hit_result)
				

func spawn_impact(hit_result: Dictionary) -> void:
	if weapon_data.impacts.is_empty(): return
	
	# Xác định bề mặt trúng đạn. Mặc định là "default"
	var surface = "default"
	var collider = hit_result.collider
	
	# Dùng Group trong Godot để làm Tag
	if collider.is_in_group("surface_flesh"):
		surface = "flesh"
	elif collider.is_in_group("surface_metal"):
		surface = "metal"
		
	# Tìm impact scene tương ứng trong mảng weapon_data.impacts
	var chosen_scene: PackedScene = null
	for impact in weapon_data.impacts:
		if impact.surface_tag == surface:
			chosen_scene = impact.impact_scene
			break
			
	# Nếu có cài đặt, tiến hành sinh ra ở điểm va chạm
	if chosen_scene:
		var impact_node = chosen_scene.instantiate()
		get_tree().current_scene.add_child(impact_node)
		impact_node.global_position = hit_result.point
		

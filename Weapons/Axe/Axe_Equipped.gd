extends Node3D

@export var damage: int = 50          # Sát thương lớn
@export var interact_name: String = "Rìu Chiến"
@export var weapon_data: WeaponData

@onready var hitbox: Area3D = $Hitbox
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var is_attacking: bool = false
## các biến khắc phục lỗi 
var shooter_body: Node3D
var current_hit_result: Dictionary


func _ready():
	# Mặc định tắt hitbox để không gây sát thương khi không chém
	hitbox.monitoring = false 

func set_weapon_data(data: WeaponData) -> void:
	weapon_data = data

func attack():
	if is_attacking: return
	is_attacking = true
	anim_player.play("attack_swing")
	
	# Chờ đến thời điểm lưỡi rìu vung ra (dùng tín hiệu hoặc await)
	await get_tree().create_timer(0.15).timeout
	
	_apply_damage()
	
	await anim_player.animation_finished
	is_attacking = false

func spawn_impact_vfx(body: Node3D):
	if not weapon_data or weapon_data.impacts.is_empty(): return
	
	# Xác định loại bề mặt (giống như logic của Dao)
	var surface = "default"
	if body.is_in_group("surface_flesh"): surface = "flesh"
	elif body.is_in_group("surface_metal"): surface = "metal"
	
	# Tìm hiệu ứng tương ứng trong WeaponData
	for impact in weapon_data.impacts:
		if impact.surface_tag == surface:
			var impact_node = impact.impact_scene.instantiate()
			get_tree().current_scene.add_child(impact_node)
			# Vì dùng Area3D, ta lấy vị trí của body làm điểm nổ hiệu ứng
			impact_node.global_position = body.global_position
			break            
# update lại hàm _apply_damage
func _apply_damage():
	hitbox.monitoring = true
	
	# Đợi 1 frame vật lý để đảm bảo Area3D nhận diện được va chạm
	await get_tree().physics_frame
	
	var bodies = hitbox.get_overlapping_bodies()
	for body in bodies:
		# Không tự chém chính mình
		if body == shooter_body: continue 
		if body.has_method("take_damage"):
			# 1. Gây sát thương (truyền thêm shooter_body để AI biết ai chém)
			body.take_damage(damage, shooter_body)
			print("Rìu đã chém trúng: ", body.name)
			
			# 2. Tạo hiệu ứng va chạm
			spawn_impact_vfx(body)
			
			# 3. Tạo lực đẩy (Knockback) cho RigidBody
			if body is RigidBody3D:
				var push_dir = (body.global_position - global_position).normalized()
				push_dir.y = 0.4 # Đẩy hơi nảy lên trên
				body.apply_impulse(push_dir * 15.0) # Lực đẩy 15.0 (tùy chỉnh)

	# Tắt ngay sau khi quét xong
	hitbox.monitoring = false

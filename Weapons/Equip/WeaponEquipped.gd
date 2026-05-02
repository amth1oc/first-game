extends Node3D
# Script này gắn ở Node ngoài cùng của Scene vũ khí (vd: RevolverEquipped)

@export var weapon_data: WeaponData # Resource WeaponData
@export var muzzle_point: Marker3D
@export var tracer_scene: PackedScene
@export var decal_scene: PackedScene
###thêm animation player
#@onready var anim_player: AnimationPlayer = $AnimationPlayerReload
var anim_player: AnimationPlayer = null

func _ready() -> void:
	# Tìm AnimationPlayer nếu có, không có thì bỏ qua (enemy không cần)
	if has_node("AnimationPlayerReload"):
		anim_player = get_node("AnimationPlayerReload")



# Biến tạm để lưu dữ liệu mục tiêu khi người chơi bấm bắn
var current_hit_result: Dictionary
#var shooter_body: Node3D
# ĐỔI từ: var shooter_body: Node3D
# THÀNH: property có setter

var shooter_body: Node3D:
	set(value):
		shooter_body = value
		# Khi WeaponManager gán shooter_body, ngay lập tức truyền xuống WeaponSway
		if has_node("Model_Holder"):
			var model_holder = get_node("Model_Holder")
			if model_holder.has_method("set_player"):
				model_holder.set_player(value)

func set_weapon_data(data: WeaponData) -> void:
	weapon_data = data
	# Khởi tạo băng đạn đầy khi mới nhặt/spawn súng
	weapon_data.initialize_ammo()

func fire_weapon(hit_result: Dictionary) -> void:
	# 1. Logic Hệ Thống
	weapon_data.current_magazine_ammo -= 1
	
	# 2. Gameplay Layer (Trừ máu, áp dụng lực đẩy)
	#if hit_result.hit and hit_result.collider.has_method("take_damage"):
	#	hit_result.collider.take_damage(weapon_data.damage)
	
		# 2. Gameplay Layer (Trừ máu, áp dụng lực đẩy)
	if hit_result.hit and hit_result.collider.has_method("take_damage"):
		# Faction check: không bắn cùng phe
		var my_faction = _get_faction(shooter_body)
		var target_faction = _get_faction(hit_result.collider)
		if my_faction != target_faction or my_faction == "":
			hit_result.collider.take_damage(weapon_data.damage, shooter_body)

	
	# Nếu bắn trúng vật lý RigidBody
	if hit_result.hit and hit_result.collider is RigidBody3D:
		var force_dir = (hit_result.point - muzzle_point.global_position).normalized()
		hit_result.collider.apply_impulse(force_dir * 10.0, hit_result.point - hit_result.collider.global_position)
		
	# 3. VFX Layer (Hiệu ứng)
	spawn_tracer(hit_result.point)
	if hit_result.hit:
		spawn_decal(hit_result.point, hit_result.normal, hit_result.collider)
		
	# 4. Feedback Layer (Recoil, Âm thanh)
	if has_node("Model_Holder"):
		var model_holder = get_node("Model_Holder")
		if model_holder.has_method("apply_recoil"):
			model_holder.apply_recoil(weapon_data)
			
	# Gọi độ giật Camera
	if shooter_body and shooter_body.has_node("%CameraHolder"):
		var cam_holder = shooter_body.get_node("%CameraHolder")
		if cam_holder.has_method("apply_camera_recoil"):
			cam_holder.apply_camera_recoil(weapon_data)

func perform_reload_logic() -> void:
	# Tính số đạn cần nạp để đầy băng
	var ammo_needed = weapon_data.max_magazine_capacity - weapon_data.current_magazine_ammo
	
	# Chỉ lấy tối đa lượng đạn mình đang có trong balo
	var ammo_to_reload = min(ammo_needed, weapon_data.total_ammo)
	
	# Bơm vào băng đạn và trừ ở balo
	weapon_data.current_magazine_ammo += ammo_to_reload
	weapon_data.total_ammo -= ammo_to_reload


func spawn_tracer(target_pos: Vector3) -> void:
	if not tracer_scene or not muzzle_point: return
	var tracer = tracer_scene.instantiate()
	get_tree().current_scene.add_child(tracer)
	tracer.global_position = muzzle_point.global_position
	# Bạn cần viết 1 script nhỏ cho Tracer để bay từ điểm A -> B bằng Tween
	if tracer.has_method("setup"):
		tracer.setup(target_pos)

func spawn_decal(pos: Vector3, normal: Vector3, parent: Node) -> void:
	if not decal_scene: return
	var decal = decal_scene.instantiate()
	parent.add_child(decal)
	decal.global_position = pos
	
	# Thuật toán xoay Decal áp sát vào bề mặt (Align with Normal) an toàn 100%
	var up_dir = normal
	var forward_dir = Vector3.UP
	
	# Nếu bề mặt đang hướng lên hoặc xuống, đổi trục phụ để tránh lỗi
	if abs(up_dir.dot(Vector3.UP)) > 0.99:
		forward_dir = Vector3.RIGHT
		
	var right_dir = up_dir.cross(forward_dir).normalized()
	forward_dir = right_dir.cross(up_dir).normalized()
	
	# Gắn góc xoay mới
	decal.global_transform.basis = Basis(right_dir, up_dir, forward_dir)

func _get_faction(node: Node) -> String:
	if node == null:
		return ""
	if node.is_in_group("player_faction"):
		return "player"
	if node.is_in_group("enemy_faction"):
		return "enemy"
	return ""

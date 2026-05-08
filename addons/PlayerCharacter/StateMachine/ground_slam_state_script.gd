extends State

var state_name : String = "GroundSlam"
var play_char : CharacterBody3D

@export var impact_vfx_scene : PackedScene
@export var slam_speed : float = 40.0
@export var aoe_radius : float = 6.0
@export var aoe_damage : int = 50
@export var knockup_force : float = 12.0
var _aoe_sphere : SphereShape3D
var _aoe_query : PhysicsShapeQueryParameters3D


func enter(play_char_ref : CharacterBody3D):
	play_char = play_char_ref
	# Bắt đầu lao xuống ngay lập tức	
	play_char.velocity = Vector3(0, -slam_speed, 0)
	if not _aoe_sphere:
		_aoe_sphere = SphereShape3D.new()
		_aoe_query = PhysicsShapeQueryParameters3D.new()
		_aoe_query.shape = _aoe_sphere


func physics_update(_delta: float):
	# Nếu chạm đất thì thực hiện nổ AOE
	if play_char.is_on_floor():
		perform_aoe()
		transitioned.emit(self, "IdleState")

func perform_aoe():
	# 1. Thiết lập vùng kiểm tra hình cầu (Sphere)
	var space_state = play_char.get_world_3d().direct_space_state
	
	# Tạo một hình cầu để quét
	_aoe_sphere.radius = aoe_radius
	_aoe_query.transform = play_char.global_transform

	# Chỉ quét các vật thể thuộc lớp va chạm (collision layer) của kẻ địch và đồ vật
	# Mặc định quét tất cả nếu bạn không chắc chắn về layer
	var results = space_state.intersect_shape(_aoe_query)
   
	for result in results:
		var body = result.collider
		
		# Kiểm tra nếu vật thể không phải là chính người chơi
		if body == play_char:
			continue
			
		# TÍNH TOÁN LỰC HẤT
		# Tính hướng từ điểm dậm nhảy đến vật thể
		var direction = (body.global_position - play_char.global_position).normalized()
		# Lực đẩy lên trên kết hợp với một chút lực đẩy ra xa
		var impulse = (direction + Vector3.UP * 1.5).normalized() * knockup_force

		# TRƯỜNG HỢP 1: Là Kẻ địch (CharacterBody3D)
		if body is EnemyController or body.is_in_group("enemy_faction"):
			if body.has_method("take_damage"):
				body.take_damage(aoe_damage, play_char)
			
			# Hất tung bằng cách gán velocity trực tiếp
			body.velocity += impulse
			
		# TRƯỜNG HỢP 2: Là Đồ vật vật lý (RigidBody3D)
		elif body is RigidBody3D:
			# Dùng apply_impulse để đẩy đồ vật bay đi
			# Đẩy tại vị trí hiện tại của vật thể
			body.apply_central_impulse(impulse * body.mass)

	# GỌI HIỆU ỨNG RUNG CAMERA
	# Tìm script camera (nằm trên CameraHolder hoặc theo cách bạn setup)
	var cam_script = play_char.get_node("CameraHolder") # Chỉnh lại đường dẫn nếu cần
	if cam_script and cam_script.has_method("apply_shake"):
		cam_script.apply_shake(0.5) # Độ mạnh 0.5

	# GỌI HIỆU ỨNG HẠT
	spawn_impact_vfx()

func spawn_impact_vfx():
	if impact_vfx_scene:
		var vfx = impact_vfx_scene.instantiate()
		# Thêm vào root để không bị di chuyển theo người chơi
		play_char.get_tree().root.add_child(vfx)
		# Đặt vị trí tại chân người chơi
		vfx.global_position = play_char.global_position

extends Area3D

@export var lift_force: float = 15.0 # Lực đẩy lên
@export var rotation_speed: float = 2.0 # Tốc độ xoay vòng tròn cho đẹp

func _ready():
	collision_mask = 4 + 1 # Layer 3 (Enemy) và Layer 1 (World)

func _physics_process(delta):
	# Xoay vòng tròn nhẹ nhàng để tạo hiệu ứng kỹ năng
	$MeshInstance3D.rotate_y(rotation_speed * delta)
	
	# Quét các đối tượng đang nằm trong vùng
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body is EnemyController:
			# Gọi hàm nhấc bổng trên Enemy
			if body.has_method("levitate"):
				body.levitate()
		if body is RigidBody3D:
			# Đối với các thùng hàng, đồ vật vật lý
			body.apply_central_impulse(Vector3.UP * lift_force * delta * 50.0)
"""
		# Xử lý NHÂN VẬT CHÍNH (Player)
		elif body is PlayerCharacter:
			# Chống lại trọng lực và đẩy nhân vật lên
			# Bạn có thể nhân với một con số để điều chỉnh độ mạnh nhẹ
			body.velocity.y += lift_force * delta * 2.5 
			
			# (Tùy chọn) Chuyển player sang trạng thái trên không nếu đang ở dưới đất
			if body.is_on_floor():
				body.state_machine.on_state_child_transition(body.state_machine.curr_state, "InairState")
"""

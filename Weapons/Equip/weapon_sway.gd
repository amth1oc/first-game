extends Node3D
class_name WeaponSway

@export var player: CharacterBody3D # Kéo thả Player vào đây (hoặc lấy qua get_tree().get_first_node_in_group("player"))
@export var sway_amount: float = 0.005
@export var sway_smooth: float = 8.0
@export var bob_amount: float = 0.006
@export var bob_freq: float = 8.0

var initial_position: Vector3
var initial_rotation: Vector3
var time_passed: float = 0.0

# Biến lưu trữ độ giật hiện tại
var current_recoil_pos: Vector3 = Vector3.ZERO
var current_recoil_rot: Vector3 = Vector3.ZERO
var recoil_recovery_speed: float = 7.0

func _ready() -> void:
	initial_position = position
	initial_rotation = rotation
	
#	if not player:
#		# Chờ 1 frame
#		await get_tree().process_frame
#		
#		# Lấy trực tiếp shooter_body từ WeaponManager truyền xuống
#		if owner and "shooter_body" in owner and owner.shooter_body:
#			player = owner.shooter_body
##############fixx để kết nối với character3D luôn
###tránh trường hợp chờ 1 frame mà dẫn đến lỗi 
## bây giờ thì biến shooter_body(từ Weapon manager) chủ động hơn 
##nó không chờ mà đưa dữ liệu xuống cho weapon_sway
func set_player(body: Node3D) -> void:
	player = body

#######################đã fixx độ giật nhẹ lên trên
func apply_recoil(data: WeaponData) -> void:
	# --- POSITION RECOIL ---
	var vertical_kick: float = absf(data.recoil_kickback) * 0.15
	current_recoil_pos.y += vertical_kick

	current_recoil_pos.x += randf_range(-0.002, 0.002)

	# --- ROTATION RECOIL ---
	var pitch: float = deg_to_rad(data.recoil_rotation_degrees.x)
	current_recoil_rot.x -= absf(pitch)

	var yaw: float = deg_to_rad(data.recoil_rotation_degrees.y)
	current_recoil_rot.y += randf_range(-yaw, yaw)

	var roll: float = deg_to_rad(data.recoil_rotation_degrees.z)
	current_recoil_rot.z += randf_range(-roll, roll)

	recoil_recovery_speed = data.recovery_speed
	



	
func _process(delta: float) -> void:
	if not player: return
	
	# Sway (Nghiêng nhẹ khi đi ngang)
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var target_pos = initial_position
	
	target_pos.x -= input_dir.x * sway_amount
	target_pos.z -= input_dir.y * sway_amount
	
	# Bobbing (Nhịp bước chân)
	var speed = player.velocity.length()
	if speed > 1.0 and player.is_on_floor():
		time_passed += delta * bob_freq * (speed / 5.0)
		target_pos.y += sin(time_passed) * bob_amount
		target_pos.x += cos(time_passed / 2.0) * bob_amount
	else:
		time_passed = 0.0 # Reset khi đứng yên
		
	# Xử lý phục hồi độ giật (Recoil Recovery)
	current_recoil_pos = current_recoil_pos.lerp(Vector3.ZERO, recoil_recovery_speed * delta)
	current_recoil_rot = current_recoil_rot.lerp(Vector3.ZERO, recoil_recovery_speed * delta)
	
	# Cộng dồn Recoil vào vị trí mục tiêu
	target_pos += current_recoil_pos
		
	# Smooth nội suy để mượt (Cả Position và Rotation)
	position = position.lerp(target_pos, sway_smooth * delta)
	rotation = rotation.lerp(initial_rotation + current_recoil_rot, sway_smooth * delta)

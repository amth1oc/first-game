extends State
class_name GrappleState

var state_name : String = "Grapple"
var play_char : CharacterBody3D

# CÁC BIẾN CẤU HÌNH
@export_group("Grapple Settings")
@export var pull_strength: float = 15.0   # Lực kéo về tâm
@export var lift_strength: float = 12.0   # Lực nâng liên tục khi đang đu
@export var release_boost: float = 1    # Hệ số đẩy khi buông dây
@export var swing_control: float = 5.0   # Độ linh hoạt khi nhấn WASD lúc đu
@export var rotation_katana_degrees_z: float = 160 #góc độ z quay kiếm khi đu
@export var rotation_katana_degrees_x: float = 10
# Biến nội bộ
var grapple_point : Vector3
var rope_visual : MeshInstance3D

func enter(play_char_ref : CharacterBody3D):
	play_char = play_char_ref
	
	# 1. Tìm điểm bám
	var aim_ray = play_char.weapons_manager.aim_ray
	aim_ray.force_raycast_update()
	
	if not aim_ray.is_colliding():
		transitioned.emit(self, "InairState")
		return
	grapple_point = aim_ray.get_collision_point()
	# XOAY KIẾM 180 ĐỘ
	#var weapon = play_char.weapons_manager.current_weapon_instance
	#if weapon:
	#	weapon.rotation_degrees.z += rotation_katana_degrees_z
	#	weapon.rotation_degrees.x += rotation_katana_degrees_x
	# 2. Tạo sợi dây hiển thị
	_setup_rope_visual()

func exit():
	# 3. LỰC BOOST KHI BUÔNG TAY (RELEASE BOOST)
	if play_char.velocity.length() > 2.0:
		# Đẩy mạnh theo hướng đang bay
		play_char.velocity += play_char.velocity.normalized() * pull_strength * 0.05 * release_boost
	
	# Cộng thêm lực nâng cuối cùng
	play_char.velocity.y += lift_strength * 0.1
	# XOAY KIẾM TRỞ LẠI BÌNH THƯỜNG
	#var weapon = play_char.weapons_manager.current_weapon_instance
	#if weapon:
	#	weapon.rotation_degrees.z -= rotation_katana_degrees_z
	#	weapon.rotation_degrees.x -= rotation_katana_degrees_x
	var weapon = play_char.weapons_manager.current_weapon_instance
	if weapon:
		var tween = create_tween()
		tween.tween_property(weapon, "rotation_degrees", Vector3(0, 0, 0), 0.1)
		tween.tween_property(weapon, "position", Vector3(0, 0, 0), 0.1)
	_cleanup_visuals()


func physics_update(delta: float):
	# 4. LOGIC ĐU DÂY CHÍNH
	_process_grapple_movement(delta)
	# Cập nhật hình ảnh dây
	_update_rope_visual()
	# --- LOGIC QUAY KATANA THEO DÂY ---
	var weapon = play_char.weapons_manager.current_weapon_instance
	if weapon:
		# 1. Tính toán hướng từ kiếm tới điểm bám
		var target_pos = grapple_point
		# 2. Bắt kiếm nhìn về phía điểm bám
		# Lưu ý: look_at mặc định sẽ hướng mũi kiếm (trục -Z) về mục tiêu.
		# Vì bạn muốn hướng CÁN KIẾM về đó, nên ta sẽ dùng một mẹo nhỏ:
		weapon.look_at(target_pos, Vector3.DOWN)
		# 3. Sau khi nhìn, ta xoay thêm 180 độ để CÁN hướng về phía trước thay vì MŨI
		weapon.rotation_degrees.x += 20 
		weapon.rotation_degrees.y += 200
		weapon.translate(Vector3(-0.0002, 0, 0))
		
		# 4. (Tùy chọn) Làm cho chuyển động xoay mượt mà hơn bằng lerp
		# Nếu bạn thấy kiếm xoay quá gắt, hãy dùng lerp_angle

	# 5. Thoát khi buông phím
	if not Input.is_action_pressed("grapple"):
		transitioned.emit(self, "InairState")

func _process_grapple_movement(delta):
	var to_grapple = grapple_point - play_char.global_position
	var direction = to_grapple.normalized()
	var distance = to_grapple.length()

	# --- A. Lực kéo chính (Pull) ---
	var pull_force = direction * pull_strength
	
	# --- B. Lực nâng (Lift) - Giúp nhân vật bay bổng ---
	var lift = Vector3.UP * lift_strength
	
	# --- C. Điều khiển hướng (Swing Control) ---
	var input_dir = Input.get_vector(play_char.move_left_action, play_char.move_right_action, play_char.move_forward_action, play_char.move_backward_action)
	var control_dir = (play_char.cam_holder.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var control_force = control_dir * swing_control
	
	# --- D. Giữ căng dây (Tension) ---
	# Nếu người chơi đang ở xa hơn độ dài dây, ta triệt tiêu vận tốc hướng ra ngoài
	var vel_dot_dir = play_char.velocity.dot(direction)
	if vel_dot_dir < 0: # Đang bay ra xa khỏi tâm
		# Làm cho lực kéo mạnh hơn để giữ nhân vật quay quanh tâm
		pull_force *= 1.2

	# --- Tổng hợp lực ---
	var total_force = pull_force + lift + control_force
	
	# Áp dụng vào velocity (Sử dụng delta để mượt mà trên mọi FPS)
	play_char.velocity += total_force * delta

# --- PHẦN HIỂN THỊ DÂY (VISUAL) ---
"""khó thấy quá
func _setup_rope_visual():
	rope_visual = MeshInstance3D.new()
	rope_visual.mesh = ImmediateMesh.new()
	get_tree().root.add_child(rope_visual)
"""
func _setup_rope_visual():
	rope_visual = MeshInstance3D.new()
	rope_visual.mesh = ImmediateMesh.new()

	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.8, 1.0) # xanh sáng
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED # luôn sáng
	mat.emission_enabled = true
	mat.emission = Color(0.2, 0.8, 1.0)
	mat.emission_energy = 3.0

	rope_visual.material_override = mat

	get_tree().root.add_child(rope_visual)


func _update_rope_visual():
	if not rope_visual: return
	var im_mesh : ImmediateMesh = rope_visual.mesh
	im_mesh.clear_surfaces()
	im_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	
	var start_pos = play_char.cam.global_position
	# Thử lấy vị trí nòng súng nếu có
	if play_char.weapons_manager.current_weapon_instance:
		var weapon = play_char.weapons_manager.current_weapon_instance
		if weapon.has_node("Model_Holder/MuzzlePoint"):
			start_pos = weapon.get_node("Model_Holder/MuzzlePoint").global_position
			
	im_mesh.surface_add_vertex(start_pos)
	im_mesh.surface_add_vertex(grapple_point)
	im_mesh.surface_end()

func _cleanup_visuals():
	if rope_visual: rope_visual.queue_free()

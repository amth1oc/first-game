extends Node3D

@export_group("Settings")
@export var pull_strength: float = 50
@export var max_distance: float = 50.0
@export var rope_color: Color = Color.WHITE

@onready var muzzle: Marker3D = $Model_Holder/MuzzlePoint
@onready var raycast: RayCast3D = $RayCast3D
@onready var rope_mesh: MeshInstance3D = $RopeVisual

var shooter_body: CharacterBody3D # Chính là Player
var is_grappling: bool = false
var grapple_point: Vector3
var immediate_mesh: ImmediateMesh
var current_hit_result: Dictionary

func _ready():
	# Khởi tạo Mesh để vẽ dây
	immediate_mesh = rope_mesh.mesh
	rope_mesh.visible = false # Mặc định ẩn dây đi

func set_weapon_data(_data):
	pass # Grapple không cần dùng nhiều data stats

func _physics_process(delta):
	if not shooter_body: return
	
	# Kiểm tra phím bắn (Chuột trái)
	if Input.is_action_pressed("fire"):
		if not is_grappling:
			_start_grapple()
	else:
		if is_grappling:
			_stop_grapple()

	if is_grappling:
		_process_grapple_logic(delta)
		_draw_rope()

# --- CƠ CHẾ MÓC DÂY ---
func _start_grapple():
	if raycast.is_colliding():
		grapple_point = raycast.get_collision_point()
		is_grappling = true
		rope_mesh.visible = true
		print("Đã móc vào: ", grapple_point)

func _stop_grapple():
	is_grappling = false
	rope_mesh.visible = false

# --- LOGIC VẬT LÝ (PHONG CÁCH KARLSON) ---
# --- TRONG FILE GrappleEquipped.gd ---
func _process_grapple_logic(delta):
	var direction = (grapple_point - shooter_body.global_position).normalized()
	
	# Thay vì cộng dồn yếu ớt, ta đẩy mạnh vận tốc theo hướng móc
	# Nếu muốn cảm giác giống Karlson, lực kéo phải đủ mạnh để nhấc bổng người lên
	var pull_vector = direction * pull_strength
	
	# Cộng thêm một chút lực hướng lên để không bị rơi quá nhanh
	pull_vector += Vector3.UP * 9.8 * delta * 2.0 
	
	shooter_body.velocity += pull_vector * delta * 60.0


# --- VẼ SỢI DÂY ---
func _draw_rope():
	immediate_mesh.clear_surfaces()
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	# Điểm đầu tại nòng súng
	immediate_mesh.surface_add_vertex(muzzle.global_position)
	# Điểm cuối tại điểm móc (chuyển về local space của súng)
	immediate_mesh.surface_add_vertex(grapple_point)
	immediate_mesh.surface_end()

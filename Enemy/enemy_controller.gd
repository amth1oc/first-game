extends CharacterBody3D
class_name EnemyController

# === EXPORTS ===
@export var weapon_data_resource: WeaponData
@export var move_speed: float = 4.0
@export var rotation_speed: float = 6.0

# === NODE REFERENCES ===
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var detection_area: Area3D = $DetectionArea
@onready var aim_ray: RayCast3D = $AimRay
@onready var weapons_manager: WeaponManager = $WeaponAnchor/WeaponManager

# === STATE ===
var target_player: CharacterBody3D = null
var weapon_data: WeaponData  # bản duplicate riêng

const GRAVITY: float = -9.8

func _ready() -> void:
	add_to_group("enemy_faction")
	# Dùng call_deferred để chạy SAU KHI toàn bộ _ready() xong
	_setup.call_deferred()

func _setup() -> void:
	# Duplicate WeaponData
	if weapon_data_resource:
		weapon_data = weapon_data_resource.duplicate(true)
		weapon_data.initialize_ammo()
	
	# Setup WeaponManager
	if weapons_manager and weapon_data:
		weapons_manager.weapon_data_array = [weapon_data]
		weapons_manager.shooter_body = self
		weapons_manager.aim_ray = aim_ray
		# Khởi tạo lại vì _ready() đã chạy với array rỗng
		weapons_manager.weapons_initialized = false
		weapons_manager._initialize_all_weapons()
		weapons_manager.switch_weapon(0)
	
	# Kết nối signals
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	move_and_slide()

# === NAVIGATION ===
func navigate_to_target(delta: float) -> void:
	if navigation_agent.is_navigation_finished():
		velocity.x = 0.0
		velocity.z = 0.0
		return
	var next_pos = navigation_agent.get_next_path_position()
	var dir = (next_pos - global_position).normalized()
	velocity.x = dir.x * move_speed
	velocity.z = dir.z * move_speed
	print("Moving toward: ", next_pos, " vel: ", velocity)  # debug
	

func strafe_around_player(delta: float) -> void:
	if not target_player:
		return
	var wd = get_current_weapon_data()
	if not wd:
		return
	var ideal_dist = wd.ai_attack_range * 0.6
	var dist = global_position.distance_to(target_player.global_position)
	if dist > ideal_dist + 2.0:
		navigation_agent.target_position = target_player.global_position
	elif dist < ideal_dist - 2.0:
		var away = (global_position - target_player.global_position).normalized()
		navigation_agent.target_position = global_position + away * 4.0
	navigate_to_target(delta)

func take_cover_while_reloading() -> void:
	if not target_player:
		return
	var away = (global_position - target_player.global_position).normalized()
	navigation_agent.target_position = global_position + away * 6.0

# === DETECTION ===
func can_see_player() -> bool:
	if not target_player:
		return false
	aim_ray.target_position = aim_ray.to_local(target_player.global_position + Vector3(0, 0.8, 0))
	aim_ray.force_raycast_update()
	if not aim_ray.is_colliding():
		return false
	var col = aim_ray.get_collider()
	return col == target_player or col.is_in_group("player_faction")

func get_player_position() -> Vector3:
	if target_player:
		return target_player.global_position
	return global_position

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("PlayerCharacter") and target_player == null:
		target_player = body as CharacterBody3D

func _on_body_exited(body: Node3D) -> void:
	if body == target_player:
		target_player = null

# === AIMING ===
func look_at_player(delta: float) -> void:
	if not target_player:
		return
	var target_flat = target_player.global_position
	target_flat.y = global_position.y
	if target_flat.distance_to(global_position) < 0.1:
		return
	var desired = global_transform.looking_at(target_flat, Vector3.UP)
	transform = transform.interpolate_with(desired, rotation_speed * delta)

func aim_at_player_with_accuracy(accuracy: float) -> void:
	if not target_player:
		return
	var noise_range = (1.0 - accuracy) * 2.5
	var aim_target = target_player.global_position + Vector3(0, 0.8, 0)
	aim_target += Vector3(
		randf_range(-noise_range, noise_range),
		randf_range(-noise_range * 0.5, noise_range * 0.5),
		0.0
	)
	aim_ray.target_position = aim_ray.to_local(aim_target)

# === WEAPON HELPER ===
func get_current_weapon_data() -> WeaponData:
	if weapons_manager and weapons_manager.current_weapon_instance:
		return weapons_manager.current_weapon_instance.weapon_data
	return weapon_data

# === TAKE DAMAGE (player sẽ gọi hàm này) ===
func take_damage(amount: int, _shooter = null) -> void:
	print("Enemy nhận %d damage!" % amount)
	# TODO: thêm HP system sau

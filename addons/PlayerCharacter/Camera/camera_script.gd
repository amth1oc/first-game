extends Node3D

#class name
class_name CameraObject 

#camera variables
@export_group("Camera variables")
@export_range(0.0, 0.5, 0.001) var x_axis_sensibility : float = 0.05
@export_range(0.0, 0.5, 0.001) var y_axis_sensibility : float = 0.05
@export_range(-360.0, 0.0, 0.01) var max_up_angle_view : float = -90.0 #in degrees
@export_range(0.0, 360.0, 0.01) var max_down_angle_view : float = 90.0 #in degrees
@export_range(5.0, 175.0, 0.01) var fov : float = 90.0

@export_group("fov variables")
@export_range(0.0, 180.0, 0.01) var min_fov_val : float = 10.0
@export_range(0.0, 180.0, 0.01) var max_fov_val : float = 170.0
@export var cam_fov_per_state : Dictionary[String, Vector2] = {
	"Default" : Vector2(90.0, 0.2),
	"Idle" : Vector2(90.0, 0.2),
	"Crouch" : Vector2(90.0, 0.2),
	"Walk" : Vector2(90.0, 0.2),
	"Run" : Vector2(100.0, 0.2),
	"Slide" : Vector2(100.0, 0.2),
	"Dash" : Vector2(110.0, 0.05),
	"Fly" : Vector2(100.0, 0.2)
}

@export_group("Zoom variables")
var zoom_on : bool = false
var zoom_has_occured : bool = false
@export_range(-180.0, 180.0, 1.0) var zoom_val : float = 40.0
@export_range(0.0, 3.0, 0.01) var zoom_duration : float = 0.2

@export_group("Tilt variables")
@export var enable_forward_tilt : bool = true
@export var enable_side_tilt : bool = true
var tilt_tween : Tween
var last_input_y : float

@export_group("Bob variables")
@export var enable_headbob : bool = true
@export_range(0.0, 1.0, 0.001) var cam_max_v_offset : float = 0.3
@export_range(0.0, 15.0, 0.1) var cam_v_offset_to_0_speed : float = 1.0
var step_timer : float = 0.0

@export_group("Recoil variables")
var target_camera_recoil: Vector2 = Vector2.ZERO
var current_camera_recoil: Vector2 = Vector2.ZERO
var camera_recoil_recovery_speed: float = 7.0

@export_group("Keybind variables")
@export var zoom_action : StringName = "play_char_zoom_action"
@export var fire_action : StringName = "fire"
@export var interact_action : StringName = "interact" 
@export var mouse_mode_action : StringName = "play_char_mouse_mode_action"

@onready var input_actions_list : Array[StringName] = [zoom_action, mouse_mode_action, fire_action, interact_action]
@export var check_on_ready_if_inputs_registered : bool = true
var default_input_actions : Dictionary

@export var weapons_manager : WeaponManager
var state : String

@onready var camera : Camera3D = $Camera
@onready var play_char : PlayerCharacter = $".."
@onready var hud : CanvasLayer = $"../HUD"

func _ready() -> void:
	if not weapons_manager and has_node("Camera/WeaponManager"):
		weapons_manager = $Camera/WeaponManager
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.fov = fov
	build_default_keybinding()
	input_actions_check()

func build_default_keybinding() -> void:
	var zoom_event = InputEventMouseButton.new()
	zoom_event.button_index = MOUSE_BUTTON_RIGHT
	var fire_event = InputEventMouseButton.new()
	fire_event.button_index = MOUSE_BUTTON_LEFT
	var mouse_mode_event = InputEventKey.new()
	mouse_mode_event.physical_keycode = KEY_ESCAPE
	var interact_event = InputEventKey.new()
	interact_event.physical_keycode = KEY_V

	default_input_actions = {
		zoom_action : [zoom_event],
		mouse_mode_action : [mouse_mode_event],
		fire_action : [fire_event],
		interact_action : [interact_event]
	}

func input_actions_check() -> void:
	if check_on_ready_if_inputs_registered:
		var registered_input_actions: Array[StringName] = []
		for input_action in InputMap.get_actions():
			if input_action.begins_with(&"play_char_"):
				registered_input_actions.append(input_action)
		for input_action in input_actions_list:
			if not registered_input_actions.has(input_action):
				InputMap.add_action(input_action)
				for keycode_or_event in default_input_actions[input_action]:
					InputMap.action_add_event(input_action, keycode_or_event)

func _process(delta: float) -> void:
	zoom()
	mouse_mode()
	process_camera_recoil(delta)

	# ĐOẠN XỬ LÝ BẮN LIÊN THANH
	if weapons_manager and weapons_manager.current_weapon_instance:
		# Lấy dữ liệu của khẩu súng đang cầm
		var current_data = weapons_manager.weapon_data_array[weapons_manager.current_weapon_index]
		
		# Nếu súng được bật chế độ Liên thanh VÀ chuột trái đang bị GIỮ (is_action_pressed)
		if current_data.is_automatic and Input.is_action_pressed("fire"):
			weapons_manager.attack()

func process_camera_recoil(delta: float) -> void:
	var previous_recoil = current_camera_recoil
	target_camera_recoil = target_camera_recoil.lerp(Vector2.ZERO, camera_recoil_recovery_speed * delta)
	current_camera_recoil = current_camera_recoil.lerp(target_camera_recoil, 25.0 * delta)
	var recoil_diff = current_camera_recoil - previous_recoil
	camera.rotation.x += recoil_diff.x
	rotation.y += recoil_diff.y
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(max_up_angle_view), deg_to_rad(max_down_angle_view))

func _unhandled_input(event) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * (x_axis_sensibility / 10))
		camera.rotate_x(-event.relative.y * (y_axis_sensibility / 10))
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(max_up_angle_view), deg_to_rad(max_down_angle_view))

func _input(event: InputEvent) -> void:
	if weapons_manager:
		if event.is_action_pressed("fire"):
			# Chỉ những súng bắn phát một (không automatic) mới dùng hàm _input này
			var current_data = weapons_manager.weapon_data_array[weapons_manager.current_weapon_index]
			if not current_data.is_automatic:
				weapons_manager.attack()
		if event.is_action_pressed("reload"):
			weapons_manager.reload_current_weapon()
		if event.is_action_pressed("weapon_scroll_up"):
			weapons_manager.switch_to_next_weapon()
		elif event.is_action_pressed("weapon_scroll_down"):
			weapons_manager.switch_to_previous_weapon()
		if event.is_action_pressed("throw_weapon"):
			weapons_manager.throw_current_weapon(weapons_manager.get_throw_direction())
####################xóa nó vì giờ đã có cánh tay là Interactor làm nhiệm vụ này rồi
	#if event.is_action_pressed("interact"):
	#	var interact_ray = $Camera/CameraRaycasts/InteractRay
	#	if interact_ray.is_colliding():
	#		var target = interact_ray.get_collider()
	#		if target.has_method("get_weapon_data"):
	#			var new_data = target.get_weapon_data()
	#			if weapons_manager.pickup_weapon(new_data):
	#				target.queue_free()

func apply_camera_recoil(recoil_data: WeaponData) -> void:
	var pitch = -abs(deg_to_rad(recoil_data.recoil_rotation_degrees.x)) * recoil_data.recoil_impact_multiplier
	var yaw = deg_to_rad(recoil_data.recoil_rotation_degrees.y) * recoil_data.recoil_impact_multiplier
	target_camera_recoil.x += pitch
	target_camera_recoil.y += yaw
	camera_recoil_recovery_speed = recoil_data.recovery_speed

func zoom() -> void:
	if Input.is_action_pressed(zoom_action):
		camera.fov = lerp(camera.fov, zoom_val, zoom_duration)


func mouse_mode() -> void:
	if Input.is_action_just_pressed(mouse_mode_action):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func change_fov() -> void:
	#for state related fov change requests
	#if zoom is occuring, pass the rest of the function
	if zoom_has_occured:
		return
	
	#manage the fov changes relative to a specific state
	state = play_char.state_machine.curr_state_name
	
	camera.fov = clamp(camera.fov, min_fov_val, max_fov_val)
	
	var fov_change_tween : Tween = get_tree().create_tween()
	
	if !zoom_on and !zoom_has_occured:
		if state != null and state != "Jump" and state != "Inair" and state != "Wallrun":
			fov_change_tween.tween_property(camera, "fov", cam_fov_per_state[state][0], cam_fov_per_state[state][1])
			fov_change_tween.finished.connect(Callable(fov_change_tween, "kill"))
		else:
			#default value used for case like this one, when you need to force a fov change for a state that doesn't have his own setted fov
			if state != "Jump" and state != "Inair" and state != "Wallrun":
				fov_change_tween.tween_property(camera, "fov", cam_fov_per_state["Default"][0], cam_fov_per_state["Default"][1])
				fov_change_tween.finished.connect(Callable(fov_change_tween, "kill"))
			else:
				#not a great piece of code, but that's the most effective and simple way a found to solve the issue
				#that if you dezoom while being in Jump in Inair state, since these two states doesn't have a fixed fov
				#the fov would go back to the default one, even if play char jump with the Run state fov
				
				var walk_or_run_state : String
				if play_char.walk_or_run == "WalkState":
					walk_or_run_state = "Walk"
				if play_char.walk_or_run == "RunState":
					if (play_char.velocity.x < 1.0 and play_char.velocity.x > -1.0 and play_char.velocity.z < 1.0 and play_char.velocity.z > -1.0): #play char not moving at all on x and z axis
						walk_or_run_state = "Walk"
					else:
						walk_or_run_state = "Run"
						
				fov_change_tween.tween_property(camera, "fov", cam_fov_per_state[walk_or_run_state][0], cam_fov_per_state[walk_or_run_state][1])
				fov_change_tween.finished.connect(Callable(fov_change_tween, "kill"))
				
	#doesn't set zoom boolean to false right now, because we want the zoom to occur whatever the current state of play char is
	if zoom_on and !zoom_has_occured:
		zoom_has_occured = true
		fov_change_tween.tween_property(camera, "fov", camera.fov - zoom_val, zoom_duration)
		fov_change_tween.finished.connect(Callable(fov_change_tween, "kill"))
		

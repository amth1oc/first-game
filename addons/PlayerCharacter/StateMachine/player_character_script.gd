extends CharacterBody3D

class_name PlayerCharacter

signal health_changed(current, max)

@export_group("Health")
@export var max_health: int = 100
var current_health: int = 100


@export_group("Movement variables")
var move_speed: float
var move_accel: float
var move_deccel: float
var input_direction: Vector2
var move_direction: Vector3
var desired_move_speed: float

@export_group("Components")
@export var weapons_manager: WeaponManager

@export var desired_move_speed_curve: Curve #accumulated speed
@export var max_desired_move_speed: float = 30.0
@export var in_air_move_speed_curve: Curve
@export var hit_ground_cooldown: float = 0.1 #amount of time the character keep his accumulated speed before losing it (while being on ground)
var hit_ground_cooldown_ref: float
@export var bunny_hop_dms_incre: float = 3.0 #bunny hopping desired move speed incrementer
@export var auto_bunny_hop: bool = false
var last_frame_position: Vector3
var last_frame_velocity: Vector3
var was_on_floor: bool
var walk_or_run: String = "WalkState" #keep in memory if play char was walking or running before being in the air
#for states that require visible changes of the model
@export var base_hitbox_height: float = 2.0
@export var base_model_height: float = 1.0
@export var height_change_duration: float = 0.15

@export_group("Crouch variables")
@export var crouch_speed: float = 6.0
@export var crouch_accel: float = 12.0
@export var crouch_deccel: float = 11.0
@export var continious_crouch: bool = false #if true, doesn't need to keep crouch button on to crouch
@export var crouch_hitbox_height: float = 1.2
@export var crouch_model_height: float = 0.6

@export_group("Walk variables")
@export var walk_speed: float = 9.0
@export var walk_accel: float = 11.0
@export var walk_deccel: float = 10.0

@export_group("Run variables")
@export var run_speed: float = 14.0
@export var run_accel: float = 10.0
@export var run_deccel: float = 9.0
@export var continious_run: bool = false #if true, doesn't need to keep run button on to run

@export_group("Jump variables")
@export var jump_height: float = 3.0
@export var jump_time_to_peak: float = 0.3
@export var jump_time_to_fall: float = 0.35
@onready var jump_velocity: float = (2.0 * jump_height) / jump_time_to_peak
@export var jump_cooldown: float = 0.25
var jump_cooldown_ref: float
@export var nb_jumps_in_air_allowed: int = 1
var nb_jumps_in_air_allowed_ref: int
var jump_buff_on: bool = false
var buffered_jump: bool = false
@export var coyote_jump_cooldown: float = 0.3
var coyote_jump_cooldown_ref: float
var coyote_jump_on: bool = false

@export_group("Slide variables")
var slide_direction: Vector3 = Vector3.ZERO
@export var use_desired_move_speed: bool = false
@export var slide_speed: float = 15.0
@export var slide_accel: float = 23.0
@export var slide_time: float = 1.2
var slide_time_ref: float
@export var time_bef_can_slide_again: float = 1.5
var time_bef_can_slide_again_ref: float
@export_range(0.0, 90.0, 0.1) var max_slope_angle: float = 75.0 #max slope angle where the slide time operate
@export_range(0.0, 0.1, 0.001) var uphill_tolerance : float = 0.05 #vertical tolerance, to avoid fake uphills
@export var amount_velocity_lost_per_sec: float = 4.0
@export var slope_sliding_dms_incre: float = 2.0 #slope sliding desired move speed incrementer
@export var slope_sliding_ms_incre: float = 2.0 #slope sliding slide speed incrementer
@export var priority_over_crouch: bool = true #if enabled, give priority over crouch state (because crouch and slide actions are assigned at the same input action)
@export var continious_slide: bool = true
var slide_buff_on: bool = false
@export var slide_hitbox_height: float = 1.0
@export var slide_model_height: float = 0.5

@export_group("Dash variables")
var dash_direction: Vector3 = Vector3.ZERO
@export var dash_speed: float = 100.0
@export var dash_time: float = 0.1
var dash_time_ref: float
@export var nb_dashs_allowed: int = 3
var nb_dashs_allowed_ref: int
@export var time_bef_can_dash_again: float = 0.8
var time_bef_can_dash_again_ref: float
@export var time_bef_reload_dash: float = 3.0
var time_bef_reload_dash_ref: float
var velocity_pre_dash : Vector3
var has_dashed : bool = false

@export_group("Wallrun variables")
var can_wallrun : bool = true
var side_check_raycast_collided : int = 0 #if -1, left side, if 1, right side
var last_wallrunned_wall_out_of_time : int = 0 #if -1, left side, if 1, right side
var wall_normal : Vector3 = Vector3.ZERO
var wall_forward_dir : Vector3 = Vector3.ZERO
@export var use_desired_move_speed_wallrun : bool = false
@export var wallrun_speed : float = 20.0
@export var wallrun_accel : float = 2.3
@export var wallrun_deccel : float = 7.0
@export_range(0.0, 1.0, 0.001) var wallrun_fall_gravity_multiplier : float = 0.006
@export var wallrun_time : float = 3.5
var wallrun_time_ref : float 
@export var infinite_wallrun_time : bool = false
@export var time_bef_can_wallrun_again : float = 0.2
var time_bef_can_wallrun_again_ref : float
@export var wallrunning_dms_incre : float = 1.0

@export_group("Walljump variables")
var about_to_jump_vel : Vector3
@export var walljump_push_force : float = 15.0
@export var walljump_y_velocity : float = 9.0
@export var walljump_lock_in_air_movement_time : float = 0.15
var walljump_lock_in_air_movement_time_ref : float

@export_group("Fly variables")
@export var fly_speed: float = 20.0
@export var fly_accel: float = 15.0
@export var fly_deccel: float = 15.0
@export var fly_boost_multiplier: float = 3.0
var fly_boost_on: bool = false

@export_group("Gravity variables")
@onready var jump_gravity: float = (-1.5 * jump_height) / (jump_time_to_peak * jump_time_to_peak)
@onready var fall_gravity: float = (-2.0 * jump_height) / (jump_time_to_fall * jump_time_to_fall)

@export_group("Focus Variables")
@export var focus_time_scale : float = 0.3 # Thời gian chậm lại còn 30%
@export var focus_drain_speed : float = 20.0 # Tốn 20 năng lượng mỗi giây
@export var focus_regen_speed : float = 10.0 # Hồi 10 năng lượng mỗi giây
@export var max_focus : float = 100.0
var current_focus : float = 100.0
var is_focusing : bool = false


@export_group("Keybind variables")
@export var move_forward_action: StringName = "move_forward"
@export var move_backward_action: StringName = "move_backward"
@export var move_left_action: StringName = "move_left"
@export var move_right_action: StringName = "move_right"
@export var run_action: StringName = "run"
@export var crouch_action: StringName = "crouch"
@export var jump_action: StringName = "jump"
@export var slide_action: StringName = "slide"
@export var dash_action: StringName = "dash"
@export var fly_action: StringName = "fly"
@export var reload_action : StringName = "reload"
@export var inspect_action : StringName = "inspect"
@export var throw_weapon : StringName = "throw_weapon"
@export var interact : StringName = "interact"
@export var skill_levitation : StringName = "skill_levitation"

@onready var input_actions_list : Array[StringName] = [move_forward_action, move_backward_action, move_left_action, move_right_action, 
run_action, crouch_action, jump_action, slide_action, dash_action, fly_action, skill_levitation]
@export var check_on_ready_if_inputs_registered : bool = true
var default_input_actions : Dictionary

#references variables
@onready var cam_holder: Node3D = $CameraHolder
@onready var cam: Camera3D = %Camera
@onready var model: MeshInstance3D = $Model
@onready var hitbox: CollisionShape3D = $Hitbox
@onready var state_machine: Node = $StateMachine
@onready var hud: CanvasLayer = $HUD
@onready var hud_ui: CanvasLayer = $HUD_UI
@onready var ceiling_check: RayCast3D = %CeilingCheck
@onready var floor_check: RayCast3D = %FloorCheck
@onready var wallrun_floor_check : RayCast3D = %WallrunFloorCheck
@onready var slide_floor_check: RayCast3D = %SlideFloorCheck
@onready var left_wall_check : RayCast3D = %LeftWallCheck
@onready var right_wall_check : RayCast3D = %RightWallCheck
@onready var focus_overlay = $HUD_UI/FocusOverlay 

func _ready() -> void:
	###### thêm vào player group
	add_to_group("player_faction")
	#set and value references
	hit_ground_cooldown_ref = hit_ground_cooldown
	jump_cooldown_ref = jump_cooldown
	jump_cooldown = -1.0
	nb_jumps_in_air_allowed_ref = nb_jumps_in_air_allowed
	coyote_jump_cooldown_ref = coyote_jump_cooldown
	slide_time_ref = slide_time
	time_bef_can_slide_again_ref = time_bef_can_slide_again
	time_bef_can_slide_again = -1.0
	time_bef_can_dash_again_ref = time_bef_can_dash_again
	time_bef_can_dash_again = -1.0
	time_bef_reload_dash_ref = time_bef_reload_dash
	time_bef_reload_dash = -1.0
	nb_dashs_allowed_ref = nb_dashs_allowed
	wallrun_time_ref = wallrun_time
	time_bef_can_wallrun_again_ref = time_bef_can_wallrun_again
	walljump_lock_in_air_movement_time_ref = walljump_lock_in_air_movement_time
	walljump_lock_in_air_movement_time = -1.0
	
	build_default_keybinding()
	input_actions_check()

	###########Update hud_ui
	  # Đặt máu mặc định lúc bắt đầu
	if hud_ui:
		hud_ui.update_health(current_health, max_health)
  # Kết nối Signals
	health_changed.connect(hud_ui.update_health)
	if weapons_manager and hud_ui:
		weapons_manager.weapon_changed.connect(hud_ui.update_weapon)
		weapons_manager.ammo_updated.connect(hud_ui.update_ammo)


	
func build_default_keybinding() -> void:
	#build it in runtime to ensure that export variables have been set
	default_input_actions = {
		move_forward_action : [Key.KEY_W, Key.KEY_UP],
		move_backward_action : [Key.KEY_S, Key.KEY_DOWN],
		move_left_action : [Key.KEY_A, Key.KEY_LEFT],
		move_right_action : [Key.KEY_D, Key.KEY_RIGHT],
		run_action : [Key.KEY_SHIFT],
		crouch_action : [Key.KEY_CTRL],
		jump_action : [Key.KEY_SPACE],
		slide_action : [Key.KEY_C],
		dash_action : [Key.KEY_Q],
		fly_action : [Key.KEY_F],
		reload_action : [Key.KEY_R],
		inspect_action : [Key.KEY_Y],
		throw_weapon : [Key.KEY_G],
		skill_levitation : [Key.KEY_T]
		#interact : [Key.KEY_V]
		# được quy định ở camera script rồi
		# để dễ dàng quản lý
		# vì interactor quản lý việc tương tác not player
	}

func input_actions_check() -> void:
	#check if the input actions written in the editor are the same as the ones registered in the Input map, and if they are written correctly
	#if not, add it to runtime Input map with default keybindings
	if check_on_ready_if_inputs_registered:
		var registered_input_actions: Array[StringName] = []
		for input_action in InputMap.get_actions():
			if input_action.begins_with(&"play_char_"):
				registered_input_actions.append(input_action)

		for input_action in input_actions_list:
			if input_action == &"":
				assert(false, "There's an undefined input action")
				
			if not registered_input_actions.has(input_action):
				var key_names = default_input_actions[input_action].map(func(key):
					return OS.get_keycode_string(key)
				)
				
				push_warning("'{input}' missing in InputMap, or input action wrongly named in the editor.\nAdding the '{input}' to runtime InputMap temporarily with the key/s: {keys}"
				.format({"input": input_action, "keys": String(", ").join(key_names)}))
				
				InputMap.add_action(input_action)
				for keycode in default_input_actions[input_action]:
					var input_event_key = InputEventKey.new()
					input_event_key.physical_keycode = keycode
					InputMap.action_add_event(input_action, input_event_key)
					



				
func _process(delta: float) -> void:
	wallrun_timer(delta)
	
	slide_timer(delta)

	dash_timer(delta)
	
	handle_focus_logic(delta)
	
	###############thêm vào để nhận inspect weapon
	if Input.is_action_just_pressed("inspect_weapon"):
		weapons_manager.inspect_current_weapon()
	####### thêm vào để dùng skill lực nâng
	if Input.is_action_just_pressed("skill_levitation") and is_on_floor():
		state_machine.on_state_child_transition(state_machine.curr_state, "LevitationState")
	
	


	
func _physics_process(_delta: float) -> void:
	modify_physics_properties()

	move_and_slide()
	
func wallrun_timer(delta : float) -> void:
	if !can_wallrun:
		if time_bef_can_wallrun_again > 0.0: time_bef_can_wallrun_again -= delta
		else:
			#can only reset capacity of wallrunning when not currently wallrunning
			if state_machine.curr_state_name != "Wallrun":
				wallrun_time = wallrun_time_ref
				can_wallrun = true
	
func slide_timer(delta: float) -> void:
	if time_bef_can_slide_again > 0.0: time_bef_can_slide_again -= delta
	else:
		#can only reset slide time when not sliding
		if state_machine.curr_state_name != "Slide":
			slide_time = slide_time_ref
			
func dash_timer(delta: float) -> void:
	#reloads dash every *timeBefReloadDash* time, to avoid dash spamming
	#if you want to be able to spam dashes, set timeBefReloadDash to 0.0
	if nb_dashs_allowed < nb_dashs_allowed_ref:
		if time_bef_reload_dash > 0.0: time_bef_reload_dash -= delta
		else:
			time_bef_reload_dash = time_bef_reload_dash_ref
			nb_dashs_allowed += 1

	if time_bef_can_dash_again > 0.0: time_bef_can_dash_again -= delta
	else:
		#can only reset slide time when not dashing
		if state_machine.curr_state_name != "Dash":
			dash_time = dash_time_ref
			
func modify_physics_properties() -> void:
	last_frame_position = global_position #get play char global position every frame
	last_frame_velocity = velocity #get play char velocity every frame
	was_on_floor = !is_on_floor() #check if play char was on floor every frame
	
func gravity_apply(delta: float) -> void:
	# if play char goes up, apply jump gravity
	#otherwise, apply fall gravity
	if not is_on_floor(): #no need to push play char if he's already on the floor
		if velocity.y >= 0.0: velocity.y += jump_gravity * delta
		elif velocity.y < 0.0: velocity.y += fall_gravity * delta
	
#use of 2 tweens to change the hitbox and model heights, relative to a specific state
func tween_hitbox_height(state_hitbox_height : float) -> void:
	var hitbox_tween: Tween = create_tween()
	if hitbox != null:
		hitbox_tween.tween_method(func(v): set_hitbox_height(v), hitbox.shape.height, 
		state_hitbox_height, height_change_duration)
	#to avoid "no tweeners" error
	else:
		hitbox_tween.tween_interval(0.1)
	hitbox_tween.finished.connect(Callable(hitbox_tween, "kill"))

func set_hitbox_height(value: float) -> void:
	if hitbox.shape is CapsuleShape3D:
		hitbox.shape.height = value
		
func tween_model_height(state_model_height : float) -> void:
	var model_tween: Tween = create_tween()
	if model != null:
		model_tween.tween_property(model, "scale:y", 
		state_model_height, height_change_duration)
	#to avoid "no tweeners" error
	else:
		model_tween.tween_interval(0.1)
	model_tween.finished.connect(Callable(model_tween, "kill"))
		
		
func take_damage(amount: int, _shooter = null) -> void:
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	health_changed.emit(current_health, max_health)
	print("Player nhận %d damage! HP: %d" % [amount, current_health])
	# Gọi hiệu ứng ửng đỏ trên HUD_UI
	if hud_ui:
		hud_ui.flash_damage_overlay()
		print("đã đỏ màn hình")

## skill làm chậm không gian - focus - bullet time
func handle_focus_logic(delta: float):
	if Input.is_action_pressed("skill_focus") and current_focus > 0:
		is_focusing = true
		Engine.time_scale = lerp(Engine.time_scale, focus_time_scale, 0.1)
		current_focus -= focus_drain_speed * (1.0 / Engine.time_scale) * delta
		
		# HIỆU ỨNG: Hiện Overlay (tăng Alpha hoặc Shader intensity)
		#focus_overlay.modulate.a = lerp(focus_overlay.modulate.a, 0.3, 0.1) 
		# Nếu dùng Shader, hãy dùng dòng này thay thế:
		focus_overlay.material.set_shader_parameter("intensity", 0.8)
		
	else:
		is_focusing = false
		Engine.time_scale = lerp(Engine.time_scale, 1.0, 0.1)
		if current_focus < max_focus:
			current_focus += focus_regen_speed * delta
			
		# HIỆU ỨNG: Ẩn Overlay
		focus_overlay.modulate.a = lerp(focus_overlay.modulate.a, 0.0, 0.1)
		# focus_overlay.material.set_shader_parameter("intensity", 0.0)

	# Cập nhật UI
	if hud_ui:
		hud_ui.update_focus_bar(current_focus, max_focus)

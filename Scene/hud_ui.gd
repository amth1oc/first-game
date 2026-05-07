extends CanvasLayer

@onready var health_bar: ProgressBar = $MarginContainer/HealthContainer/HealthBar
@onready var weapon_name: Label = $MarginContainer/WeaponUI/WeaponName
@onready var ammo_count: Label = $MarginContainer/WeaponUI/AmmoCount
@onready var interact_prompt: Label = $MarginContainer/InteractPrompt
@onready var damage_overlay = $DamageOverlay
@onready var focus_bar = $FocusBar
@onready var focus_overlay = $FocusOverlay

func _ready():
	interact_prompt.hide() # Ẩn đi lúc mới vào game

# 1. Hiệu ứng thanh máu trượt mượt mà (Smooth Health)
func update_health(current: int, max_hp: int):
	health_bar.max_value = max_hp
	var tween = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(health_bar, "value", float(current), 0.3)

# 2. Đổi súng và hiệu ứng "Pop"
func update_weapon(weapon_data: WeaponData):
	if weapon_data:
		weapon_name.text = weapon_data.weapon_name
		pop_animation(weapon_name)
	else:
		weapon_name.text = ""
		###############xóa khi drop súng
# 3. Cập nhật đạn và hiệu ứng "Pop"
func update_ammo(current_mag: int, total_ammo: int):
	ammo_count.text = str(current_mag) + " / " + str(total_ammo)
	# Đổi màu đỏ nếu hết đạn
	if current_mag == 0:
		ammo_count.add_theme_color_override("font_color", Color.RED)
	else:
		ammo_count.remove_theme_color_override("font_color")
	
	pop_animation(ammo_count)

# Hàm xài chung tạo hiệu ứng phình to rồi thu nhỏ (Juicy UI)
func pop_animation(ui_element: Control):
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# Phóng to lên 1.1
	tween.tween_property(ui_element, "scale", Vector2(1.1, 1.1), 0.05)
	# Thu về 1.0
	tween.tween_property(ui_element, "scale", Vector2.ONE, 0.15)
	# Lưu ý: Nhớ set Pivot Offset của Label nằm ở giữa để nó phình ra đều đặn.

# 4. Hiển thị thông báo nhặt đồ (Interaction)
func show_interact(text: String):
	interact_prompt.text = text
	interact_prompt.show()

func hide_interact():
	interact_prompt.hide()

func flash_damage_overlay():
	# Tạo một Tween mới
	var tween = create_tween()
	# 1. Cho màn hình hiện màu đỏ (Alpha lên khoảng 0.4 - 0.5) cực nhanh
	#tween.tween_property(damage_overlay, "color:a", 0.5, 0.05)
	damage_overlay.color = Color(1.0, 0.2, 0.2, 0.45)
	# 2. Sau đó mờ dần về 0 (trong suốt) trong khoảng 0.4 giây
	tween.tween_property(damage_overlay, "color:a", 0.0, 0.4)
	
func update_focus_bar(current: float, max_val: float):
	
	focus_bar.max_value = max_val
	focus_bar.value = current

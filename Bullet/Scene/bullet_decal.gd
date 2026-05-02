extends Decal

@export var lifespan: float = 10.0 # Tồn tại trong 10 giây

func _ready() -> void:
	# Tự động xóa node sau 10 giây
	var timer = get_tree().create_timer(lifespan)
	timer.timeout.connect(queue_free)
	
	# Tùy chọn: Làm vết đạn mờ dần trước khi biến mất bằng Tween
	var tween = create_tween()
	tween.tween_interval(lifespan - 2.0) # Chờ 8 giây
	tween.tween_property(self, "albedo_mix", 0.0, 2.0) # Mờ dần trong 2 giây cuối

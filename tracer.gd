extends MeshInstance3D

@export var speed: float = 150.0 # Tốc độ bay của đạn
var target_position: Vector3

func setup(target_pos: Vector3) -> void:
	target_position = target_pos
	
	# Hướng tracer nhìn thẳng về phía mục tiêu
	look_at(target_position, Vector3.UP)
	
	# Xóa tracer sau 2 giây để tránh rác bộ nhớ nếu nó bay ra ngoài bản đồ
	get_tree().create_timer(2.0).timeout.connect(queue_free)

func _process(delta: float) -> void:
	if target_position != Vector3.ZERO:
		# Tính hướng bay
		var direction = (target_position - global_position).normalized()
		global_position += direction * speed * delta
		
		# Nếu đã bay đến sát mục tiêu thì xóa tracer
		if global_position.distance_to(target_position) < 2.0:
			queue_free()

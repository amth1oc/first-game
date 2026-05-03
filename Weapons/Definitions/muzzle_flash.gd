extends Node3D

@onready var particles: GPUParticles3D = $GPUParticles3D
# @onready var light: OmniLight3D = $OmniLight3D # Nếu bạn có dùng đèn

func _ready() -> void:
	particles.emitting = true
	# Để muzzle flash biến mất sau khi phát xong (khoảng 0.5s đến 1s)
	get_tree().create_timer(1.0).timeout.connect(queue_free)
	
	# Nếu có đèn, tắt đèn thật nhanh (vd 0.05s)
	# get_tree().create_timer(0.05).timeout.connect(func(): light.visible = false)

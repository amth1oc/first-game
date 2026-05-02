extends Node3D
class_name Interactable

# Tín hiệu phát ra khi được tương tác
signal interacted(interactor: Node3D)

@export var interact_name: String = "Vật phẩm" # Tên vật thể (ví dụ: Revolver)
@export var interact_text: String = "Nhặt"     # Hành động (ví dụ: Nhặt, Mở, Bật)

# Hàm này sẽ được gọi bởi người chơi
func interact(interactor: Node3D):
	interacted.emit(interactor)

extends Node3D
class_name Interactor

@export var interact_ray: RayCast3D
@export var interact_action: StringName = "interact"

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(interact_action):
		check_interaction()

func check_interaction():
	if interact_ray.is_colliding():
		var collider = interact_ray.get_collider()
		
		# Tìm node Interactable trong collider (có thể là chính nó hoặc con của nó)
		var interactable = find_interactable(collider)
		if interactable:
			interactable.interact(owner) # Kích hoạt tương tác

func find_interactable(node: Node) -> Interactable:
	if node is Interactable:
		return node
	# Nếu collider không phải Interactable, tìm trong các node con của nó
	for child in node.get_children():
		if child is Interactable:
			return child
	return null
	
func _physics_process(_delta: float) -> void:
	if interact_ray.is_colliding():
		var interactable = find_interactable(interact_ray.get_collider())
		if interactable and owner and owner.hud_ui:
			# Hiện UI: "Press V to Nhặt Revolver"
			owner.hud_ui.show_interact("Bấm E để " + interactable.interact_text + " " + interactable.interact_name)
			return
			
	# Nếu tia Raycast không trúng gì, hoặc vật đó không phải Interactable thì ẩn UI
	if owner and owner.hud_ui:
		owner.hud_ui.hide_interact()

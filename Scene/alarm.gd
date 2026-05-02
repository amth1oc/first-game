# Alarm.gd
extends StaticBody3D

@export var interactable: Interactable
var is_active = false

func _ready() -> void:
	# Set the initial prompt
	#interactable.interaction_prompt = "Turn On Alarm"
	pass

func _on_interactable_interacted(interactor: Node3D) -> void:
	is_active = !is_active
	if is_active:
		print("ALARM IS NOW ON!")
		#interactable.interaction_prompt = "Turn Off Alarm"
	else:
		print("Alarm is now off.")
		#interactable.interaction_prompt = "Turn On Alarm"

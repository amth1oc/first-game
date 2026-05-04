# KnifePickup.gd
class_name KnifePickup
extends RigidBody3D

@export var weapon_data: WeaponData

# This function allows a thrown weapon to pass its current data (like ammo count)
# to the pickup object that gets spawned.
func set_weapon_data(data: WeaponData) -> void:
	weapon_data = data

func _on_interactable_interacted(interactor):
	# interactor chính là PlayerCharacter
	if interactor.weapons_manager.pickup_weapon(weapon_data):
		queue_free() # Nhặt xong thì biến mất

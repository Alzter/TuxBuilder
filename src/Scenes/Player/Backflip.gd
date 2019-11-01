extends Node

onready var host = get_owner()

func _step(delta):
	host.set_animation("backflip")
	host.get_node("Hitbox").shape.extents.y = 31
	host.get_node("Hitbox").position.y = 1
	host.get_node("ShootLocation").position.y = 1
	
	# Backflip speed and rotation
	host.get_node("Control/AnimatedSprite").rotation_degrees = 0
	if host.get_node("Control/AnimatedSprite").scale.x == 1:
		host.velocity.x = host.BACKFLIP_SPEED
		host.backflip_rotation -= 15
	else:
		host.velocity.x = -host.BACKFLIP_SPEED
		host.backflip_rotation += 15
	host.get_node("Control/AnimatedSprite").rotation_degrees = host.backflip_rotation
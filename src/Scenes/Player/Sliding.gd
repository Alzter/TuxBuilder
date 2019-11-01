extends Node

onready var host = get_owner()

func _step(delta):
	host.set_animation("slide")
	host.get_node("Hitbox").shape.extents.y = 15
	host.get_node("Hitbox").position.y = 17
	host.get_node("ShootLocation").position.y = 17
	
	host.can_jump(false, false)
	
	# Gravity
	if host.on_ground > 0:
		host.velocity.y += host.GRAVITY
		if host.velocity.y > host.FALL_SPEED: host.velocity.y = host.FALL_SPEED
	else: host.velocity.y = 0
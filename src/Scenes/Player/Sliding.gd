extends Node

onready var host = get_owner()

func _step(delta):
	host.set_animation("slide")
	
	host.can_jump(false, false)
	
	# Gravity
	if host.on_ground > 0:
		host.velocity.y += host.GRAVITY
		if host.velocity.y > host.FALL_SPEED: host.velocity.y = host.FALL_SPEED
	else: host.velocity.y = 0
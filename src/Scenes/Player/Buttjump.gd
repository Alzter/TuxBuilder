extends Node

onready var host = get_owner()

func _step(delta):
	host.set_animation("buttjump")
	
	# Gravity
	if host.on_ground > 0 and host.get_node("ButtjumpTimer").time_left == 0:
		host.velocity.y += host.BUTTJUMP_GRAVITY
		if host.velocity.y > host.BUTTJUMP_FALL_SPEED: host.velocity.y = host.BUTTJUMP_FALL_SPEED
	else: host.velocity = Vector2(0,0)
extends Node

onready var host = get_owner()

var climb_up = true
var frame = 0

func _step(delta):
	frame = host.get_node("Control/AnimatedSprite").frame
	
	if Input.is_action_pressed("up"):
		host.velocity.y = -300
		host.set_animation("climb_up")
		if climb_up == false:
			host.get_node("Control/AnimatedSprite").frame = 8 - frame
		climb_up = true
		
	elif Input.is_action_pressed("duck"):
		host.velocity.y = 300
		host.set_animation("climb_down")
		if climb_up == true:
			host.get_node("Control/AnimatedSprite").frame = 8 - frame
		climb_up = false
		
	else:
		host.velocity.y = 0
		host.get_node("Control/AnimatedSprite").stop()
	
	if host.is_on_floor():
		host.player_state = "Movement"
	
	# Climbable boundaries
	if host.position.y < host.climbtop + 16:
		host.position.y = host.climbtop + 16
		host.get_node("Control/AnimatedSprite").stop()
	
	if host.position.y > host.climbbottom - 48:
		host.position.y = host.climbbottom - 48
		host.get_node("Control/AnimatedSprite").stop()
	
	host.can_jump(false, true)
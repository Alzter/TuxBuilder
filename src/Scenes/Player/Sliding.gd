extends Node

onready var host = get_owner()

func _step(delta):
	host.set_animation("slide")
	host.skidding = false
	host.ducking = false
	
	# Jumping
	if Input.is_action_pressed("jump") and host.jumpheld <= host.JUMP_BUFFER_TIME:
		if host.on_ground <= host.LEDGE_JUMP and host.get_node("ButtjumpLandTimer").time_left <= host.BUTTJUMP_LAND_TIME - 0.02:
			# Running jump
			if abs(host.velocity.x) >= host.run_max:
				host.velocity.y = -host.RUNJUMP_POWER
			
			# Normal jump
			else:
				host.velocity.y = -host.JUMP_POWER
			if host.state == "small":
				host.get_node("SFX/Jump").play()
			else: host.get_node("SFX/BigJump").play()
			host.get_node("AnimationPlayer").playback_speed = 1
			host.get_node("AnimationPlayer").play("Stop")
			host.set_animation("jump")
			host.jumpheld = host.JUMP_BUFFER_TIME + 1
			host.on_ground = host.LEDGE_JUMP + 1
			host.jumpcancel = true
			if host.get_node("StandWindow").is_colliding() and host.state != "small": host.ducking = true
			host.player_state = "Movement"
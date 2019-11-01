extends Node

onready var host = get_owner()

func _step(delta):
	# Horizontal movement
	if (!host.ducking or host.on_ground != 0) and !host.skidding:
		if Input.is_action_pressed("move_right"):
			host.get_node("Control/AnimatedSprite").scale.x = 1
			
			# Moving
			if host.velocity.x >= 0:
				if host.velocity.x < host.WALK_ADD:
					host.velocity.x = host.WALK_ADD
				if abs(host.velocity.x) > host.WALK_MAX:
						host.velocity.x += host.RUN_ACCEL * delta
				else: host.velocity.x += host.WALK_ACCEL * delta
			
			# Skidding
			elif host.on_ground == 0 and abs(host.velocity.x) >= host.WALK_MAX:
				if !host.skidding:
					host.skidding = true
					host.get_node("SFX/Skid").play()
			
			# Air turning
			elif host.wind > 0:
				host.velocity.x += host.TURN_ACCEL * delta * 5
			else: host.velocity.x += host.TURN_ACCEL * delta
		
		if Input.is_action_pressed("move_left"):
			host.get_node("Control/AnimatedSprite").scale.x = -1
			if host.velocity.x <= 0:
				
				# Moving
				host.get_node("Control/AnimatedSprite").scale.x = -1
				if host.velocity.x > -host.WALK_ADD:
					host.velocity.x = -host.WALK_ADD
				if abs(host.velocity.x) > host.WALK_MAX:
						host.velocity.x -= host.RUN_ACCEL * delta
				else: host.velocity.x -= host.WALK_ACCEL * delta
			
			# Skidding
			elif host.on_ground == 0 and abs(host.velocity.x) >= host.WALK_MAX:
				if !host.skidding:
					host.skidding = true
					host.get_node("SFX/Skid").play()
			
			# Air turning
			elif host.wind > 0:
				host.velocity.x -= host.TURN_ACCEL * delta * 5
			else: host.velocity.x -= host.TURN_ACCEL * delta

	# Speedcap
	if host.velocity.x >= host.run_max:
		host.velocity.x = host.run_max
	if host.velocity.x <= -host.run_max:
		host.velocity.x = -host.run_max

	# Friction
	if (host.skidding or (host.ducking and host.on_ground == 0) or (not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"))):
		
		# Turn when skidding
		if host.skidding:
			if host.velocity.x > 0:
				host.get_node("Control/AnimatedSprite").scale.x = -1
			if host.velocity.x < 0:
				host.get_node("Control/AnimatedSprite").scale.x = 1
		
		# Friction
		host.velocity.x *= host.FRICTION
		if host.on_ground == 0: host.velocity.x *= host.SLIDE_FRICTION
		if abs(host.velocity.x) < 80 and host.wind == 0:
			host.velocity.x = 0

	# Stop skidding if low velocity
	if abs(host.velocity.x) < 75 and host.skidding:
		host.skidding = false
		host.velocity.x = 0

		# Ducking / Sliding
	if host.on_ground == 0:
		# Stop Ducking in certain situations
		if not Input.is_action_pressed("duck") or host.state == "small": host.ducking = false
		
		# Duck if in one block space
		if host.get_node("StandWindow").is_colliding() and host.state != "small": host.ducking = true
		
		# Ducking / Sliding
		elif Input.is_action_pressed("duck"):
			if abs(host.velocity.x) < host.WALK_MAX:
				if host.state != "small": host.ducking = true
			else: host.start_sliding()
	elif host.get_node("StandWindow").is_colliding() and host.state != "small": host.ducking = true
	else: host.ducking = false
	
	# Jumping
	if Input.is_action_pressed("jump") and host.jumpheld <= host.JUMP_BUFFER_TIME:
		if host.on_ground <= host.LEDGE_JUMP and host.get_node("ButtjumpLandTimer").time_left <= host.BUTTJUMP_LAND_TIME - 0.02:
			
			# Backflip
			if host.state != "small" and Input.is_action_pressed("duck") and host.get_node("StandWindow").is_colliding() == false and !host.sliding and host.get_node("ButtjumpLandTimer").time_left == 0:
				host.player_state = "Backflip"
				host.backflip_rotation = 0
				host.velocity.y = -host.RUNJUMP_POWER
				host.get_node("SFX/Flip").play()
			
			# Running jump
			elif abs(host.velocity.x) >= host.run_max:
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
			host.skidding = false
			host.ducking = false
			if host.get_node("StandWindow").is_colliding() and host.state != "small": host.ducking = true

	# Jump cancelling
	if host.on_ground != 0 and not Input.is_action_pressed("jump") and host.jumpcancel:
		if host.velocity.y < 0:
			host.get_node("AnimationPlayer").playback_speed += 0.3
			host.velocity.y *= 0.5
		else:
			host.jumpcancel = false

	# Animations
	host.get_node("Control/AnimatedSprite").speed_scale = 1
	if host.ducking:
		host.set_animation("duck")
	else:
		if host.on_ground <= host.LEDGE_JUMP:
			if host.skidding:
				host.set_animation("skid")
			elif abs(host.velocity.x) >= host.WALK_ADD / 2:
				host.get_node("Control/AnimatedSprite").speed_scale = abs(host.velocity.x) * 0.0035
				if host.get_node("Control/AnimatedSprite").speed_scale < 0.4:
					host.get_node("Control/AnimatedSprite").speed_scale = 0.4
				host.set_animation("walk")
			else: host.set_animation("idle")
		elif host.velocity.y > 0:
			if host.get_node("Control/AnimatedSprite").animation == ("jump") or host.get_node("Control/AnimatedSprite").animation == ("fall_transition") or  host.get_node("Control/AnimatedSprite").animation == ("jump_small") or host.get_node("Control/AnimatedSprite").animation == ("fall_transition_small"):
				host.set_animation("fall_transition")
			else: host.set_animation("fall")
		else: host.set_animation("jump")
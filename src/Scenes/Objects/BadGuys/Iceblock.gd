extends "BadGuy.gd"

const INVINCIBLE_TIME = 10
const KICK_SPEED = 500

func on_ready():
	collision_mask = 2
	
func _squish(delta):
	velocity.y += 20
	velocity = move_and_slide(velocity, FLOOR)

# Physics
func on_physics_process(delta):
	if state == "grabbed":
		collision_mask = 0
		collision_layer = 0
	elif state == "kicked":
		collision_mask = 0
		collision_layer = 8
	else: 
		collision_mask = 2
		collision_layer = 2
	
	if state == "kicked":
		velocity.x = KICK_SPEED * -$Control/AnimatedSprite.scale.x
		velocity.y += 20
		velocity = move_and_slide(velocity, FLOOR)
		if is_on_wall():
			for body in $BlockBreaker.get_overlapping_bodies():
				if body.is_in_group("bonusblock") or body.is_in_group("brick"):
					body.hit($Control/AnimatedSprite.scale.x, false)
			$Control/AnimatedSprite.scale.x *= -1
			velocity.x *= -1
			$SFX/Bump.play()
			

# Fireball death animation
func on_fireball_kill():
	$SFX/Melt.play()
	$AnimationPlayer.play("explode")

# Buttjump death animation
func on_buttjump_kill():
	$SFX/Shatter.play()
	$AnimationPlayer.play("explode")

# Hit player / Squished
func _on_Area2D_body_entered(body):
	if body.is_in_group("badguys") and state == "kicked" and body.name != name:
		body.kill()
		return
	elif not body.is_in_group("player"): return
	if body.position.y + 20 < position.y and squishable == true:
		if (state == "active" or state == "kicked"):
			
			# Squished
			if body.player_state == "Sliding":
				kill()
				return
			if body.player_state == "Buttjump":
				body.velocity.y *= 0.9
				buttjump_kill()
			state = "squished"
			$AnimationPlayer.play(SQUISHED_ANIMATION)
			$SFX/Squish.play()
			body.bounce(300, body.JUMP_POWER, true)
			velocity = Vector2(0,0)
		
		# Kicked
		elif state == "squished":
			if body.player_state == "Sliding":
				kill()
				return
			if body.player_state == "Buttjump" == true:
				body.velocity.y *= 0.9
				buttjump_kill()
			state = "kicked"
			$AnimationPlayer.play(SQUISHED_ANIMATION)
			$SFX/Kick.play()
			body.bounce(300, body.JUMP_POWER, true)
			velocity = Vector2(0,0)
			if body.position.x > position.x:
				velocity.x = -KICK_SPEED
				$Control/AnimatedSprite.scale.x = 1
				
			else:
				velocity.x = KICK_SPEED
				$Control/AnimatedSprite.scale.x = -1
	else:
		# Hit player
		if body.invincible == true:
			kill()
		if (state == "active" or state == "kicked") and body.has_method("hurt"):
			body.hurt()
		
		# Kick / Grab Iceblock
		elif state == "squished":
			$AnimationPlayer.stop()
			$AnimationPlayer.play("stop")
			if Input.is_action_pressed("action") and body.holding_object == false:
				body.holding_object = true
				body.object_held = name
				state = "grabbed"
			elif invincible_time == 0:
				invincible_time = INVINCIBLE_TIME
				$Control/AnimatedSprite.play("squished")
				$SFX/Kick.play()
				
				if body.position.x > position.x:
					velocity.x = -KICK_SPEED
					$Control/AnimatedSprite.scale.x = 1
					
				else:
					velocity.x = KICK_SPEED
					$Control/AnimatedSprite.scale.x = -1
				state = "kicked"
		return

# When thrown by player
func throw():
	state = "kicked"
	$Control/AnimatedSprite.play("squished")
	$SFX/Kick.play()

func _on_WakeupTimer_timeout():
	$WakeupTimer.stop()
	if state == "squished":
		$AnimationPlayer.stop()
		$AnimationPlayer.play("shake")
		$ShakeTimer.start(1)

func _on_ShakeTimer_timeout():
	$ShakeTimer.stop()
	$WakeupTimer.stop()
	if state == "squished":
		$AnimationPlayer.play("wakeup")
		state = "active"
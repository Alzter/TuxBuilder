extends "BadGuy.gd"

var invincible_time = 0

const INVINCIBLE_TIME = 10
const KICK_SPEED = 500

func on_ready():
	collision_mask = 2
	
func _squish(delta):
	velocity.y += 20
	velocity = move_and_slide(velocity, FLOOR)

# Physics
func on_physics_process(delta):

	if invincible_time > 0: 
		invincible_time -= 1
	
	if state != "kicked": 
		collision_layer = 2
	else: 
		collision_layer = 8
	
	if state == "kicked":
		velocity.x = KICK_SPEED * -$Control/AnimatedSprite.scale.x
		velocity.y += 20
		velocity = move_and_slide(velocity, FLOOR)
		collision_mask = 0
		if is_on_wall():
			$Control/AnimatedSprite.scale.x *= -1
			velocity.x *= -1
			$SFX/Bump.play()

# Custom fireball death animation (optional)
func on_fireball_kill():
	$SFX/Melt.play()
	$AnimationPlayer.play("explode")

# If squished
func _on_Head_area_entered(area):
	if area.is_in_group("bottom"):
		var player = area.get_parent()
		if player.sliding == true:
			kill()
			return
		
		if invincible_time == 0:
			invincible_time = INVINCIBLE_TIME
			
			if state == "active" or state == "kicked":
				state = "squished"
				velocity = Vector2(0,0)
				$AnimationPlayer.play("squished")
				$SFX/Squish.play()
				player.call("bounce")
				$ShakeTimer.stop()
				$WakeupTimer.start(5)
				
			elif state == "squished":
				$AnimationPlayer.play("squished")
				$Control/AnimatedSprite.play("squished")
				$SFX/Kick.play()
				
				if player.position.x > position.x:
					velocity.x = -KICK_SPEED
					$Control/AnimatedSprite.scale.x = 1
					
				else:
					velocity.x = KICK_SPEED
					$Control/AnimatedSprite.scale.x = -1
				state = "kicked"
				player.call("bounce")

# Hit player
func _on_snowball_body_entered(body):
	if body.is_in_group("badguys") and body.name != name and state == "kicked":
		body.kill()
	if body.is_in_group("player"):
		if body.invincible == true: kill()
		if (state == "active" or state == "kicked") and body.has_method("hurt"):
			body.hurt()
			
		# Kick / Grab Iceblock
		elif state == "squished":
			$AnimationPlayer.stop()
			$AnimationPlayer.play("stop")
			if Input.is_action_pressed("action"):
				body.holding_object = true
				body.object_held = name
				state = ""
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

extends KinematicBody2D

const FLOOR = Vector2(0, -1)

var velocity = Vector2(0,0)
var startpos = Vector2(0,0)
var state = "active"
var direction = 1
var rotate = 0
var invincible_time = 0

const KICK_SPEED = 500

func _ready():
	startpos = position
	direction = $Control/AnimatedSprite.scale.x
	collision_mask = 2

func disable():
	remove_from_group("badguys")
	$CollisionShape2D.call_deferred("set_disabled", true)
	$Head/CollisionShape2D.call_deferred("set_disabled", true)
	$Area2D/CollisionShape2D.call_deferred("set_disabled", true)

# Physics
func _physics_process(delta):
	
	if invincible_time > 0: invincible_time -= 1
	
	if get_tree().current_scene.editmode == true:
		return
	
	
	if state != "kicked": collision_layer = 2
	else: collision_layer = 8
	
	# Movement
	if state == "active":
		velocity.x = -100 * $Control/AnimatedSprite.scale.x
		velocity.y += 20
		velocity = move_and_slide(velocity, FLOOR)
		if is_on_wall():
			$Control/AnimatedSprite.scale.x *= -1
			velocity.x *= -1
	
	if state == "kicked":
		velocity.x = KICK_SPEED * -$Control/AnimatedSprite.scale.x
		velocity.y += 20
		velocity = move_and_slide(velocity, FLOOR)
		collision_mask = 0
		if is_on_wall():
			$Control/AnimatedSprite.scale.x *= -1
			velocity.x *= -1
			$SFX/Bump.play()
	
	# Kill states
	if state == "kill":
		position += velocity * delta
		velocity.y += 20
		$Control/AnimatedSprite.rotation_degrees += rotate

# Custom fireball death animation (optional)
func fireball_kill():
	disable()
	state = ""
	$SFX/Melt.play()
	$AnimationPlayer.play("explode")
	
# If hit by bullet or invincible player
func kill():
	disable()
	state = "kill"
	if velocity.x == 0: velocity.x = 1
	velocity = Vector2(300 * (velocity.x / abs(velocity.x)), -350)
	rotate = 30 * (velocity.x / abs(velocity.x))
	$SFX/Fall.play()

# If squished
func _on_Head_area_entered(area):
	if area.is_in_group("bottom"):
		var player = area.get_parent()
		if player.sliding == true:
			kill()
			return
		
		if invincible_time == 0:
			invincible_time = 5
			
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
			if Input.is_action_pressed("action"):
				body.holding_object = true
				body.object_held = name
				state = ""
			elif invincible_time == 0:
				invincible_time = 5
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

# Die when knocked off stage
func _on_VisibilityEnabler2D_screen_exited():
	if state == "kill" or state == "": queue_free()

func appear(dir):
	$Control/AnimatedSprite.scale.x = -dir

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

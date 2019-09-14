extends KinematicBody2D

const FLOOR = Vector2(0, -1)

var velocity = Vector2(0,0)
var startpos = Vector2(0,0)
var state = "active"
var direction = 1
var rotate = 0
var squishable = true
var invincible_time = 0
var areastored = null

const WALK_SPEED = 80
var SQUISHED_ANIMATION = "squished"

# These methods are here to be overridden in the badguy sub-classes
func on_ready():
	pass

func on_kill(delta):
	pass
	
func on_move(delta):
	pass
	
func on_squish(delta):
	pass
	
func on_fireball_kill():
	pass
	
func on_buttjump_kill():
	pass
	
func on_physics_process(delta):
	pass

func _ready():
	startpos = position
	direction = $Control/AnimatedSprite.scale.x
	on_ready()

func disable():
	remove_from_group("badguys")
	$CollisionShape2D.call_deferred("set_disabled", true)
	$Area2D/CollisionShape2D.call_deferred("set_disabled", true)

func _physics_process(delta):
	if get_tree().current_scene.editmode == true:
		return

	if invincible_time > 0: 
		invincible_time -= 1
	else: invincible_time = 0

	# Movement
	if state == "active":
		_move(delta)
		
	# Kill states
	if state == "kill":
		_kill(delta)
	
	if state == "squished":
		_squish(delta)
		
	on_physics_process(delta);

# If hit by bullet or invincible player
func kill():
	if invincible_time > 0: return
	disable()
	$AnimationPlayer.stop()
	state = "kill"

	if velocity.x == 0: 
		velocity.x = 1

	velocity = Vector2(300 * (velocity.x / abs(velocity.x)), -350)
	rotate = 30 * (velocity.x / abs(velocity.x))
	$SFX/Fall.play()

func _move(delta):
	velocity.x = -WALK_SPEED * $Control/AnimatedSprite.scale.x
	velocity.y += 20
	velocity = move_and_slide(velocity, FLOOR)
	if is_on_wall():
		$Control/AnimatedSprite.scale.x *= -1
	on_move(delta)

func _squish(delta):
	velocity.x = 0
	velocity.y += 20
	velocity = move_and_slide(velocity, FLOOR)
	collision_layer = 4
	collision_mask = 0
	$CollisionShape2D.disabled = false
	on_squish(delta)

func _kill(delta):
	position += velocity * delta
	velocity.y += 20
	$Control/AnimatedSprite.rotation_degrees += rotate
	on_kill(delta)

# Buttjump detection
func _on_snowball_area_entered(area):
	if area.get_parent().is_in_group("player"):
		if area.get_parent().buttjump == true:
			area.get_parent().velocity.y *= 0.9
			buttjump_kill()

# Hit player / Squished
func _on_snowball_body_entered(body):
	if not body.is_in_group("player"): return
	if body.position.y + 20 < position.y and squishable == true or body.buttjump == true:
		if state == "active" and invincible_time == 0:
			
			# Squished
			if body.sliding == true:
				kill()
				return
			if body.buttjump == true:
				body.velocity.y *= 0.9
				buttjump_kill()
			disable()
			state = "squished"
			$AnimationPlayer.play(SQUISHED_ANIMATION)
			$SFX/Squish.play()
			body.bounce(300, body.JUMP_POWER, true)
			velocity = Vector2(0,0)
	else:
		# Hit player
		if body.invincible == true:
			kill()
		if state == "active" and body.has_method("hurt"):
			body.hurt()
		return


# Die when knocked off stage
func _on_VisibilityEnabler2D_screen_exited():
	if state == "kill" or state == "":
		queue_free()

func appear(dir, hitdown):
	invincible_time = 5
	$Control/AnimatedSprite.scale.x = -dir
	if abs($Control/AnimatedSprite.scale.x) != 1: $Control/AnimatedSprite.scale.x = -1

# Fireball death animation
func fireball_kill():
	disable()
	state = ""
	on_fireball_kill()

# Buttjump death animation
func buttjump_kill():
	disable()
	state = ""
	on_buttjump_kill()
	return
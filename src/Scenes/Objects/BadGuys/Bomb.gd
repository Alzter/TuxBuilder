extends "BadGuy.gd"
var hurt_player = true
var exploding = false

func on_ready():
	SQUISHED_ANIMATION = "triggered"

# Fireball death animation
func fireball_kill():
	explode()

# Buttjump death animation
func on_buttjump_kill():
	hurt_player = false
	explode()

func explode():
	exploding = true
	var bodies = $Area2D.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("player"):
			if body.holding_object == true:
				if body.object_held == name:
					body.holding_object = false
	disable()
	state = ""
	$AnimationPlayer.play("explode")

func _squish(delta):
	velocity.x = 0
	velocity.y += 20
	velocity = move_and_slide(velocity, FLOOR)
	$CollisionShape2D.disabled = false
	on_squish(delta)

func _on_ExplosionRadius_body_entered(body):
	if body.get_name() != name and exploding == true:
		if body.is_in_group("player"):
			if hurt_player == true: body.hurt()
			else: body.velocity.y = -1000
		if body.is_in_group("bonusblock") or body.is_in_group("brick"):
			if body.position.x < position.x:
				body.hit(-1,body.position.y > position.y)
			else: body.hit(1,body.position.y > position.y)

func _on_ExplosionRadius_area_entered(area):
	if area.get_parent().get_name() != name and exploding == true:
		if area.get_parent().is_in_group("badguys"):
			area.get_parent().kill()

# Hit player / Squished
func _on_Area2D_body_entered(body):
	if not body.is_in_group("player"): return
	if body.position.y + 20 < position.y and squishable == true:
		if state == "active" and invincible_time == 0:
			
			# Squished
			if body.player_state == "Sliding":
				kill()
				return
			if body.player_state == "Buttjump":
				body.velocity.y *= 0.9
				buttjump_kill()
			disable()
			state = "squished"
			$AnimationPlayer.play(SQUISHED_ANIMATION)
			$SFX/Squish.play()
			body.bounce(300, body.JUMP_POWER, true)
			velocity = Vector2(0,0)
		elif state == "triggered":
			if Input.is_action_pressed("action") and body.holding_object == false:
				body.holding_object = true
				body.object_held = name
	else:
		# Hit player
		if body.invincible == true:
			kill()
		if state == "active" and body.has_method("hurt"):
			body.hurt()
		return
extends KinematicBody2D

const FLOOR = Vector2(0, -1)

var velocity = Vector2(0,0)
var state = "active"

# Physics
func _physics_process(delta):
	if state == "active":
		velocity.x = -100 * $AnimatedSprite.scale.x
		velocity.y += 20
		velocity = move_and_slide(velocity, FLOOR)
		if is_on_wall():
			$AnimatedSprite.scale.x *= -1
	
	# Enemy killed animations
	elif state == "burned":
		pass
		
	elif state == "squished":
		$AnimationPlayer.play("squished")
		
	elif state == "bullet":
		$CollisionShape2D.disabled = true
		velocity = move_and_slide(velocity, FLOOR)
		velocity.y += 20
		$AnimatedSprite.rotation_degrees += 30 * (velocity.x / abs(velocity.x))
		if $VisibilityNotifier2D.is_on_screen() == false:
			queue_free()

# If hit by any type of bullet
func hit_by_bullet():
	state = "bullet"
	remove_from_group("badguys")
	$CollisionShape2D.disabled = true
	$Area2D/CollisionShape2D.disabled = true
	velocity = Vector2(300 * (velocity.x / abs(velocity.x)), -350)
	$Fall.play()

func _on_snowball_body_entered(body):
	if body.has_method("hurt") && !state == "squished":
		body.hurt()

func _on_Head_area_entered(area):
	if area.is_in_group("bottom") and state != "squished":
		state = "squished"
		var player = area.get_parent()
		if player.jumpheld > 0:
			player.velocity.y = -player.JUMP_POWER
		else: player.velocity.y = -300
		player.jumpcancel = false
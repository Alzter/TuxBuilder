extends KinematicBody2D

var velocity = Vector2(0,0)
var oldvelocity = velocity.x
var hit = false

func _physics_process(delta):
	if $VisibilityNotifier2D.is_on_screen() == false:
		queue_free()
	if hit == false:
		if velocity.x > 0:
			if $AnimationPlayer.current_animation != "ActiveRight":
				$AnimationPlayer.play("ActiveRight")
		elif $AnimationPlayer.current_animation != "ActiveLeft":
			$AnimationPlayer.play("ActiveLeft")
		velocity.y += 20
		var collision = move_and_collide(velocity * delta)
		var oldvelocity = velocity.x
		if collision:
			velocity = velocity.bounce(collision.normal)
			if velocity.x != oldvelocity:
					$Extinguish.play()
					$AnimationPlayer.play("Hit")
					$CollisionShape2D.disabled = true
					remove_from_group("Bullets")
					hit = true
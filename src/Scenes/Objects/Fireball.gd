extends KinematicBody2D

var velocity = Vector2(0,0)
var oldvelocity = velocity.x
var hit = false

func _on_fireball_body_entered(body):
	if body.is_in_group("badguys") and hit == false:
		remove_from_group("bullets")
		$CollisionShape2D.disabled = true
		$Area2D/EnemyCollision.disabled = true
		$AnimationPlayer.play("Hit")
		hit = true
		if body.has_method("hit_by_fireball"):
			body.velocity.x = velocity.x
			body.call("hit_by_fireball")
		elif body.has_method("hit_by_bullet"):
			body.velocity.x = velocity.x
			body.call("hit_by_bullet")

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
				remove_from_group("bullets")
				$CollisionShape2D.disabled = true
				$Area2D/EnemyCollision.disabled = true
				$Extinguish.play()
				$AnimationPlayer.play("Hit")
				hit = true
extends KinematicBody2D

var velocity = Vector2(0,0)
var oldvelocity = velocity.x

func _physics_process(delta):
	velocity.y += 20
	var collision = move_and_collide(velocity * delta)
	var oldvelocity = velocity.x
	if collision:
		velocity = velocity.bounce(collision.normal)
		if velocity.x != oldvelocity:
			$AnimationPlayer.play("Hit")
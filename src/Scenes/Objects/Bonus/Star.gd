extends KinematicBody2D

var collected = false
var direction = 1
var velocity = Vector2(200,0)

func _physics_process(_delta):
	if get_tree().current_scene.editmode == false and collected == false:
		velocity.x = 200 * direction
		velocity.y += 20
		move_and_slide(velocity,Vector2(0,-1))
		if is_on_wall():
			direction *= -1
	if is_on_floor():
		velocity.y = -500
		$AnimationPlayer.stop()
		$AnimationPlayer.play("bounce")
	
	if is_on_ceiling():
		$AnimationPlayer.stop()
		$AnimationPlayer.play("default")
		velocity.y = 0

func _on_Area2D_body_entered(body):
	if body.is_in_group("player") and collected == false:
		collected = true
		body.star_invincibility()
		$AnimationPlayer.play("pickup")

func appear(dir):
	direction = dir
	velocity = Vector2(200 * dir, 500)
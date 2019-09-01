extends KinematicBody2D

var collected = false
var direction = 1
var velocity = Vector2()

func _physics_process(delta):
	if get_tree().current_scene.editmode == false and collected == false:
		velocity.x = 100 * direction
		if not is_on_floor():
			velocity.y += 20
		if is_on_ceiling():
			velocity.y = 0
		move_and_slide(velocity,Vector2(0,-1))
		if is_on_wall():
			direction *= -1

func _on_Area2D_body_entered(body):
	if body.is_in_group("player") and collected == false:
		collected = true
		if body.state == "small": body.state = "big"
		$AnimationPlayer.play("collect")

func appear(dir):
	direction = dir
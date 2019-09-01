extends RigidBody2D

var collected = false

func _physics_process(delta):
	if get_tree().current_scene.editmode == true:
		gravity_scale = 0
	else:
		gravity_scale = 1

func _on_Area2D_body_entered(body):
	if body.is_in_group("player") and collected == false:
		collected = true
		body.state = "fire"
		$AnimationPlayer.play("collect")
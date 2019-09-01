extends RigidBody2D

func _physics_process(delta):
	if get_tree().current_scene.editmode == true:
		gravity_scale = 0
	else:
		gravity_scale = 3

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		body.star_invincibility()
		$AnimationPlayer.play("pickup")

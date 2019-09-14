extends KinematicBody2D

const BOUNCE_LOW = 530
const BOUNCE_HIGH = 1000

func _on_Area2D_body_entered(body):
	if get_tree().current_scene.editmode == true: return
	if body.is_in_group("player"):
		$Trampoline.play()
		if body.get_node("ButtjumpLandTimer").time_left > 0:
			body.bounce(BOUNCE_HIGH, BOUNCE_HIGH, false)
		else: body.bounce(BOUNCE_LOW, BOUNCE_HIGH, false)
	if body.is_in_group("badguys"):
		$Trampoline.play()
		body.velocity.y = -BOUNCE_LOW
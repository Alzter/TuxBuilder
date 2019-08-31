extends Area2D

var collected = false

func _on_FireFlower_body_entered(body):
	if body.is_in_group("player") and collected == false:
		collected = true
		body.state = "fire"
		$AnimationPlayer.play("collect")
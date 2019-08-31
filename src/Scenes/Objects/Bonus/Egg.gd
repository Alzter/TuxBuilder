extends Area2D

var collected = false

func _on_Egg_body_entered(body):
	if body.is_in_group("player") and collected == false:
		collected = true
		body.state = "big"
		$AnimationPlayer.play("collect")

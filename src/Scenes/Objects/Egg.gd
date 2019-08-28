extends Area2D

func _on_Egg_body_entered(body):
	if body.is_in_group("player"):
		body.state = "big"
		$PickupSFX.play()
		queue_free()

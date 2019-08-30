extends Area2D

func _on_FireFlower_body_entered(body):
	if body.is_in_group("player"):
		body.state = "fire"
		$PickupSFX.play()
		queue_free()
		
extends Area2D

func _on_Coin_body_entered(body):
	if body.is_in_group("player"):
		$AnimationPlayer.play("Pickup")
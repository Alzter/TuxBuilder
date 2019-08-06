extends Area2D

func _on_Coin_body_entered(body):
	if body.is_in_group("player"):
		$AnimationPlayer.play("Pickup")
		var counter = get_tree().get_nodes_in_group("CoinCounter")[0]
		counter.coins = counter.coins + 1
		counter._update_coin_count()
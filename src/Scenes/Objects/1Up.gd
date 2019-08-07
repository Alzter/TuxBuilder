extends Area2D

var touched = 0

func _on_1Up_body_entered(body):
	if body.is_in_group("player") and touched == 0:
		var counter = get_tree().get_nodes_in_group("CoinCounter")[0]
		counter.coins = counter.coins + 100
		counter._update_coin_count()
		$AnimationPlayer.play("Pickup")
		touched = 1
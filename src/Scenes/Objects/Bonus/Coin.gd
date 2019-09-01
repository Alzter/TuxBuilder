extends Area2D

var touched = 0

func _on_Coin_body_entered(body):
	if body.is_in_group("player") and touched == 0:
		$AnimationPlayer.play("Pickup")
		var counter = get_tree().get_nodes_in_group("CoinCounter")[0]
		counter.coins = counter.coins + 1
		touched = 1

func appear(dir):
	$AnimationPlayer.play("Pickup")
	var counter = get_tree().get_nodes_in_group("CoinCounter")[0]
	counter.coins = counter.coins + 1
	touched = 1
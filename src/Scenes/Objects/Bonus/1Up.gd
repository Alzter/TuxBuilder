extends Area2D

var collected = false

func _on_1Up_body_entered(body):
	if body.is_in_group("player") and collected == false:
		collected = true
		var counter = get_tree().get_nodes_in_group("CoinCounter")[0]
		counter.coins = counter.coins + 100
		$AnimationPlayer.play("collect")
extends Area2D

var touched = false

func collect():
	$AnimationPlayer.play("Pickup")
	var counter = get_tree().get_nodes_in_group("CoinCounter")[0]
	counter.coins += 1
	touched = true

func _on_Coin_body_entered(body):
	if body.is_in_group("player") and not touched:
		collect()

func appear(dir, hitdown):
	collect()
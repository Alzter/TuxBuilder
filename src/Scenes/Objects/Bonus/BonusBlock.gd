extends "BlockContainer.gd"

func on_empty_hit():
	$AnimatedSprite.play("empty")

	if hitdownstored == true:
		$AnimationPlayer.play("hitdown")
	else: $AnimationPlayer.play("hit")

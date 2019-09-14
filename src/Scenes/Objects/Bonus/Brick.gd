extends "BlockContainer.gd"

func on_empty_hit():
	if hitdownstored == true:
		$AnimationPlayer.play("breakdown")
	else: $AnimationPlayer.play("break")
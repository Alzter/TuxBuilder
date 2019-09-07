extends "BadGuy.gd"

# Custom fireball death animation (optional)
func on_fireball_kill():
	$SFX/Melt.play()
	$AnimationPlayer.play("explode")
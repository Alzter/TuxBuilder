extends "BadGuy.gd"

# Fireball death animation
func on_fireball_kill():
	$SFX/Melt.play()
	$AnimationPlayer.play("explode")

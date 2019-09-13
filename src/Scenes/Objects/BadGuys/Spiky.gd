extends "BadGuy.gd"

func on_ready():
	squishable = false

# Fireball death animation
func on_fireball_kill():
	$SFX/Melt.play()
	$AnimationPlayer.play("explode")
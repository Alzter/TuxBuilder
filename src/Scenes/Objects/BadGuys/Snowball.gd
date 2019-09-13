extends "BadGuy.gd"

func on_ready():
	SQUISHED_ANIMATION = "squished"

# Fireball death animation
func on_fireball_kill():
	$SFX/Melt.play()
	$AnimationPlayer.play("explode")

# Buttjump death animation
func on_buttjump_kill():
	$SFX/Fall.play()
	$AnimationPlayer.play("explode")
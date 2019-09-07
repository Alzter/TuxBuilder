extends "BadGuy.gd"

func on_ready():
	SQUISHED_ANIMATION = "squished"

# Custom fireball death animation (optional)
func on_fireball_kill():
	$SFX/Melt.play()
	$AnimationPlayer.play("explode")
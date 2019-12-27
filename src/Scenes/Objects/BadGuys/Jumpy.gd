extends "BadGuy.gd"

const BOUNCE_HEIGHT = 600

func _move(delta):
	velocity.y += 20
	if is_on_floor():
		velocity.y = -BOUNCE_HEIGHT
		$Control/AnimatedSprite.play("bounce")
	velocity = move_and_slide(velocity, FLOOR)

# Fireball death animation
func on_fireball_kill():
	$SFX/Melt.play()
	$AnimationPlayer.play("explode")

# Buttjump death animation
func on_buttjump_kill():
	$SFX/Fall.play()
	$AnimationPlayer.play("explode")

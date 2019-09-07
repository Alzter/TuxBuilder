extends "BadGuy.gd"

func on_squish(delta):
	pass

# Custom fireball death animation (optional)
func fireball_kill():
	explode()

func explode():
	disable()
	state = ""
	$AnimationPlayer.play("explode")

func _on_ExplosionRadius_area_entered(area):
	if area.get_parent().get_name() != name:
		if area.get_parent().is_in_group("badguys"):
			area.get_parent().kill()
		if area.get_parent().is_in_group("player"):
			area.get_parent().hurt()
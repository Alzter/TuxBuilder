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
	var parent = area.get_parent()
	if parent.get_name() != name:
		if parent.is_in_group("badguys"):
			parent.kill()
		if parent.is_in_group("player"):
			parent.hurt()
extends "BadGuy.gd"
var hurt_player = true

func on_ready():
	SQUISHED_ANIMATION = "triggered"

func on_squish(delta):
	pass

# Fireball death animation
func fireball_kill():
	explode()

# Buttjump death animation
func on_buttjump_kill():
	hurt_player = false
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
			if hurt_player == true: parent.hurt()
			else: parent.velocity.y = -1000
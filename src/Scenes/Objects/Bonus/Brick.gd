extends "BlockContainer.gd"

func on_empty_hit():
	if player.state == "small":
		$AnimationPlayer.stop()
		if hitdownstored == true:
			$AnimationPlayer.play("hitdown_small")
		else: $AnimationPlayer.play("hit_small")
		hit = false
	else:
		$AnimationPlayer.stop()
		if hitdownstored == true:
			$AnimationPlayer.play("breakdown")
		else: $AnimationPlayer.play("break")

# Break on buttjump
func _on_Area2D_area_entered(area):
	if area.get_parent().is_in_group("player"):
		if area.get_parent().buttjump == true and stored == "":
			# Prevent brick from breaking if Tux is outside its hitbox
			if area.get_parent().position.x > position.x - 31.5 and area.get_parent().position.x < position.x + 31.5:
				area.get_parent().velocity.y *= 0.9
				
				# We need a special break animation for buttjumps
				# so the brick doesn't look like it breaks
				# before the player reaches it.
				$AnimationPlayer.play("buttjumpbreak")
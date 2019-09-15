extends "BadGuy.gd"
var hurt_player = true
var exploding = false

func on_ready():
	SQUISHED_ANIMATION = "triggered"

# Fireball death animation
func fireball_kill():
	explode()

# Buttjump death animation
func on_buttjump_kill():
	hurt_player = false
	explode()

func explode():
	exploding = true
	disable()
	state = ""
	$AnimationPlayer.play("explode")

func _squish(delta):
	velocity.x = 0
	velocity.y += 20
	velocity = move_and_slide(velocity, FLOOR)
	$CollisionShape2D.disabled = false
	on_squish(delta)

func _on_ExplosionRadius_body_entered(body):
	if body.get_name() != name and exploding == true:
		if body.is_in_group("player"):
			if hurt_player == true: body.hurt()
			else: body.velocity.y = -1000
		if body.is_in_group("bonusblock") or body.is_in_group("brick"):
			if body.position.x < position.x:
				body.hit(-1,body.position.y > position.y)
			else: body.hit(1,body.position.y > position.y)

func _on_ExplosionRadius_area_entered(area):
	if area.get_parent().get_name() != name and exploding == true:
		if area.get_parent().is_in_group("badguys"):
			area.get_parent().kill()

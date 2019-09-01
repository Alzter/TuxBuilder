extends KinematicBody2D

const FLOOR = Vector2(0, -1)

var velocity = Vector2(0,0)
var startpos = Vector2(0,0)
var state = "active"
var direction = 1
var rotate = 0

func _ready():
	startpos = position
	direction = $AnimatedSprite.scale.x

func disable():
	remove_from_group("badguys")
	$CollisionShape2D.call_deferred("set_disabled", true)
	$Head/CollisionShape2D.call_deferred("set_disabled", true)
	$Area2D/CollisionShape2D.call_deferred("set_disabled", true)

# Physics
func _physics_process(delta):
	
	if get_tree().current_scene.editmode == true:
		return
	
	# Movement
	if state != "kill" and state != "":
		if state == "active": velocity.x = -100 * $AnimatedSprite.scale.x
		velocity.y += 20
		velocity = move_and_slide(velocity, FLOOR)
		if is_on_wall() and state == "active":
			$AnimatedSprite.scale.x *= -1
	
	# Kill states
	if state == "kill":
		position += velocity * delta
		velocity.y += 20
		$AnimatedSprite.rotation_degrees += rotate

# Custom fireball death animation (optional)
func fireball_kill():
	disable()
	state = ""
	$SFX/Melt.play()
	$AnimationPlayer.play("explode")
	
# If hit by bullet or invincible player
func kill():
	disable()
	state = "kill"
	if velocity.x == 0: velocity.x = 1
	velocity = Vector2(300 * (velocity.x / abs(velocity.x)), -350)
	rotate = 30 * (velocity.x / abs(velocity.x))
	$SFX/Fall.play()

# If squished
func _on_Head_area_entered(area):
	if area.is_in_group("bottom") and state == "active":
		var player = area.get_parent()
		if player.sliding == true:
			kill()
			return
		state = "squished"
		velocity = Vector2(0,0)
		$AnimationPlayer.play("squished")
		$SFX/Squish.play()
		player.call("bounce")

# Hit player
func _on_snowball_body_entered(body):
	if body.is_in_group("player"):
		if body.invincible == true: kill()
	if state == "active" and body.has_method("hurt"):
		body.hurt()
	return

# Die when knocked off stage
func _on_VisibilityEnabler2D_screen_exited():
	if state == "kill" or state == "": queue_free()

extends KinematicBody2D

const FLOOR = Vector2(0, -1)

var velocity = Vector2(0,0)
var startpos = Vector2(0,0)
var state = "active"
var direction = 1
var rotate = 0

func _ready():
	startpos = position
	direction = $Control/AnimatedSprite.scale.x

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
	if state == "active":
		velocity.x = -100 * $Control/AnimatedSprite.scale.x
		velocity.y += 20
		velocity = move_and_slide(velocity, FLOOR)
		if is_on_wall():
			$Control/AnimatedSprite.scale.x *= -1
	
	# Kill states
	if state == "kill":
		position += velocity * delta
		velocity.y += 20
		$Control/AnimatedSprite.rotation_degrees += rotate
	
	if state == "squished":
		velocity.x = 0
		velocity.y += 20
		velocity = move_and_slide(velocity, FLOOR)
		collision_layer = 4
		collision_mask = 0
		$CollisionShape2D.disabled = false

# Custom fireball death animation (optional)
func fireball_kill():
	explode()

# If hit by bullet or invincible player
func kill():
	explode()

# If hit by sliding player
func normal_kill():
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
			normal_kill()
			return
		disable()
		state = "squished"
		$AnimationPlayer.play("triggered")
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

func explode():
	disable()
	state = ""
	$AnimationPlayer.play("explode")

func appear(dir):
	$Control/AnimatedSprite.scale.x = -dir
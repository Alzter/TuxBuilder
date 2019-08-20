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
	state = ""
	remove_from_group("badguys")
	$CollisionShape2D.disabled = true
	$Head/CollisionShape2D.disabled = true
	$Area2D/CollisionShape2D.disabled = true

# Physics
func _physics_process(delta):
	if get_tree().current_scene.editmode == true:
		return
	
	# Movement
	if state == "active":
		velocity.x = -100 * $AnimatedSprite.scale.x
		velocity.y += 20
		velocity = move_and_slide(velocity, FLOOR)
		if is_on_wall():
			$AnimatedSprite.scale.x *= -1
	
	# Kill states
	if state == "kill":
		disable()
		velocity = move_and_slide(velocity, Vector2(0,0))
		velocity.y += 20
		$AnimatedSprite.rotation_degrees += rotate
		if $VisibilityNotifier2D.is_on_screen() == false:
			queue_free()

# Custom death animation (optional, overrides normal kill)
func custom_kill():
	disable()
	$SFX/Fall.play()
	$AnimationPlayer.play("explode")
	
# If hit by bullet or invincible player
func kill():
	disable()
	$SFX/Fall.play()
	velocity = Vector2(300 * (velocity.x / abs(velocity.x)), -350)
	rotate = 30 * (velocity.x / abs(velocity.x))
	state = "kill"

# If squished
func _on_Head_area_entered(area):
	if area.is_in_group("bottom") and state == "active":
		disable()
		$AnimationPlayer.play("squished")
		$SFX/Squish.play()
		var player = area.get_parent()
		if player.jumpheld > 0:
			player.velocity.y = -player.JUMP_POWER
			player.jumpcancel = true
		else:
			player.velocity.y = -300
			player.jumpcancel = false

# Despawn when falling out of world
	if position.y > get_tree().current_scene.get_node("Camera2D").limit_bottom:
		queue_free()

# Hit player
func _on_snowball_body_entered(body):
	if state == "active" and body.has_method("hurt") and body.invincible_time == 0:
		body.hurt()
	return
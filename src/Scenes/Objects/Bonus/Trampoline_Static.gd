extends KinematicBody2D

const BOUNCE_LOW = 530
const BOUNCE_HIGH = 1000
const FLOOR = Vector2(0, -1)

var velocity = Vector2()
var on_ground = true

func _physics_process(delta):
	if get_tree().current_scene.editmode == true: return
	velocity.y += 20 * 2
	velocity = move_and_slide(velocity, FLOOR)
	
	if is_on_floor():
		if on_ground == false:
			$Thud.play()
			$AnimatedSprite.frame = 0
			$AnimatedSprite.play("land")
		on_ground = true
		velocity.x *= 0.9
	else: on_ground = false

func _on_Area2D_body_entered(body):
	if get_tree().current_scene.editmode == true: return
	if body.is_in_group("player"):
		if body.position.y - 20 < position.y:
			$AnimatedSprite.frame = 0
			$AnimatedSprite.play("bounce")
			if body.velocity.y >= 0:
				$Trampoline.play()
				if body.get_node("ButtjumpLandTimer").time_left > 0:
					body.bounce(BOUNCE_HIGH, BOUNCE_HIGH, false)
				else: body.bounce(BOUNCE_LOW, BOUNCE_HIGH, false)
		else:
			$AnimatedSprite.play("default")
			$Thud.play()
			velocity.y = -600
			if body.position.x < position.x:
				velocity.x = -175
			else: velocity.x = 175
	if body.is_in_group("badguys"):
		if body.position.y - 20 < position.y:
			$Trampoline.play()
			$AnimatedSprite.frame = 0
			$AnimatedSprite.play("bounce")
			body.velocity.y = -BOUNCE_LOW
		else:
			body.buttjump_kill()
			$AnimatedSprite.play("default")
	if body.is_in_group("trampoline") and body.name != name:
		if body.position.y - 20 < position.y:
			$Trampoline.play()
			$AnimatedSprite.frame = 0
			$AnimatedSprite.play("bounce")
			body.velocity.y = -BOUNCE_LOW
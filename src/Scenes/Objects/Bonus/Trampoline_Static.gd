extends KinematicBody2D

const BOUNCE_LOW = 530
const BOUNCE_HIGH = 1000
const FLOOR = Vector2(0, -1)

var velocity = Vector2()
var wallcling = ""
var on_ground = true

func _physics_process(delta):
	if velocity == Vector2(0,0): align()
	if get_tree().current_scene.editmode == true: return
	
	if wallcling == "":
		velocity.y += 20 * 2
		velocity = move_and_slide(velocity, FLOOR)
	
	if is_on_floor():
		if on_ground == false:
			$Thud.play()
			$Control/AnimatedSprite.frame = 0
			$Control/AnimatedSprite.play("land")
		on_ground = true
		velocity.x *= 0.9
	else: on_ground = false

func _on_Area2D_body_entered(body):
	if get_tree().current_scene.editmode == true: return
	if body.is_in_group("player"):
		if (body.position.y - 20 < position.y and wallcling == "") or wallcling != "":
			$Control/AnimatedSprite.frame = 0
			$Control/AnimatedSprite.play("bounce")
			if body.velocity.y >= 0 or wallcling != "":
				$Trampoline.play()
				if wallcling == "":
					if body.get_node("ButtjumpLandTimer").time_left > 0:
						body.bounce(BOUNCE_HIGH, BOUNCE_HIGH, false)
					else: body.bounce(BOUNCE_LOW, BOUNCE_HIGH, false)
				elif wallcling == "top":
					body.velocity.y = BOUNCE_LOW
				else:
					body.backflip = false
					if wallcling == "left":
						body.velocity.x = BOUNCE_LOW
						body.get_node("Control/AnimatedSprite").scale.x = 1
					elif wallcling == "right":
						body.velocity.x = -BOUNCE_LOW
						body.get_node("Control/AnimatedSprite").scale.x = -1
		else:
			$Control/AnimatedSprite.play("default")
			$Thud.play()
			velocity.y = -600
			if body.position.x < position.x:
				velocity.x = -175
			else: velocity.x = 175
	if body.is_in_group("badguys"):
		if (body.position.y - 20 < position.y and wallcling == "") or wallcling != "":
			$Trampoline.play()
			$Control/AnimatedSprite.frame = 0
			$Control/AnimatedSprite.play("bounce")
			if wallcling == "":
				body.velocity.y = -BOUNCE_LOW
			elif wallcling == "top": body.velocity.y = BOUNCE_LOW
			elif wallcling == "left": body.velocity.x = BOUNCE_LOW
			elif wallcling == "right": body.velocity.x = -BOUNCE_LOW
		else:
			body.buttjump_kill()
			$Control/AnimatedSprite.play("default")
	if body.is_in_group("trampoline") and body.name != name:
		if (body.position.y - 20 < position.y and wallcling == ""):
			$Trampoline.play()
			$Control/AnimatedSprite.frame = 0
			$Control/AnimatedSprite.play("bounce")
			body.velocity.y = -BOUNCE_LOW

func align():
	$Control.rect_rotation = 0
	$CollisionShape2D.position = Vector2(0, 2)
	$CollisionShape2D.shape.extents = Vector2(15.5,14)
	$Area2D/CollisionShape2D.position = Vector2(0, -2)
	$CollisionShape2D.rotation_degrees = 0
	$Area2D/CollisionShape2D.rotation_degrees = 0
	wallcling = ""
	
	if $CeilingDetector.is_colliding():
		wallcling = "top"
		$Control.rect_pivot_offset.y = 0
		$Control.rect_rotation = 180
		$CollisionShape2D.position.y = -16
		$Area2D/CollisionShape2D.position.y = -8
		$CollisionShape2D.rotation_degrees = 0
		$Area2D/CollisionShape2D.rotation_degrees = 0
	
	elif $LeftWallDetector.is_colliding() and not $RightWallDetector.is_colliding():
		wallcling = "left"
		$Control.rect_pivot_offset.y = -1
		$Control.rect_rotation = 90
		$CollisionShape2D.position.y = 0
		$CollisionShape2D.position.x = -16
		$Area2D/CollisionShape2D.position.y = 0
		$CollisionShape2D.rotation_degrees = $Control.rect_rotation
		$Area2D/CollisionShape2D.rotation_degrees = $Control.rect_rotation
	
	elif $RightWallDetector.is_colliding() and not $LeftWallDetector.is_colliding():
		wallcling = "right"
		$Control.rect_pivot_offset.y = -1
		$Control.rect_rotation = -90
		$CollisionShape2D.position.y = 0
		$CollisionShape2D.position.x = 16
		$Area2D/CollisionShape2D.position.y = 0
		$CollisionShape2D.rotation_degrees = $Control.rect_rotation
		$Area2D/CollisionShape2D.rotation_degrees = $Control.rect_rotation
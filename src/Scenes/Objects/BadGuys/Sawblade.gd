extends Node2D

var clockwise = false
var direction = 90
var start = false
var moving = true

const MOVE_SPEED = 4

func _physics_process(delta):
	if get_tree().current_scene.editmode == true: return
	
	if start == false:
		start = true
		if $Left.is_colliding():
			if clockwise == true:
				direction = 0
			else: direction = 180
			position.x -= 16 - $Area2D/CollisionShape2D.shape.extents.x
		
		elif $Right.is_colliding():
			if clockwise == true:
				direction = 0
			else: direction = 180
			position.x += 16 - $Area2D/CollisionShape2D.shape.extents.x
		
		elif $Top.is_colliding():
			if clockwise == true:
				direction = 90
			else: direction = 270
			position.y -= 16 - $Area2D/CollisionShape2D.shape.extents.x
		
		elif $Bottom.is_colliding():
			if clockwise == true:
				direction = 270
			else: direction = 90
			position.y += 16 - $Area2D/CollisionShape2D.shape.extents.x
		
		else: moving = false
	
	if moving == false: return
	
	if $Area2D.get_overlapping_bodies().size() == 0:
		move(-MOVE_SPEED)
		if clockwise == true:
			direction += 90
		else: direction -= 90
	
	if $Wall.is_colliding():
		if clockwise == true:
			direction -= 90
		else: direction += 90
	
	$Wall.rotation_degrees = direction - 90
	$Sparks.emitting = true
	$Sparks.rotation_degrees = (direction - 90) + 110
	if clockwise == true: $Sparks.rotation_degrees = (direction - 90) - 110
	else: $Sparks.rotation_degrees = (direction - 90) + 110
	
	if $Left.is_colliding():
		$Sparks.position = Vector2(-12,0)
		
	elif $Right.is_colliding():
		$Sparks.position = Vector2(12,0)
		
	elif $Top.is_colliding():
		$Sparks.position = Vector2(0,-12)
		
	elif $Bottom.is_colliding():
		$Sparks.position = Vector2(0,12)
	
	move(MOVE_SPEED)
	
	if clockwise == true:
		$AnimatedSprite.scale.x = 1
	else: $AnimatedSprite.scale.x = -1

func move(speed):
	if direction < 0: direction = abs(direction) + 180
	direction %= 360
	if direction == 90:
		position.x += speed
	if direction == 270:
		position.x -= speed
	if direction == 0:
		position.y -= speed
	if direction == 180:
		position.y += speed

func _on_HitDetection_body_entered(body):
	if body.is_in_group("player"):
		body.hurt()

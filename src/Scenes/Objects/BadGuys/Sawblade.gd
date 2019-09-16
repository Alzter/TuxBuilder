extends Node2D

var clockwise = false
var direction = 90

const MOVE_SPEED = 4

func _physics_process(delta):
	if get_tree().current_scene.editmode == true: return
	
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
	
	move(MOVE_SPEED)

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		body.hurt()

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
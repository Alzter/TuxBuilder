extends "BadGuy.gd"

onready var iciclestate = ""
onready var trigger_ray = get_node('trigger_ray')

func _process(delta):
	if iciclestate == "" and trigger_ray.is_colliding():
		if trigger_ray.get_collider().is_in_group('player'):
			$Timer.start(0.5)
			iciclestate = "shaking"
			$SFX/Cracking.play()
			$AnimationPlayer.play("shake")

func _move(delta):
	if iciclestate == "active":
		if is_on_floor():
			iciclestate = "broken"
			$SFX/Icecrash.play()
			$AnimationPlayer.play("broken")
			
			collision_layer = 4
			collision_mask = 0
			return
		
		velocity.y += 20
		velocity = move_and_slide(velocity, FLOOR)

func _on_Timer_timeout():
	if iciclestate == "shaking":
		$AnimationPlayer.play("default")
		iciclestate = "active"

func _on_Area2D_body_entered(body):
	if iciclestate != "broken":
		if body.is_in_group('player'):
			body.hurt()
		
		elif body.is_in_group('badguys'):
			body.kill()
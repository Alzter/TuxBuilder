extends "BadGuy.gd"

var triggered = false
var recovering = false
var cooling_down = false

onready var trigger_ray = get_node('trigger_ray')
	
func _process(delta):
	
	if triggered or recovering or cooling_down:
		return

	if trigger_ray.is_colliding():
		if trigger_ray.get_collider().is_in_group('player'):
			triggered = true
		
	
func _move(delta):
	
	var player = UIHelpers.get_player()
	if player != null and not recovering:
		var target = player.position
		$Control/lefteye.look_at(target)
		$Control/righteye.look_at(target)
	
	if not triggered and not recovering:
		return
	
	if is_on_floor() and not recovering:
		triggered = false
		$SFX/thud.play()
		$AnimationPlayer.play("spinning_eyes")
		$recover_timer.start()
		return
	
	if triggered:
		velocity.y += 20
		velocity.y = move_and_slide(velocity, FLOOR).y

	elif recovering:
		position.y -= 4

	if recovering and position.y < startpos.y:
		recovering = false
		cooling_down = true
		velocity.y = 0
		velocity.y = move_and_slide(velocity, FLOOR).y
		$AnimationPlayer.stop()
		$recover_timer.start()

func _on_Area2D_body_entered(body):

	if body.is_in_group('player') and not body.dead:
		body.hurt()
		triggered = false
		recovering = true

	if body.is_in_group('badguys'):
		body.kill()
		triggered = false
		recovering = true

func _on_recover_timer_timeout():
	$recover_timer.stop()
	
	if cooling_down:
		cooling_down = false
		return
	
	recovering = true

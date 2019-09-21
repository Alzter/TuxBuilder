extends "BadGuy.gd"

var triggered = false
var shaking = false
var is_broken = false

onready var trigger_ray = get_node('trigger_ray')
	
func _process(delta):
	if triggered or shaking:
		return

	if trigger_ray.is_colliding():
		if trigger_ray.get_collider().is_in_group('player'):
			shaking = true
			$SFX/cracking.play()
			$AnimationPlayer.play("shake")
		
	
func _move(delta):
	if not triggered:
		return
	
	if is_on_floor() and not is_broken:
		is_broken = true
		$SFX/icecrash.play()
		$AnimationPlayer.play("broken")
		
		collision_layer = 4
		collision_mask = 0
		$CollisionShape2D.disabled = false
		return
	
	velocity.y += 20
	velocity = move_and_slide(velocity, FLOOR)

func _on_Area2D_body_entered(body):
	if is_broken:
		return

	if body.is_in_group('player'):
		body.hurt()
	
	if body.is_in_group('badguys'):
		body.kill()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "shake":
		triggered = true

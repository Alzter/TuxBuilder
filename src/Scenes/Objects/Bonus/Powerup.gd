extends KinematicBody2D

export var physics = false
export var gravity_when_static = false
export var gravity_when_appeared = false
export var move_speed = 0
export var bounce_height = 0
export var initial_speed = Vector2(0,0)
export var coins = 0
export var powerup_state = ""
export var ignore_small = false
export var collect_on_appear = false
export var appear_animation = ""
export var pickup_animation = ""
export var bounce_animation = ""
var collected = false
var direction = 1
var velocity = Vector2()
var appeared = false
var player = null
var gravity = false

func _physics_process(delta):
	gravity = false
	if appeared == true and gravity_when_appeared == true:
		gravity = true
	if appeared == false and gravity_when_static == true:
		gravity = true
	
	if get_tree().current_scene.editmode == false and collected == false:
		if physics:
			if move_speed != 0: velocity.x = move_speed * direction
			if not is_on_floor():
				velocity.y += 20
			if is_on_ceiling():
				velocity.y = 0
			move_and_slide(velocity,Vector2(0,-1))
			if is_on_wall():
				direction *= -1
			if is_on_floor():
				if bounce_height != 0: velocity.y = bounce_height
				if bounce_animation != "":
					$AnimationPlayer.stop()
					$AnimationPlayer.play(bounce_animation)
		else:
			if move_speed != 0: velocity.x = move_speed * direction
			if gravity: velocity.y += 20
			position += velocity * delta
		collect_check()

func collect_check():
	if collected == true: return
	for body in $Area2D.get_overlapping_bodies():
		if body.is_in_group("player"):
			player = body
			collected = true
	if collected == true:
		if player.state == "small" or ignore_small == false:
			if powerup_state == "star":
				player.star_invincibility()
			else: player.state = powerup_state
		if pickup_animation != "":
			$AnimationPlayer.stop()
			$AnimationPlayer.play(pickup_animation)
		if coins > 0:
			var counter = get_tree().get_nodes_in_group("CoinCounter")[0]
			counter.coins += coins

func appear(dir, hitdown):
	appeared = true
	direction = dir
	velocity = initial_speed
	velocity.x *= dir
	if collect_on_appear: collect_check()
	if appear_animation != "":
		$AnimationPlayer.stop()
		$AnimationPlayer.play(appear_animation)
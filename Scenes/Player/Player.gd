extends KinematicBody2D

# What angle is considered floor
const FLOOR = Vector2(0, -1)
# Instant speed when starting walk
const WALK_ADD = 120.0
# Speed Tux accelerates per second when walking
const WALK_ACCEL = 350.0
# Speed Tux accelerates per second when running
const RUN_ACCEL = 400.0

# Speed you need to start running
const WALK_MAX = 230.0
# Maximum horizontal speed
const RUN_MAX = 320.0
# Backflip horizontal speed
const BACKFLIP_SPEED = -128

# Acceleration when holding the opposite direction
const TURN_ACCEL = 900.0
# Speed which Tux slows down
const SKID_ACCEL = 950.0
# Speed which Tux skids
const FRICTION = 0.93
# Speed Tux slows down skidding
const SKID_TIME = 12

# Jump velocity
const JUMP_POWER = 580
# Running Jump / Backflip velocity
const RUNJUMP_POWER = 640
# Gravity
const GRAVITY = 20.0
# Amount of frames Tux can still jump after falling off a ledge
const LEDGE_JUMP = 3

# Invincible time after being hit
const SAFE_TIME = 108
# Fireball speed
const FIREBALL_SPEED = 500

var velocity = Vector2()
var on_ground = 0 # Frames Tux has been in air (0 if grounded)
var jumpheld = 0 # Time the jump key has been held
var jumpcancel = false # Can let go of jump to stop vertical ascent
var running = 0 # If horizontal speed is higher than walk max
var skid = 0 # Time skidding
var ducking = false # Ducking
var backflip = false # Backflipping
var backflip_rotation = 0 # Backflip rotation
var state = "fire" # Tux's power-up state
var invincible_time = 0 # Amount of frames Tux is invincible
var camera_offset = 0 # Moves camera horizontally for extended view
var dead = false # Stop doing stuff if true

func hurt():
	if state == "small":
		kill()
	elif state == "big":
		state = "small"
		$SFX/Hurt.play()
		invincible_time = SAFE_TIME
	else:
		state = "big"
		$SFX/Hurt.play()
		invincible_time = SAFE_TIME

func kill():
	state = "small"
	$SFX/Kill.play()
	$BigHitbox.disabled = true
	$SmallHitbox.disabled = true
	$SquishRadius/CollisionShape2D.disabled = true
	dead = true
	velocity = Vector2 (0,-JUMP_POWER)

#=============================================================================
# PHYSICS

func _physics_process(delta):

	if dead == true:
		velocity.y += GRAVITY
		$BigHitbox.disabled = true
		$SmallHitbox.disabled = true
		$SquishRadius/CollisionShape2D.disabled = true
		velocity = move_and_slide(velocity, Vector2(0,0))
		return

	# Horizontal movement
	if Input.is_action_pressed("move_right") and (ducking == false or on_ground != 0) and backflip == false:
		$AnimatedSprite.scale.x = 1
		if skid <= 0 and velocity.x >= 0:
			if velocity.x == 0:
				velocity.x += WALK_ADD
			if running == 1:
					velocity.x += RUN_ACCEL / 60
			else: velocity.x += WALK_ACCEL / 60

			# Skidding and air turning
		if velocity.x < 0:
			if on_ground == 0:
				velocity.x += SKID_ACCEL / 60
				if skid == 0 and velocity.x <= -WALK_MAX:
					skid = SKID_TIME
			else: velocity.x += TURN_ACCEL / 60

	else: if Input.is_action_pressed("move_left") and (ducking == false or on_ground != 0) and backflip == false:
		$AnimatedSprite.scale.x = -1
		if skid <= 0 and velocity.x <= 0:
			if velocity.x == 0:
				velocity.x -= WALK_ADD
			if running == 1:
					velocity.x -= RUN_ACCEL / 60
			else: velocity.x -= WALK_ACCEL / 60

		# Skidding and air turning
		if velocity.x > 0:
			if on_ground == 0:
				velocity.x -= SKID_ACCEL / 60
				if skid == 0 and velocity.x >= WALK_MAX:
					skid = SKID_TIME
			else: velocity.x -= TURN_ACCEL / 60

	else: if backflip == false: velocity.x *= FRICTION

	# Speedcap
	if velocity.x >= RUN_MAX:
		velocity.x = RUN_MAX
	if velocity.x <= -RUN_MAX:
		velocity.x = -RUN_MAX

	# Don't slide on the ground
	if abs(velocity.x) < 50:
		velocity.x = 0

	# Skid
	if skid > 0:
		if skid == SKID_TIME:
			$SFX/Skid.play()
		skid -= 1
	else:
		skid = 0

	# Gravity
	velocity.y += GRAVITY

	velocity = move_and_slide(velocity, FLOOR)

	# Floor check
	if is_on_floor():
		on_ground = 0
		jumpcancel = false
		$SquishRadius/CollisionShape2D.disabled = true
		if backflip == true:
			backflip = false
			velocity.x = 0
	else:
		on_ground += 1
		$SquishRadius/CollisionShape2D.disabled = false

	# Running
	if abs(velocity.x) > WALK_MAX:
		running = 1
	else: running = 0

	# Ducking
	if on_ground == 0:
		if not Input.is_action_pressed("duck"):
			ducking = false
		if Input.is_action_pressed("duck") or ($StandWindow.is_colliding() == true and state != "small") and backflip == false:
				ducking = true

	# Jump buffering
	if Input.is_action_pressed("jump"):
			jumpheld += 1
	else:
			jumpheld = 0

	# Jumping
	if Input.is_action_pressed("jump"):
		if jumpheld <= 15:
			if on_ground <= LEDGE_JUMP:
				if state != "small" and Input.is_action_pressed("duck") == true and (Input.is_action_pressed("move_left") == false and Input.is_action_pressed("move_right") == false) and $StandWindow.is_colliding() == false:
						backflip = true
						ducking = false
						backflip_rotation = 0
						velocity.y = -RUNJUMP_POWER
						$SFX/Flip.play()
				elif running == 1:
					velocity.y = -RUNJUMP_POWER
					
				else:
					velocity.y = -JUMP_POWER
				if state == "small":
					$SFX/Jump.play()
				else: $SFX/BigJump.play()
				on_ground = LEDGE_JUMP + 1
			jumpheld = 16
			jumpcancel = true

	# Jump cancelling
	if on_ground != 0 and not Input.is_action_pressed("jump") and backflip == false and jumpcancel == true:
		if velocity.y < 0:
			velocity.y *= 0.5
		else: jumpcancel = false

	# Backflip speed and rotation
	$AnimatedSprite.rotation_degrees = 0
	if backflip == true:
		if $AnimatedSprite.scale.x == 1:
			velocity.x = BACKFLIP_SPEED
			backflip_rotation -= 15
		else:
			velocity.x = -BACKFLIP_SPEED
			backflip_rotation += 15
		$AnimatedSprite.rotation_degrees = backflip_rotation

	# Animations
	$AnimatedSprite.speed_scale = 1
	if backflip == true:
		$AnimatedSprite.play("backflip")
	elif ducking == true:
		$AnimatedSprite.play("duck")
	else:
		if on_ground == 0:
			if skid > 0:
				$AnimatedSprite.play("skid")
			else: if abs(velocity.x) >= 20:
				$AnimatedSprite.speed_scale = abs(velocity.x) * 0.0035
				if $AnimatedSprite.speed_scale < 0.4:
					$AnimatedSprite.speed_scale = 0.4
				$AnimatedSprite.play("walk")
			else: $AnimatedSprite.play("idle")
		else: $AnimatedSprite.play("jump")

	if ducking == true or state == "small":
		$BigHitbox.disabled = true
		$SmallHitbox.disabled = false
	else:
		$BigHitbox.disabled = false
		$SmallHitbox.disabled = true

	# Invincible flashing
	if invincible_time > 0:
		if $AnimatedSprite.visible == true:
			$AnimatedSprite.visible = false
		else: $AnimatedSprite.visible = true
		invincible_time -= 1
	else:
		$AnimatedSprite.visible = true
		invincible_time = 0

	# Shooting
	if Input.is_action_just_pressed("action") and state == "fire" and get_tree().get_nodes_in_group("bullets").size() < 2:
		$SFX/Shoot.play()
		var fireball = preload("res://Scenes/Objects/Fireball.tscn").instance()
		if ducking == true and backflip == false:
			fireball.position = $AnimatedSprite/ShootLocationDuck.global_position
		else: fireball.position = $AnimatedSprite/ShootLocation.global_position
		fireball.velocity = Vector2((FIREBALL_SPEED * $AnimatedSprite.scale.x) + velocity.x,0)
		fireball.add_collision_exception_with(self) # Prevent fireball colliding with player
		get_parent().add_child(fireball) # Shoot fireball as child of player

	# Camera Positioning
	if abs(velocity.x) > 0:
		camera_offset += 2 * (velocity.x / abs(velocity.x))
		if abs(camera_offset) >= (get_viewport().size.x * 0.1):
			camera_offset = (get_viewport().size.x * 0.1) * (camera_offset / abs(camera_offset))
	$Camera2D.position.x = $Camera2D.position.x + (camera_offset - $Camera2D.position.x) / 5

	# Set ends of camera to ends of TileSet
	$Camera2D.limit_left = get_tree().current_scene.get_node("TileMap").get_used_rect().position.x * get_tree().current_scene.get_node("TileMap").get_cell_size().x
	$Camera2D.limit_right = get_tree().current_scene.get_node("TileMap").get_used_rect().end.x * get_tree().current_scene.get_node("TileMap").get_cell_size().x
	if $Camera2D.limit_right < get_viewport().size.x: # If the tilemap is thinner than the window, align the camera to the left
		$Camera2D.limit_right = get_viewport().size.x
	$Camera2D.limit_top = get_tree().current_scene.get_node("TileMap").get_used_rect().position.y * get_tree().current_scene.get_node("TileMap").get_cell_size().y
	if $Camera2D.limit_top > get_viewport().size.y * -1: # If the tilemap is shorter than the window, align the camera to the bottom
		$Camera2D.limit_top = get_viewport().size.y * -1
	$Camera2D.limit_bottom = get_tree().current_scene.get_node("TileMap").get_used_rect().end.y * get_tree().current_scene.get_node("TileMap").get_cell_size().y

	# Block player leaving screen
	if position.x < 16:
		position.x = 16
	if position.x > $Camera2D.limit_right - 16:
		position.x = $Camera2D.limit_right - 16
	if position.y > $Camera2D.limit_bottom:
		kill()
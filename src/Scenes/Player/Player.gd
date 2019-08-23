extends KinematicBody2D

const FLOOR = Vector2(0, -1)
const SLOPE = 999
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
# Speed Tux slows down skidding
const SKID_ACCEL = 950.0
# Speed which Tux slows down
const FRICTION = 0.93

# Jump velocity
const JUMP_POWER = 580
# Running Jump / Backflip velocity
const RUNJUMP_POWER = 640
# Gravity
const GRAVITY = 20.0
# Amount of frames Tux can still jump after falling off a ledge
const LEDGE_JUMP = 3

# Invincible time after being hit
const SAFE_TIME = 60
# Fireball speed
const FIREBALL_SPEED = 500

var velocity = Vector2()
var on_ground = 999 # Frames Tux has been in air (0 if grounded)
var can_jump = false # Can Tux jump
var jumpheld = 0 # Time the jump key has been held
var jumpcancel = false # Can let go of jump to stop vertical ascent
var running = 0 # If horizontal speed is higher than walk max
var skidding = false # Skidding
var ducking = false # Ducking
var duck_disable = 0 # Number of frames Tux can't duck
var duck_disable_wait = false # Wait until Tux isn't colliding
var backflip = false # Backflipping
var backflip_rotation = 0 # Backflip rotation
var state = "fire" # Tux's power-up state
var invincible_time = 0 # Amount of frames Tux is invincible
var camera_offset = 0 # Moves camera horizontally for extended view
var camera_position = Vector2(0,0) # Camera Position
var dead = false # Stop doing stuff if true
var restarted = false # Should Tux call restart level

# Set Tux's current playing animation
func set_animation(anim):
	if state == "small": $Control/AnimatedSprite.play(str(anim, "_small"))
	else: $Control/AnimatedSprite.play(anim)

# Damage Tux
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

# Kill Tux
func kill():
	state = "small"
	$SFX/Kill.play()
	$Hitbox.disabled = true
	$HeadAttack/CollisionShape2D.disabled = true
	$SquishRadius/CollisionShape2D.disabled = true
	$Control/AnimatedSprite.rotation_degrees = 0
	$Control/AnimatedSprite.scale.x = 1
	set_animation("gameover")
	dead = true
	velocity = Vector2 (0,-JUMP_POWER * 1.5)

func _ready():
	position = get_tree().current_scene.get_node("Level/SpawnPos").position

#=============================================================================
# PHYSICS

func _physics_process(delta):

	if get_tree().current_scene.editmode == true:
		set_animation("idle")
		$Hitbox.disabled = true
		$HeadAttack/CollisionShape2D.disabled = true
		$SquishRadius/CollisionShape2D.disabled = true
		duck_disable = 3
		duck_disable_wait = true
		return

	if dead == true:
		if Input.is_action_pressed("pause"):
			if restarted == false:
					get_tree().current_scene.call("restart_level")
					restarted = true
		if position.y > get_viewport().size.y and velocity.y > 0:
			if restarted == false:
				get_tree().current_scene.call("restart_level")
				restarted = true
			$Control.visible = false
			return
		$Control/AnimatedSprite.z_index = 999
		velocity.y += GRAVITY
		$Hitbox.disabled = true
		$HeadAttack/CollisionShape2D.disabled = true
		$SquishRadius/CollisionShape2D.disabled = true
		velocity = move_and_slide(velocity, Vector2(0,0))
		return

	# Horizontal movement
	if Input.is_action_pressed("move_right") and (ducking == false or on_ground != 0) and backflip == false:
		$Control/AnimatedSprite.scale.x = 1
		if skidding == false and velocity.x >= 0:
			if velocity.x == 0:
				velocity.x += WALK_ADD
			if running == 1:
					velocity.x += RUN_ACCEL / 60
			else: velocity.x += WALK_ACCEL / 60

			# Skidding and air turning
		if velocity.x < 0:
			if on_ground == 0:
				velocity.x += SKID_ACCEL / 60
				if skidding == false and velocity.x <= -WALK_MAX:
					skidding == true
			else: velocity.x += TURN_ACCEL / 60

	else: if Input.is_action_pressed("move_left") and (ducking == false or on_ground != 0) and backflip == false:
		$Control/AnimatedSprite.scale.x = -1
		if skidding == false and velocity.x <= 0:
			if velocity.x == 0:
				velocity.x -= WALK_ADD
			if running == 1:
					velocity.x -= RUN_ACCEL / 60
			else: velocity.x -= WALK_ACCEL / 60

		# Skidding and air turning
		if velocity.x > 0:
			if on_ground == 0:
				velocity.x -= SKID_ACCEL / 60
				if skidding == false and velocity.x >= WALK_MAX:
					skidding == true
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

	# Gravity
	velocity.y += GRAVITY

	velocity = move_and_slide(velocity, FLOOR, SLOPE)

	# Floor check
	if is_on_floor():
		if on_ground != 0:
			$AnimationPlayer.stop()
			$AnimationPlayer.playback_speed = 1
			if on_ground >= 40:
				$AnimationPlayer.play("Land")
			elif on_ground >= 20:
				$AnimationPlayer.play("LandSmall")
			else: $AnimationPlayer.play("Stop")
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
		ducking = false
		if (Input.is_action_pressed("duck") or $StandWindow.is_colliding() == true) and backflip == false and state != "small":
			if duck_disable == 0 and duck_disable_wait == false:
				ducking = true
			else:
				if duck_disable <= 0:
					duck_disable = 0
					if $StandWindow.is_colliding() == false: duck_disable_wait = false
				else:
					duck_disable -= 1

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
				$AnimationPlayer.playback_speed = 1
				$AnimationPlayer.play("Jump")
				jumpheld = 16
				jumpcancel = true

	# Jump cancelling
	if on_ground != 0 and not Input.is_action_pressed("jump") and backflip == false and jumpcancel == true:
		if velocity.y < 0:
			$AnimationPlayer.playback_speed += 0.3
			velocity.y *= 0.5
		else:
			jumpcancel = false

	# Backflip speed and rotation
	$Control/AnimatedSprite.rotation_degrees = 0
	if backflip == true:
		if $Control/AnimatedSprite.scale.x == 1:
			velocity.x = BACKFLIP_SPEED
			backflip_rotation -= 15
		else:
			velocity.x = -BACKFLIP_SPEED
			backflip_rotation += 15
		$Control/AnimatedSprite.rotation_degrees = backflip_rotation

	# Animations
	$Control/AnimatedSprite.speed_scale = 1
	if backflip == true:
		set_animation("backflip")
	elif ducking == true:
		set_animation("duck")
	else:
		if on_ground == 0:
			if skidding == true:
				set_animation("skid")
			else: if abs(velocity.x) >= 20:
				$Control/AnimatedSprite.speed_scale = abs(velocity.x) * 0.0035
				if $Control/AnimatedSprite.speed_scale < 0.4:
					$Control/AnimatedSprite.speed_scale = 0.4
				set_animation("walk")
			else: set_animation("idle")
		else: set_animation("jump")

	# Duck Hitboxes
	if ducking == true or state == "small":
		$Hitbox.shape.extents.y = 15
		$Hitbox.position.y = 23
		$HeadAttack/CollisionShape2D.position.y = 11
		$ShootLocation.position.y = 22
	else:
		$Hitbox.shape.extents.y = 31
		$Hitbox.position.y = 7
		$HeadAttack/CollisionShape2D.position.y = -21
		$ShootLocation.position.y = 1
	$ShootLocation.position.x = $Control/AnimatedSprite.scale.x * 16

	# Invincible flashing
	if invincible_time > 0:
		if $Control.visible == true:
			$Control.visible = false
		else: $Control.visible = true
		invincible_time -= 1
	else:
		$Control.visible = true
		invincible_time = 0

	# Shooting
	if Input.is_action_just_pressed("action") and state == "fire" and get_tree().get_nodes_in_group("bullets").size() < 2:
		$SFX/Shoot.play()
		var fireball = preload("res://Scenes/Objects/Fireball.tscn").instance()
		fireball.position = $ShootLocation.global_position
		fireball.velocity = Vector2((FIREBALL_SPEED * $Control/AnimatedSprite.scale.x) + velocity.x,0)
		fireball.add_collision_exception_with(self) # Prevent fireball colliding with player
		get_parent().add_child(fireball) # Shoot fireball as child of player

	# Camera Positioning
	if abs(velocity.x) > 0:
		camera_offset += 2 * (velocity.x / abs(velocity.x))
		if abs(camera_offset) >= (get_viewport().size.x * 0.1):
			camera_offset = (get_viewport().size.x * 0.1) * (camera_offset / abs(camera_offset))
	camera_position.x = camera_position.x + (camera_offset - camera_position.x) / 5
	get_tree().current_scene.get_node("Camera2D").position = Vector2(position.x + camera_position.x,position.y + camera_position.y)

	# Block player leaving screen
	if position.x <= get_tree().current_scene.get_node("Camera2D").limit_left + 16:
		position.x = get_tree().current_scene.get_node("Camera2D").limit_left + 16
	if position.x >= get_tree().current_scene.get_node("Camera2D").limit_right - 16:
		position.x = get_tree().current_scene.get_node("Camera2D").limit_right - 16
	if position.y >= get_tree().current_scene.get_node("Camera2D").limit_bottom:
		position.y = get_tree().current_scene.get_node("Camera2D").limit_bottom
		kill()
extends KinematicBody2D

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

# Speed which Tux slows down
const FRICTION = 0.93
# Speed Tux slows down when sliding
const SLIDE_FRICTION = 0.99
# Acceleration when holding the opposite direction
const TURN_ACCEL = 1800.0

# Jump velocity
const JUMP_POWER = 580
# Running Jump / Backflip velocity
const RUNJUMP_POWER = 640
# Amount of frames you can hold jump before landing and still jump
const JUMP_BUFFER_TIME = 15
# Gravity
const GRAVITY = 20.0
# Gravity when buttjumping
const BUTTJUMP_GRAVITY = 120.0
# Amount of frames Tux can still jump after falling off a ledge
const LEDGE_JUMP = 3
# Falling speedcap
const FALL_SPEED = 1280.0
# Buttjumping speedcap
const BUTTJUMP_FALL_SPEED = 2000.0
# How long to stay in the buttjump landing pose
const BUTTJUMP_LAND_TIME = 0.3

# Fireball speed
const FIREBALL_SPEED = 500

var velocity = Vector2()
var on_ground = 999 # Frames Tux has been in air (0 if grounded)
var jumpheld = 0 # Amount of frames jump has been held
var jumpcancel = false # Can let go of jump to stop vertical ascent
var skidding = false # Skidding
var sliding = false # Sliding
var ducking = false # Ducking
var backflip = false # Backflipping
var backflip_rotation = 0 # Backflip rotation
var buttjump = false # Butt-jumping
var powerup = "fire" # Tux's power-up powerup
var camera_offset = 0 # Moves camera horizontally for extended view
var camera_position = Vector2() # Camera Position
var dead = false # Stop doing stuff if true
var restarted = false # Should Tux call restart level
var invincible_damage = false
var invincible = false
var using_star = false
var holding_object = false
var object_held = ""
var ground_normal = Vector2()

# Set Tux's current playing animation
func set_animation(anim):
	if powerup == "small": $Control/AnimatedSprite.play(str(anim, "_small"))
	else: $Control/AnimatedSprite.play(anim)

# Damage Tux
func hurt():
	if invincible_damage == false and invincible == false:
		if powerup == "small":
			kill()
		elif powerup == "big":
			powerup = "small"
			backflip = false
			buttjump = false
			ducking = false
			$SFX/Hurt.play()
			damage_invincibility()
			var frame = $Control/AnimatedSprite.frame
			set_animation($Control/AnimatedSprite.animation)
			$Control/AnimatedSprite.frame = frame
		else:
			powerup = "big"
			$SFX/Hurt.play()
			damage_invincibility()

# Kill Tux
func kill():
	if dead:
		return

	invincible = false
	invincible_damage = false
	powerup = "small"
	$SFX/Kill.play()
	$AnimationPlayerInvincibility.play("Stop")
	$Control/AnimatedSprite.rotation_degrees = 0
	$Control/AnimatedSprite.scale.x = 1
	$AnimationPlayer.play("Stop")
	set_animation("gameover")
	dead = true
	velocity = Vector2 (0,-JUMP_POWER * 1.5)

func _ready():
	position = Vector2(0,0)
	for child in get_tree().current_scene.get_node("Level").get_children():
		if child.is_in_group("spawnpoint"):
			position = child.position

#=============================================================================
# PHYSICS

func _physics_process(delta):

	if get_tree().current_scene.editmode == true:
		set_animation("idle")
		$HitboxBig.disabled = true
		$HitboxSmall.disabled = true
		return

	if dead == true:
		if Input.is_action_pressed("pause"):
			if restarted == false:
					get_tree().current_scene.call("restart_level")
					restarted = true
		if position.y >= get_tree().current_scene.get_node("Camera2D").limit_bottom and velocity.y > 0:
			if restarted == false:
				get_tree().current_scene.call("restart_level")
				restarted = true
			self.visible = false
			return
		$Control/AnimatedSprite.z_index = 999
		$HitboxBig.disabled = true
		$HitboxSmall.disabled = true
		$ButtjumpHitbox/CollisionShape2D.disabled = true
		position += velocity * delta
		velocity.y += GRAVITY
		return

	# Horizontal movement
	if (ducking == false or on_ground != 0) and backflip == false and skidding == false and sliding == false and $ButtjumpLandTimer.time_left == 0:
		if Input.is_action_pressed("move_right"):
			$Control/AnimatedSprite.scale.x = 1
			
			# Moving
			if velocity.x >= 0:
				if velocity.x < WALK_ADD:
					velocity.x = WALK_ADD
				if abs(velocity.x) > WALK_MAX:
						velocity.x += RUN_ACCEL * delta
				else: velocity.x += WALK_ACCEL * delta
			
			# Skidding
			elif on_ground == 0 and abs(velocity.x) >= WALK_MAX:
				if skidding == false:
					skidding = true
					$SFX/Skid.play()
			
			# Air turning
			else: velocity.x += TURN_ACCEL * delta
		
		if Input.is_action_pressed("move_left"):
			$Control/AnimatedSprite.scale.x = -1
			if velocity.x <= 0:
				
				# Moving
				$Control/AnimatedSprite.scale.x = -1
				if velocity.x > -WALK_ADD:
					velocity.x = -WALK_ADD
				if abs(velocity.x) > WALK_MAX:
						velocity.x -= RUN_ACCEL * delta
				else: velocity.x -= WALK_ACCEL * delta
			
			# Skidding
			elif on_ground == 0 and abs(velocity.x) >= WALK_MAX:
				if skidding == false:
					skidding = true
					$SFX/Skid.play()
			
			# Air turning
			else: velocity.x -= TURN_ACCEL * delta

	# Speedcap
	if sliding == false:
		if velocity.x >= RUN_MAX:
			velocity.x = RUN_MAX
		if velocity.x <= -RUN_MAX:
			velocity.x = -RUN_MAX

	# Friction
	if backflip == false and (skidding == true or (ducking == true and on_ground == 0) or (not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"))):
		
		# Turn when skidding
		if skidding == true:
			if velocity.x > 0:
				$Control/AnimatedSprite.scale.x = -1
			if velocity.x < 0:
				$Control/AnimatedSprite.scale.x = 1
		
		# Friction
		if sliding == false:
			velocity.x *= FRICTION
		elif on_ground == 0: velocity.x *= SLIDE_FRICTION
		if abs(velocity.x) < 80:
			velocity.x = 0

	# Stop skidding if low velocity
	if abs(velocity.x) < 75 and skidding == true:
		skidding = false
		velocity.x = 0

	# Move
	var oldvelocity = velocity
	if on_ground == 0:
		velocity = move_and_slide_with_snap(velocity, Vector2(0, 20), FLOOR)
	else: velocity = move_and_slide(velocity, FLOOR)
	if abs(velocity.x) > abs(oldvelocity.x) and $ButtjumpLandTimer.time_left > 0:
		start_sliding()

	# Gravity
	if $ButtjumpTimer.time_left > 0:
		velocity *= 0.5
	elif buttjump == false or velocity.y <= 0:
		if on_ground:
			velocity.y += GRAVITY
			if velocity.y > FALL_SPEED: velocity.y = FALL_SPEED
	else:
		if on_ground:
			velocity.y += BUTTJUMP_GRAVITY
			if velocity.y > BUTTJUMP_FALL_SPEED: velocity.y = BUTTJUMP_FALL_SPEED

	# Floor check
	if is_on_floor(): #on_ground():
		if on_ground != 0:
			$AnimationPlayer.stop()
			$AnimationPlayer.playback_speed = 1
			if buttjump == true:
				$AnimationPlayer.play("ButtjumpLand")
				$ButtjumpLandTimer.start(BUTTJUMP_LAND_TIME)
				$SFX/Brick.play()
				buttjump = false
			elif on_ground >= 40:
				$AnimationPlayer.play("Land")
			elif on_ground >= 20:
				$AnimationPlayer.play("LandSmall")
			else:
				$AnimationPlayer.play("Stop")
		on_ground = 0
		jumpcancel = false
		if backflip == true:
			backflip = false
			velocity.x = 0
	else:
		on_ground += 1
		$ButtjumpLandTimer.stop()

	# Ceiling bump sound
	if is_on_ceiling():
		$SFX/Thud.play()

	# Ducking / Sliding
	if on_ground == 0:
		# Stop ducking in certain situations
		if not Input.is_action_pressed("duck") or powerup == "small": ducking = false
		
		# Duck if in one block space
		if $StandWindow.is_colliding() == true and sliding == false and powerup != "small": ducking = true
		
		# Ducking / Sliding
		elif Input.is_action_pressed("duck") and sliding == false and $ButtjumpLandTimer.time_left == 0:
			if abs(velocity.x) < WALK_MAX:
				if powerup != "small": ducking = true
			else: start_sliding()
	elif $StandWindow.is_colliding() == true and sliding == false and powerup != "small": ducking = true
	else: ducking == false

	# Sliding
	if sliding == true:
		var angle = rad2deg($RayCast2D.get_collision_normal().angle_to(Vector2(0, -1))) * -1
		rotation_degrees = rotation_degrees + (angle - rotation_degrees) / 1
		invincible = true
		if $StandWindow.is_colliding() == true: # Push Tux forward when stuck in a one block space to prevent getting stuck
			velocity.x += 4 * $Control/AnimatedSprite.scale.x
		if abs(velocity.x) < 20 and on_ground == 0:
			sliding = false
			if $StandWindow.is_colliding() == true: ducking = true
	else:
		rotation_degrees = rotation_degrees + (0 - rotation_degrees) / 5
		if using_star == false: invincible = false

	# Jump buffering
	if Input.is_action_pressed("jump"):
		jumpheld += 1
	else: jumpheld = 0

	# Jumping
	if Input.is_action_pressed("jump") and jumpheld <= JUMP_BUFFER_TIME:
		if on_ground <= LEDGE_JUMP and $ButtjumpLandTimer.time_left <= BUTTJUMP_LAND_TIME - 0.02:
			if powerup != "small" and Input.is_action_pressed("duck") == true and $StandWindow.is_colliding() == false and sliding == false and $ButtjumpLandTimer.time_left == 0:
				backflip = true
				backflip_rotation = 0
				velocity.y = -RUNJUMP_POWER
				$SFX/Flip.play()
			elif abs(velocity.x) >= RUN_MAX or $ButtjumpLandTimer.time_left > 0:
				velocity.y = -RUNJUMP_POWER
			else:
				velocity.y = -JUMP_POWER
			if powerup == "small":
				$SFX/Jump.play()
			else: $SFX/BigJump.play()
			on_ground = LEDGE_JUMP + 1
			$AnimationPlayer.playback_speed = 1
			$AnimationPlayer.stop()
			$AnimationPlayer.play("Stop")
			set_animation("jump")
			jumpheld = JUMP_BUFFER_TIME + 1
			on_ground = LEDGE_JUMP + 1
			jumpcancel = true
			sliding = false
			skidding = false
			ducking = false
			if $StandWindow.is_colliding() == true and powerup != "small": ducking = true

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

	# Buttjump
	if on_ground != 0 and Input.is_action_just_pressed("duck") and powerup != "small" and backflip == false and buttjump == false:
		buttjump = true
		$AnimationPlayer.stop()
		$AnimationPlayer.play("Buttjump")
		$ButtjumpTimer.start(0.15)

	# Stop buttjump if small
	if buttjump == true and powerup == "small":
		buttjump = false
		$AnimationPlayer.stop()
		$AnimationPlayer.play("Stop")
		set_animation("fall")

	# Animations
	$Control/AnimatedSprite.speed_scale = 1
	if buttjump == true:
		set_animation("buttjump")
	elif backflip == true:
		set_animation("backflip")
	elif ducking == true:
		set_animation("duck")
	elif sliding == true:
		set_animation("slide")
	else:
		if on_ground <= LEDGE_JUMP:
			if $ButtjumpLandTimer.time_left > 0:
				set_animation("buttjumpland")
			elif skidding == true:
				set_animation("skid")
			elif abs(velocity.x) >= WALK_ADD / 2:
				$Control/AnimatedSprite.speed_scale = abs(velocity.x) * 0.0035
				if $Control/AnimatedSprite.speed_scale < 0.4:
					$Control/AnimatedSprite.speed_scale = 0.4
				set_animation("walk")
			else: set_animation("idle")
		elif velocity.y > 0:
			if $Control/AnimatedSprite.animation == ("jump") or $Control/AnimatedSprite.animation == ("fall_transition") or  $Control/AnimatedSprite.animation == ("jump_small") or $Control/AnimatedSprite.animation == ("fall_transition_small"):
				set_animation("fall_transition")
			else: set_animation("fall")
		else: set_animation("jump")

	# Duck Hitboxes
	if ducking == true or sliding == true or powerup == "small" or buttjump == true:
		$HitboxBig.disabled = true
		$HitboxSmall.disabled = false
		$ShootLocation.position.y = 16
	else:
		$HitboxBig.disabled = false
		$HitboxSmall.disabled = true
		$ShootLocation.position.y = 0
	$ShootLocation.position.x = $Control/AnimatedSprite.scale.x * 8

	# Buttjump hitboxes
	if buttjump == true and $ButtjumpTimer.time_left == 0:
		$ButtjumpHitbox/CollisionShape2D.disabled = false
		
		# Change the buttjump hitbox's size so it always collides before Tux hits the ground
		if velocity.y > 0:
			$ButtjumpHitbox/CollisionShape2D.shape.extents = Vector2(25,16 + (velocity.y * delta))
			$ButtjumpHitbox/CollisionShape2D.position.y = (velocity.y * delta)
		else:
			$ButtjumpHitbox/CollisionShape2D.shape.extents = Vector2(25,16)
			$ButtjumpHitbox/CollisionShape2D.position.y = 0
	else:
		$ButtjumpHitbox/CollisionShape2D.shape.extents = Vector2(0,0)
		$ButtjumpHitbox/CollisionShape2D.disabled = true

	# Shooting
	if Input.is_action_just_pressed("action") and powerup == "fire" and get_tree().get_nodes_in_group("bullets").size() < 2:
		$SFX/Shoot.play()
		var fireball = load("res://Scenes/Player/Objects/Fireball.tscn").instance()
		fireball.position = $ShootLocation.global_position
		fireball.velocity = Vector2((FIREBALL_SPEED * $Control/AnimatedSprite.scale.x) + velocity.x,0)
		fireball.add_collision_exception_with(self) # Prevent fireball colliding with player
		get_parent().add_child(fireball) # Shoot fireball as child of player

	# Camera Positioning
	if abs(velocity.x) > WALK_ADD:
		camera_offset += 2 * (velocity.x / abs(velocity.x))
		if abs(camera_offset) >= (get_viewport().size.x * 0.1) * get_tree().current_scene.get_node("Camera2D").zoom.x:
			camera_offset = (get_viewport().size.x * 0.1) * get_tree().current_scene.get_node("Camera2D").zoom.x * (camera_offset / abs(camera_offset))
	camera_position.x = camera_position.x + (camera_offset - camera_position.x) / 5
	get_tree().current_scene.get_node("Camera2D").position = Vector2(position.x + camera_position.x,position.y + camera_position.y)

	# Block player leaving screen
	if position.x <= get_tree().current_scene.get_node("Camera2D").limit_left + 16:
		position.x = get_tree().current_scene.get_node("Camera2D").limit_left + 16
		velocity.x = 0
	if position.x >= get_tree().current_scene.get_node("Camera2D").limit_right - 16:
		position.x = get_tree().current_scene.get_node("Camera2D").limit_right - 16
		velocity.x = 0
	if position.y >= get_tree().current_scene.get_node("Camera2D").limit_bottom:
		position.y = get_tree().current_scene.get_node("Camera2D").limit_bottom
		kill()

	# Carry objects
	if holding_object == true:
		# Set the object's position
		get_tree().current_scene.get_node(str("Level/", object_held)).position = Vector2(position.x + $ShootLocation.position.x, position.y + $ShootLocation.position.y)
		
		# Set the object's direction
		if get_tree().current_scene.get_node(str("Level/", object_held)).has_node("Sprite"): get_tree().current_scene.get_node(str("Level/", object_held, "/Sprite")).scale.x = $Control/AnimatedSprite.scale.x * -1
		if get_tree().current_scene.get_node(str("Level/", object_held)).has_node("AnimatedSprite"): get_tree().current_scene.get_node(str("Level/", object_held, "/AnimatedSprite")).scale.x = $Control/AnimatedSprite.scale.x * -1
		if get_tree().current_scene.get_node(str("Level/", object_held)).has_node("Control/AnimatedSprite"): get_tree().current_scene.get_node(str("Level/", object_held, "/Control/AnimatedSprite")).scale.x = $Control/AnimatedSprite.scale.x * -1
		
		# Throw objects
		if not Input.is_action_pressed("action"):
			holding_object = false
			if get_tree().current_scene.get_node(str("Level/", object_held)).has_method("throw"):
				get_tree().current_scene.get_node(str("Level/", object_held)).throw()
				if not Input.is_action_pressed("duck"): get_tree().current_scene.get_node(str("Level/", object_held)).velocity.x = velocity.x + (200 * $Control/AnimatedSprite.scale.x)

# Star invincibility
func star_invincibility():
	using_star = true
	invincible = true
	self.show()
	$InvincibilityTimer.start(14)
	get_tree().current_scene.play_music("invincible.ogg")
	$AnimationPlayerInvincibility.stop()
	$AnimationPlayerInvincibility.play("InvincibleStar")

# Damage invincibility
func damage_invincibility():
	invincible_damage = true
	$InvincibilityTimer.start(1.8)
	$AnimationPlayerInvincibility.stop()
	$AnimationPlayerInvincibility.play("HurtInvincibility")

func _on_InvincibilityTimer_timeout():
	invincible = false
	invincible_damage = false
	using_star = false
	self.show()
	$AnimationPlayerInvincibility.stop()
	$AnimationPlayerInvincibility.play("Stop")

# Bounce off squished enemies
func bounce(low, high, cancellable):
	on_ground = LEDGE_JUMP + 1
	sliding = false
	backflip = false
	buttjump = false
	on_ground = LEDGE_JUMP + 1
	$ButtjumpTimer.stop()
	$ButtjumpLandTimer.stop()
	$AnimationPlayer.play("Stop")
	$Control/AnimatedSprite.play("jump")
	set_animation("jump")
	if jumpheld > 0:
		velocity.y = -high
		jumpcancel = cancellable
	else:
		velocity.y = -low
		jumpcancel = false

# Activate sliding
func start_sliding():
	$ButtjumpLandTimer.stop()
	sliding = true
	$SFX/Skid.play()
	velocity.x += WALK_ADD * $Control/AnimatedSprite.scale.x
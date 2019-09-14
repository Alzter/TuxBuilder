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
const TURN_ACCEL = 900.0

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
var jumpheld = 0 # Amount of frames jump has been help
var jumpcancel = false # Can let go of jump to stop vertical ascent
var running = 0 # If horizontal speed is higher than walk max
var skidding = false # Skidding
var sliding = false # Sliding
var ducking = false # Ducking
var backflip = false # Backflipping
var backflip_rotation = 0 # Backflip rotation
var buttjump = false # Butt-jumping
var state = "fire" # Tux's power-up state
var camera_offset = 0 # Moves camera horizontally for extended view
var camera_position = Vector2(0,0) # Camera Position
var dead = false # Stop doing stuff if true
var restarted = false # Should Tux call restart level
var invincible_damage = false
var invincible = false
var using_star = false
var holding_object = false
var object_held = ""

# Set Tux's current playing animation
func set_animation(anim):
	if state == "small": $Control/AnimatedSprite.play(str(anim, "_small"))
	else: $Control/AnimatedSprite.play(anim)

# Damage Tux
func hurt():
	if invincible_damage == false and invincible == false:
		if state == "small":
			kill()
		elif state == "big":
			state = "small"
			$SFX/Hurt.play()
			damage_invincibility()
		else:
			state = "big"
			backflip = false
			ducking = false
			$SFX/Hurt.play()
			damage_invincibility()

# Kill Tux
func kill():
	invincible = false
	invincible_damage = false
	state = "small"
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
		$Hitbox.disabled = true
		return

	$Hitbox.disabled = false

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
		$Hitbox.disabled = true
		position += velocity * delta
		velocity.y += GRAVITY
		return

	# Horizontal movement
	if Input.is_action_pressed("move_right") and (ducking == false or on_ground != 0) and backflip == false and skidding == false and sliding == false and $ButtjumpLandTimer.time_left == 0:
		$Control/AnimatedSprite.scale.x = 1
		if velocity.x == 0:
			velocity.x += WALK_ADD
		if running == 1:
				velocity.x += RUN_ACCEL / 60
		else: velocity.x += WALK_ACCEL / 60
		
		# Skidding and air turning
		if velocity.x < 0:
			if on_ground == 0 and velocity.x <= -WALK_MAX:
				if skidding == false:
					skidding = true
					$SFX/Skid.play()
			else: velocity.x += TURN_ACCEL / 60

	else: if Input.is_action_pressed("move_left") and (ducking == false or on_ground != 0) and backflip == false and skidding == false and sliding == false and $ButtjumpLandTimer.time_left == 0:
		$Control/AnimatedSprite.scale.x = -1
		if velocity.x == 0:
			velocity.x -= WALK_ADD
		if running == 1:
				velocity.x -= RUN_ACCEL / 60
		else: velocity.x -= WALK_ACCEL / 60
		
		# Skidding and air turning
		if velocity.x > 0:
			if on_ground == 0 and velocity.x >= WALK_MAX:
				if skidding == false:
					skidding = true
					$SFX/Skid.play()
			else: velocity.x -= TURN_ACCEL / 60

	else: if backflip == false:
		if sliding == false:
			velocity.x *= FRICTION
		else: velocity.x *= SLIDE_FRICTION

	# Speedcap
	if sliding == false:
		if velocity.x >= RUN_MAX:
			velocity.x = RUN_MAX
		if velocity.x <= -RUN_MAX:
			velocity.x = -RUN_MAX

	# Don't slide on the ground
	if abs(velocity.x) < 50:
		velocity.x = 0

	# Stop skidding if low velocity
	if abs(velocity.x) < 75 and skidding == true:
		skidding = false
		velocity.x = 0

	# Gravity
	if buttjump == false or velocity.y <= 0:
		velocity.y += GRAVITY
		if velocity.y > FALL_SPEED: velocity.y = FALL_SPEED
	elif $ButtjumpTimer.time_left == 0:
		velocity.y += BUTTJUMP_GRAVITY
		if velocity.y > BUTTJUMP_FALL_SPEED: velocity.y = BUTTJUMP_FALL_SPEED
	else: velocity *= 0.4

	velocity = move_and_slide(velocity, FLOOR, 30)

	# Floor check
	if is_on_floor():
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
		$SFX/Brick.play()

	# Running
	if abs(velocity.x) > WALK_MAX:
		running = 1
	else: running = 0

	# Ducking / Sliding
	if on_ground == 0:
		# Stop ducking in certain situations
		if not Input.is_action_pressed("duck") or state == "small": ducking = false
		
		# Duck if in one block space
		if $StandWindow.is_colliding() == true and sliding == false and state != "small": ducking = true
		
		# Ducking / Sliding
		elif Input.is_action_pressed("duck") and sliding == false and $ButtjumpLandTimer.time_left == 0:
			if abs(velocity.x) < WALK_MAX:
				if state != "small": ducking = true
			else:
				sliding = true
				$SFX/Skid.play()
				velocity.x += WALK_ADD * $Control/AnimatedSprite.scale.x
	else: ducking = false

	# Sliding
	if sliding == true:
		invincible = true
		if $StandWindow.is_colliding() == true: # Push Tux forward when stuck in a one block space to prevent getting stuck
			velocity.x += 4 * $Control/AnimatedSprite.scale.x
		if abs(velocity.x) < 20 and on_ground == 0:
			sliding = false
			if $StandWindow.is_colliding() == true: ducking = true
	elif using_star == false: invincible = false

	# Jump buffering
	if Input.is_action_pressed("jump"):
		jumpheld += 1
	else: jumpheld = 0

	# Jumping
	if Input.is_action_pressed("jump") and jumpheld <= JUMP_BUFFER_TIME:
		if on_ground <= LEDGE_JUMP and $ButtjumpLandTimer.time_left <= BUTTJUMP_LAND_TIME - 0.02:
			if state != "small" and Input.is_action_pressed("duck") == true and $StandWindow.is_colliding() == false and sliding == false and $ButtjumpLandTimer.time_left == 0:
				backflip = true
				backflip_rotation = 0
				velocity.y = -RUNJUMP_POWER
				$SFX/Flip.play()
			elif abs(velocity.x) >= RUN_MAX or $ButtjumpLandTimer.time_left > 0:
				velocity.y = -RUNJUMP_POWER
			else:
				velocity.y = -JUMP_POWER
			if state == "small":
				$SFX/Jump.play()
			else: $SFX/BigJump.play()
			on_ground = LEDGE_JUMP + 1
			$AnimationPlayer.playback_speed = 1
			$AnimationPlayer.play("Jump")
			set_animation("jump")
			jumpheld = JUMP_BUFFER_TIME + 1
			jumpcancel = true
			sliding = false
			skidding = false
			ducking = false
			if $StandWindow.is_colliding() == true and state != "small": ducking = true

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
	if on_ground != 0 and Input.is_action_just_pressed("duck") and state != "small" and backflip == false and buttjump == false:
		buttjump = true
		$AnimationPlayer.stop()
		$AnimationPlayer.play("Buttjump")
		$ButtjumpTimer.start(0.15)

	# Stop buttjump if small
	if buttjump == true and state == "small":
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
		set_animation("jump") # Placeholder until slide animation is added
	else:
		if on_ground == 0:
			if $ButtjumpLandTimer.time_left > 0:
				set_animation("buttjumpland")
			elif skidding == true:
				set_animation("skid")
			elif abs(velocity.x) >= 20:
				$Control/AnimatedSprite.speed_scale = abs(velocity.x) * 0.0035
				if $Control/AnimatedSprite.speed_scale < 0.4:
					$Control/AnimatedSprite.speed_scale = 0.4
				set_animation("walk")
			else: set_animation("idle")
		elif velocity.y > 0:
			if $Control/AnimatedSprite.animation == ("jump") or $Control/AnimatedSprite.animation == ("fall_transition") or  $Control/AnimatedSprite.animation == ("jump_small") or $Control/AnimatedSprite.animation == ("fall_transition_small"):
				set_animation("fall_transition")
			else: set_animation("fall")

	# Duck Hitboxes
	if ducking == true or sliding == true or state == "small" or buttjump == true:
		$Hitbox.shape.extents.y = 15
		$Hitbox.position.y = 17
		$ShootLocation.position.y = 17
		$GrabLocation.position.y = 17
	else:
		$Hitbox.shape.extents.y = 31
		$Hitbox.position.y = 1
		$ShootLocation.position.y = 1
		$GrabLocation.position.y = 1
	$ShootLocation.position.x = $Control/AnimatedSprite.scale.x * 16
	$GrabLocation.position.x = $Control/AnimatedSprite.scale.x * 16

	# Buttjump hitboxes
	if buttjump == true and $ButtjumpTimer.time_left == 0:
		$ButtjumpHitbox/CollisionShape2D.disabled = false
		
		# Change the buttjump hitbox's size so it always collides before Tux hits the ground
		if velocity.y > 0:
			$ButtjumpHitbox/CollisionShape2D.shape.extents = Vector2(25,(velocity.y * delta))
			$ButtjumpHitbox/CollisionShape2D.position.y = (velocity.y * delta)
		else:
			$ButtjumpHitbox/CollisionShape2D.shape.extents = Vector2(25,16)
			$ButtjumpHitbox/CollisionShape2D.position.y = 0
	else:
		$ButtjumpHitbox/CollisionShape2D.shape.extents = Vector2(0,0)
		$ButtjumpHitbox/CollisionShape2D.disabled = true

	# Shooting
	if Input.is_action_just_pressed("action") and state == "fire" and get_tree().get_nodes_in_group("bullets").size() < 2:
		$SFX/Shoot.play()
		var fireball = load("res://Scenes/Player/Objects/Fireball.tscn").instance()
		fireball.position = $ShootLocation.global_position
		fireball.velocity = Vector2((FIREBALL_SPEED * $Control/AnimatedSprite.scale.x) + velocity.x,0)
		fireball.add_collision_exception_with(self) # Prevent fireball colliding with player
		get_parent().add_child(fireball) # Shoot fireball as child of player

	# Camera Positioning
	if abs(velocity.x) > 0:
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
		get_tree().current_scene.get_node(str("Level/", object_held)).position = Vector2(position.x + $GrabLocation.position.x, position.y + $GrabLocation.position.y)
		
		# Set the object's direction
		if get_tree().current_scene.get_node(str("Level/", object_held)).has_node("Sprite"): get_tree().current_scene.get_node(str("Level/", object_held, "/Sprite")).scale.x = $Control/AnimatedSprite.scale.x * -1
		if get_tree().current_scene.get_node(str("Level/", object_held)).has_node("AnimatedSprite"): get_tree().current_scene.get_node(str("Level/", object_held, "/AnimatedSprite")).scale.x = $Control/AnimatedSprite.scale.x * -1
		if get_tree().current_scene.get_node(str("Level/", object_held)).has_node("Control/AnimatedSprite"): get_tree().current_scene.get_node(str("Level/", object_held, "/Control/AnimatedSprite")).scale.x = $Control/AnimatedSprite.scale.x * -1
		
		# Throw objects
		if not Input.is_action_pressed("action"):
			holding_object = false
			if get_tree().current_scene.get_node(str("Level/", object_held)).has_method("throw"):
				get_tree().current_scene.get_node(str("Level/", object_held)).throw()

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
func bounce():
	sliding = false
	$AnimationPlayer.play("Jump")
	$Control/AnimatedSprite.play("jump")
	set_animation("jump")
	if jumpheld > 0:
		velocity.y = -JUMP_POWER
		jumpcancel = true
	else:
		velocity.y = -300
		jumpcancel = false
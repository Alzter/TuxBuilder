extends KinematicBody2D

var player_state = "Movement" # Each player state has a different script assigned to it.

const FLOOR = Vector2(0, -1)
const WALK_ADD = 120.0 # Instant speed when starting walk
const WALK_ACCEL = 350.0 # Speed Tux accelerates per second when walking
const RUN_ACCEL = 400.0 # Speed Tux accelerates per second when running
const WALK_MAX = 230.0 # Speed you need to start running
var run_max = 320.0 # Maximum horizontal speed (Changes with wind)
const BACKFLIP_SPEED = -128 # Backflip horizontal speed
const FRICTION = 0.93 # Speed which Tux slows down
const SLIDE_FRICTION = 0.99 # Speed Tux slows down when sliding
const TURN_ACCEL = 1800.0 # Acceleration when holding the opposite direction
const JUMP_POWER = 580 # Jump velocity
const RUNJUMP_POWER = 640 # Running Jump / Backflip velocity
const JUMP_BUFFER_TIME = 15 # Amount of frames you can hold jump before landing and still jump
const GRAVITY = 20.0 # Gravity
const BUTTJUMP_GRAVITY = 120.0 # Gravity when buttjumping
const LEDGE_JUMP = 3 # Amount of frames Tux can still jump after falling off a ledge (Coyote Time)
const FALL_SPEED = 1280.0 # Falling speedcap
const BUTTJUMP_FALL_SPEED = 2000.0 # Buttjumping speedcap
const BUTTJUMP_LAND_TIME = 0.3 # How long to stay in the buttjump landing pose
const FIREBALL_SPEED = 500 # Fireball speed

var velocity = Vector2()
var on_ground = 999 # Frames Tux has been in air (0 if grounded)
var jumpheld = 0 # Amount of frames jump has been held
var jumpcancel = false # Can let go of jump to stop vertical ascent
var skidding = false # Skidding
var ducking = false # Ducking
var backflip_rotation = 0 # Backflip rotation
var state = "fire" # Tux's power-up state
var camera_offset = 0 # Moves camera horizontally for extended view
var camera_position = Vector2() # Camera Position
var invincible_damage = false
var invincible = false
var using_star = false
var holding_object = false
var object_held = ""
var wind = 0 # Is Tux being blown by wind (changes some movement properties)
var climbtop = 0 # How high Tux can climb
var climbbottom = 0 # How low Tux can climb

# Set Tux's current playing animation
func set_animation(anim):
	if state == "small": $Control/AnimatedSprite.play(str(anim, "_small"))
	else: $Control/AnimatedSprite.play(anim)

# Damage Tux
func hurt():
	if !invincible_damage and !invincible:
		if state == "small":
			kill()
		elif state == "big":
			state = "small"
			player_state = "Movement"
			ducking = false
			$SFX/Hurt.play()
			damage_invincibility()
			var frame = $Control/AnimatedSprite.frame
			set_animation($Control/AnimatedSprite.animation)
			$Control/AnimatedSprite.frame = frame
		else:
			state = "big"
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
	player_state = "Dead"
	velocity = Vector2 (0,-JUMP_POWER * 1.5)

func _ready():
	position = Vector2(0,0)
	for child in get_tree().current_scene.get_node("Level").get_children():
		if child.is_in_group("spawnpoint"):
			position = child.position

func _step(delta):
	# Move
	var oldvelocity = velocity
	if on_ground == 0 and wind == 0 and player_state != "Climbing":
		velocity = move_and_slide_with_snap(velocity, Vector2(0, 10), FLOOR)
	else: velocity = move_and_slide(velocity, FLOOR)
	if abs(velocity.x) > abs(oldvelocity.x) and $ButtjumpLandTimer.time_left > 0:
		start_sliding()

	# Floor check
	if is_on_floor():
		if on_ground != 0:
			$AnimationPlayer.stop()
			$AnimationPlayer.playback_speed = 1
			if player_state == "Buttjump":
				$AnimationPlayer.play("ButtjumpLand")
				$ButtjumpLandTimer.start(BUTTJUMP_LAND_TIME)
				$SFX/Brick.play()
				player_state = "Movement"
			elif on_ground >= 40:
				$AnimationPlayer.play("Land")
			elif on_ground >= 20:
				$AnimationPlayer.play("LandSmall")
			else:
				$AnimationPlayer.play("Stop")
		on_ground = 0
		jumpcancel = false
		if player_state == "Backflip":
			player_state = "Movement"
			velocity.x = 0
			$Control/AnimatedSprite.rotation_degrees = 0
	else:
		on_ground += 1
		$ButtjumpLandTimer.stop()

	# Ceiling bump sound
	if is_on_ceiling():
		$SFX/Thud.play()

	# Jump buffering
	if Input.is_action_pressed("jump"):
		jumpheld += 1
	else: jumpheld = 0

	# Activate Buttjump
	if player_state == "Movement" and on_ground != 0 and Input.is_action_just_pressed("duck") and state != "small" and $ButtjumpDistance.is_colliding() == false:
		$AnimationPlayer.stop()
		$AnimationPlayer.play("Buttjump")
		$ButtjumpTimer.start(0.15)
		player_state = "Buttjump"

	# Stop buttjump if small
	if player_state == "Buttjump" and state == "small":
		player_state = "Movement"
		$AnimationPlayer.stop()
		$AnimationPlayer.play("Stop")
		set_animation("fall")

	# Shooting
	if Input.is_action_just_pressed("action") and state == "fire" and get_tree().get_nodes_in_group("bullets").size() < 2:
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
	if holding_object:
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
	
	# Decrease Wind variable
	if wind > 0:
		wind -= 1
	else:
		wind = 0
		run_max = 320.0

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
	player_state = "Movement"
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
	player_state = "Sliding"
	$SFX/Skid.play()
	velocity.x += WALK_ADD * $Control/AnimatedSprite.scale.x

func can_jump(can_backflip, aerial):
	# Jumping
	if Input.is_action_pressed("jump") and jumpheld <= JUMP_BUFFER_TIME:
		if (on_ground <= LEDGE_JUMP or aerial) and $ButtjumpLandTimer.time_left <= BUTTJUMP_LAND_TIME - 0.02:
			
			player_state = "Movement"
			# Backflip
			if can_backflip and state != "small" and Input.is_action_pressed("duck") and $StandWindow.is_colliding() == false and $ButtjumpLandTimer.time_left == 0:
				player_state = "Backflip"
				backflip_rotation = 0
				velocity.y = -RUNJUMP_POWER
				$SFX/Flip.play()
			
			# Running jump
			elif abs(velocity.x) >= run_max:
				velocity.y = -RUNJUMP_POWER
			
			# Normal jump
			else:
				velocity.y = -JUMP_POWER
			if state == "small":
				$SFX/Jump.play()
			else: $SFX/BigJump.play()
			$AnimationPlayer.playback_speed = 1
			$AnimationPlayer.play("Stop")
			set_animation("jump")
			jumpheld = JUMP_BUFFER_TIME + 1
			on_ground = LEDGE_JUMP + 1
			jumpcancel = true
			skidding = false
			ducking = false
			if $StandWindow.is_colliding() and state != "small": ducking = true

func hitbox(delta):
	# Hitboxes
	if ducking or state == "small" or player_state == "Sliding":
		$Hitbox.disabled = true
		$SmallHitbox.disabled = false
		$ShootLocation.position.y = 17
	else:
		$Hitbox.disabled = false
		$SmallHitbox.disabled = true
		$ShootLocation.position.y = 1
	$ShootLocation.position.x = $Control/AnimatedSprite.scale.x * 8
	
	# Buttjump hitboxes
	if $ButtjumpTimer.time_left == 0 and player_state == "Buttjump":
		$ButtjumpHitbox/CollisionShape2D.disabled = false
		$ButtjumpHitbox/CollisionShape2D.position.y = 0
		
		# Change the buttjump hitbox's size so it always collides before Tux hits the ground
		if velocity.y > 0:
			$ButtjumpHitbox/CollisionShape2D.position.y = (velocity.y * delta)
	else:
		$ButtjumpHitbox/CollisionShape2D.disabled = true
		$ButtjumpHitbox/CollisionShape2D.position.y = 0
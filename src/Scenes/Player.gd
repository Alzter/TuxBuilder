extends KinematicBody2D

# Instant speed when starting walk
const WALK_ADD = 120.0
# Speed Tux accelerates per second when walking
const WALK_ACCEL = 320.0
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
const SKID_TIME = 18

# Jump velocity
const JUMP_POWER = 565.0
# Running Jump / Backflip velocity
const RUNJUMP_POWER = 630.0
# Gravity
const GRAVITY = 20.0

const FLOOR = Vector2(0, -1)

var velocity = Vector2()
var on_ground = false
var jumpheld = 0 # Time the jump key has been held
var running = 0 # If horizontal speed is higher than walk max
var skid = 0 # Time skidding
var ducking = 0 # Ducking
var backflip = 0 # Backflipping
var backflip_rotation = 0 # Backflip rotation

var use_effect = true # For skidding sound effect

#=============================================================================
# PHYSICS

func _physics_process(delta):
	
	# Horizontal movement
	if Input.is_action_pressed("move_right") and (ducking == 0 or on_ground == false) and backflip == 0:
		$Animation.flip_h = false
		if skid <= 0 and velocity.x >= 0:
			if velocity.x == 0:
				velocity.x += WALK_ADD
			if running == 1:
					velocity.x += RUN_ACCEL / 60
			else: velocity.x += WALK_ACCEL / 60
			
			# Skidding and air turning
		if velocity.x < 0:
			if on_ground == true:
				velocity.x += SKID_ACCEL / 60
				if skid == 0 and velocity.x <= -WALK_MAX:
					skid = SKID_TIME
			else: velocity.x += TURN_ACCEL / 60
		
	else: if Input.is_action_pressed("move_left") and (ducking == 0 or on_ground == false) and backflip == 0:
		$Animation.flip_h = true
		if skid <= 0 and velocity.x <= 0:
			if velocity.x == 0:
				velocity.x -= WALK_ADD
			if running == 1:
					velocity.x -= RUN_ACCEL / 60
			else: velocity.x -= WALK_ACCEL / 60
			
		# Skidding and air turning
		if velocity.x > 0:
			if on_ground == true:
				velocity.x -= SKID_ACCEL / 60
				if skid == 0 and velocity.x >= WALK_MAX:
					skid = SKID_TIME
			else: velocity.x -= TURN_ACCEL / 60
		
	else: if backflip == 0: velocity.x *= FRICTION
	
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
		skid -= 1
		if use_effect == true:
			$SFX/Skid.play()
			use_effect = false
	else:
		skid = 0
		use_effect = true
	
	# Gravity
	velocity.y += GRAVITY
	
	velocity = move_and_slide(velocity, FLOOR)
	
	# Floor check
	if is_on_floor():
		on_ground = true
		if backflip == 1:
			backflip = 0
			velocity.x = 0
	else:
		on_ground = false
	
	# Running
	if abs(velocity.x) > WALK_MAX:
		running = 1
	else: running = 0
	
	# Ducking
	if not Input.is_action_pressed("duck"):
		ducking = 0
	if on_ground == true and Input.is_action_pressed("duck"):
			ducking = 1
	
	# Jump buffering
	if Input.is_action_pressed("jump"):
			jumpheld += 1
	else:
			jumpheld = 0
	
	# Jumping
	if Input.is_action_pressed("jump"):
		if jumpheld <= 15:
			if on_ground == true:
				if running == 1 or ducking == 1:
					velocity.y = -RUNJUMP_POWER
					if ducking == 1 and abs(velocity.x) <= 20:
						backflip = 1
						backflip_rotation = 0
						$SFX/Flip.play()
					else:
						$SFX/Jump.play()
				else: 
					velocity.y = -JUMP_POWER
					$SFX/Jump.play()
				on_ground = false
	
	# Jump cancelling
	if on_ground == false and not Input.is_action_pressed("jump") and backflip == 0:
		if velocity.y < 0:
			velocity.y *= 0.7
	
	# Backflip speed and rotation
	$Animation.rotation_degrees = 0
	if backflip == 1:
		if $Animation.flip_h == false:
			velocity.x = BACKFLIP_SPEED
			backflip_rotation -= 15
		else:
			velocity.x = -BACKFLIP_SPEED
			backflip_rotation += 15
		$Animation.rotation_degrees = backflip_rotation
	
	# Animations
	if backflip == 1:
		$Animation.play("backflip")
	elif ducking == 1:
		$Animation.play("duck")
	else:
		if on_ground == true:
			if skid > 0:
				$Animation.play("skid")
			else: if abs(velocity.x) >= 20:
				$Animation.play("walk")
			else: $Animation.play("idle")
		else: $Animation.play("jump")
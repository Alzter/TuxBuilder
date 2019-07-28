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

# Acceleration when holding the opposite direction
const TURN_ACCEL = 900.0
# Speed which Tux slows down
const FRICTION = 0.93
# Speed Tux slows down skidding
const SKID_TIME = 18
# Jump velocity
const JUMP_POWER = 555.0
# Gravity
const GRAVITY = 20.0

const FLOOR = Vector2(0, -1)

var velocity = Vector2()
var on_ground = false
var jumpheld = 0 # Time the jump key has been held
var skid = 0 # Time skidding

#=============================================================================
# PHYSICS

func _physics_process(delta):
	
	# Horizontal movement
	if Input.is_action_pressed("move_right") and not Input.is_action_pressed("duck"):
		$Animation.flip_h = false
		if skid <= 0 and velocity.x >= 0:
			if velocity.x == 0:
				velocity.x += WALK_ADD
			if velocity.x >= WALK_MAX:
					velocity.x += RUN_ACCEL / 60
			else: velocity.x += WALK_ACCEL / 60
			
			# Skidding and air turning
		if velocity.x < 0:
			velocity.x += TURN_ACCEL / 60
			if on_ground == true and skid == 0 and velocity.x <= WALK_MAX:
				skid = SKID_TIME
		
	else: if Input.is_action_pressed("move_left") and not Input.is_action_pressed("duck"):
		$Animation.flip_h = true
		if skid <= 0 and velocity.x <= 0:
			if velocity.x == 0:
				velocity.x -= WALK_ADD
			if velocity.x <= -WALK_MAX:
					velocity.x -= RUN_ACCEL / 60
			else: velocity.x -= WALK_ACCEL / 60
			
		# Skidding and air turning
		if velocity.x > 0:
			velocity.x -= TURN_ACCEL / 60
			if on_ground == true and skid == 0 and velocity.x >= WALK_MAX:
				skid = SKID_TIME
		
	else: velocity.x *= FRICTION
	
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
	else: skid = 0
	
	# Gravity
	velocity.y += GRAVITY
	
	# Floor check
	if is_on_floor():
		on_ground = true
	else:
		on_ground = false
	
	velocity = move_and_slide(velocity, FLOOR)
	
		# Animations
	if Input.is_action_pressed("duck"):
		$Animation.play("duck")
	else:
		if on_ground == true:
			if skid > 0:
				$Animation.play("skid")
			else: if abs(velocity.x) >= 20:
				$Animation.play("walk")
			else: $Animation.play("idle")
		else: $Animation.play("jump")
	
	# Jump buffering
	if Input.is_action_pressed("jump"):
			jumpheld += 1
	else:
			jumpheld = 0
	
	# Jumping
	if Input.is_action_pressed("jump"):
		if jumpheld <= 15:
			if on_ground == true:
				velocity.y = -JUMP_POWER
				on_ground = false
	
	# Jump cancelling
	if on_ground == false and not Input.is_action_pressed("jump"):
		if velocity.y < 0:
			velocity.y *= 0.7
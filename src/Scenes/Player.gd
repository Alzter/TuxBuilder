extends KinematicBody2D

# Instant speed when starting walk
const WALK_SPEED = 100
# Horizontal acceleration when walking
const WALK_ACCEL = 300
# Max speed when walking
const WALK_MAX = 230
# Instant speed when starting run
const RUN_SPEED = 80
# Horizontal acceleration when running
const RUN_ACCEL = 400
# Max speed when running
const RUN_MAX = 320
# Speed which Tux slows down
const FRICTION = 0.9
# Jump velocity
const JUMP_POWER = 555
# Gravity
const GRAVITY = 20

const FLOOR = Vector2(0, -1)

var velocity = Vector2() 
var on_ground = false
var jumpheld = 0 # Time the jump key has been held
var running = false # Is Tux running

#=============================================================================
# PHYSICS

func _physics_process(delta):
	
	# Horizontal movement
	if Input.is_action_pressed("move_right"):
		if velocity.x == 0:
			if on_ground == true:
				velocity.x += WALK_SPEED
		velocity.x += WALK_ACCEL
	else:
		if Input.is_action_pressed("move_left"):
			if velocity.x == 0:
				if on_ground == true:
					velocity.x -= WALK_SPEED
			velocity.x -= WALK_ACCEL
		else:
			velocity.x *= FRICTION
	
	# Walk to run
	if velocity.x >= WALK_MAX:
		running = true
		velocity.x += RUN_SPEED
	else:
		running = false
	if velocity.x <= -WALK_MAX:
		running = true
		velocity.x -= -RUN_SPEED
	else:
		running = false
	
	# Speedcap
	if velocity.x >= WALK_MAX:
		velocity.x = WALK_MAX
	if velocity.x <= -WALK_MAX:
		velocity.x = -WALK_MAX
	
	if velocity.x >= RUN_MAX:
		velocity.x = RUN_MAX
	if velocity.x <= -RUN_MAX:
		velocity.x = -RUN_MAX
	
	# Don't slide on the ground
	if abs(velocity.x) < 50:
		velocity.x = 0
	
	# Gravity
	velocity.y += GRAVITY
	
	# Floor check
	if is_on_floor():
		on_ground = true
	else:
		on_ground = false
	
	velocity = move_and_slide(velocity, FLOOR)
	
		# Animations
	if on_ground == true:
		if abs(velocity.x) >= 20:
			$Animation.play("walk")
		else:
			$Animation.play("idle")
	else:
		$Animation.play("jump")
	
	# Directions
	if abs(velocity.x) >= 5:
		if velocity.x > 0:
			$Animation.flip_h = false
		else:
			$Animation.flip_h = true
	
	# Jump buffering
	if Input.is_action_pressed("jump"):
			jumpheld += 1
	else:
			jumpheld = 0
	
	if Input.is_action_pressed("jump"):
		if jumpheld <= 15:
			if on_ground == true:
				velocity.y = -JUMP_POWER
				on_ground = false
	
	# Jump cancelling
	if on_ground == false and not Input.is_action_pressed("jump"):
		if velocity.y < 0:
			velocity.y *= 0.8
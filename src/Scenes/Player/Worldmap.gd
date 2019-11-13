extends Node2D

var dead = false
var state = "big"
var moving = false
var direction = null
var newdirection = null
var directionbuffer = 0
var level_passable = false # If the level dot you're standing on has been cleared (is true if you're not standing on one)
var movedirection = null # Direction you moved onto a level dot (so you can't pass uncleared levels)
var can_move = true

const MOVE_SPEED = 4 # Must be a power of 2 that's lower than 32
const BUFFER = 3 # If you press a direction, Tux will turn if he finds an intersection in that direction within the next 2 tiles

func _ready():
	position = Vector2(0,0)
	for child in get_tree().current_scene.get_node("Level").get_children():
		if child.is_in_group("spawnpoint"):
			position = child.position
	
	# The player needs to be on a grid space to move
	var rndx = (floor(position.x / 32) * 32) + 16
	var rndy = (floor(position.y / 32) * 32) + 16
	position = Vector2(rndx,rndy) 

func _process(delta):
	if UIHelpers._get_scene().editmode or !can_move:
		return
	
	# Setting the direction to move
	if !moving: newdirection = null
	if Input.is_action_pressed("up"):
		newdirection = 0
	
	if Input.is_action_pressed("duck"):
		newdirection = 180
	
	if Input.is_action_pressed("move_left"):
		newdirection = -90
	
	if Input.is_action_pressed("move_right"):
		newdirection = 90
	
	var rndx = (floor(position.x / 32) * 32) + 16
	var rndy = (floor(position.y / 32) * 32) + 16
	
	# Stop at level dots
	level_passable = true
	movedirection = null
	for child in UIHelpers.get_level().get_children():
		if child.is_in_group("leveldot"):
			if child.position == position:
				if moving:
					if direction != null:
						child.movedirection = direction
					moving = false
					newdirection = null
					directionbuffer = 0
				movedirection = child.movedirection
				level_passable = child.cleared
	
	# Change direction from the grid
	if position.x == rndx and position.y == rndy:
		for child in UIHelpers.get_level().get_children():
			if child.is_in_group("tilemap"):
				var playerpos = child.world_to_map(UIHelpers.get_player().position)
				var tile_id = child.get_cellv(playerpos)
				if tile_id != null and tile_id != -1:
					var tile_name = child.get_tileset().tile_get_name(tile_id)
					
					if tile_name == "Pathing":
						var tile_pos = child.get_cell_autotile_coord(playerpos.x, playerpos.y)
						var bitmask = child.get_tileset().autotile_get_bitmask(tile_id, tile_pos)
						var up_tiles = [186, 146, 18, 58, 178, 154, 50, 26]
						var down_tiles = [186, 146, 176, 152, 184, 178, 154, 144]
						var left_tiles = [186, 56, 152, 26, 154, 58, 184, 24]
						var right_tiles = [186, 56, 178, 58, 184, 48, 50, 176]
						
						# Move regularly
						if newdirection == 0 and bitmask in up_tiles:
							moving = true
							direction = newdirection
							directionbuffer = BUFFER
						elif newdirection == 180 and bitmask in down_tiles:
							moving = true
							direction = newdirection
							directionbuffer = BUFFER
						elif newdirection == 90 and bitmask in right_tiles:
							moving = true
							direction = newdirection
							directionbuffer = BUFFER
						elif newdirection == -90 and bitmask in left_tiles:
							moving = true
							direction = newdirection
							directionbuffer = BUFFER
						else:
							directionbuffer -= 1
							if directionbuffer <= 0:
								newdirection = null
								directionbuffer = 0
						
						# Turn on corner tiles
						if bitmask == 176: # Bottom Right
							if direction == 0:
								direction = 90
								newdirection = direction
							if direction == -90:
								direction = 180
								newdirection = direction
						elif bitmask == 152: # Bottom Left
							if direction == 0:
								direction = -90
								newdirection = direction
							if direction == 90:
								direction = 180
								newdirection = direction
						elif bitmask == 50: # Top Right
							if direction == -90:
								direction = 0
								newdirection = direction
							if direction == 180:
								direction = 90
								newdirection = direction
						elif bitmask == 26: # Top Left
							if direction == 90:
								direction = 0
								newdirection = direction
							if direction == 180:
								direction = -90
								newdirection = direction
						
						# Stop at edges or when trying to pass uncleared level dots
						if direction == 0 and (not bitmask in up_tiles or (!level_passable and movedirection != 180)):
							moving = false
						if direction == 180 and (not bitmask in down_tiles or (!level_passable and movedirection != 0)):
							moving = false
						if direction == 90 and (not bitmask in right_tiles or (!level_passable and movedirection != -90)):
							moving = false
						if direction == -90 and (not bitmask in left_tiles or (!level_passable and movedirection != 90)):
							moving = false
	
	# Move
	if moving:
		position += Vector2(MOVE_SPEED, 0).rotated(deg2rad(direction - 90))
	
	# Camera
	UIHelpers.get_camera().position = position
	UIHelpers.get_camera().align()
	
	# Animations
	if moving:
		set_animation("walk")
	else: set_animation("idle")

# Set Tux's current playing animation
func set_animation(anim):
	if state == "small": $Control/AnimatedSprite.play(str(anim, "_small"))
	else: $Control/AnimatedSprite.play(anim)
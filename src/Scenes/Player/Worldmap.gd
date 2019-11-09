extends Node2D

var dead = false
var state = "big"
var moving = false
var direction = 180
var newdirection = 180

const MOVE_SPEED = 8

func _ready():
	position = Vector2(0,0)
	for child in get_tree().current_scene.get_node("Level").get_children():
		if child.is_in_group("spawnpoint"):
			position = child.position

func _process(delta):
	if UIHelpers._get_scene().editmode:
		pass#return
	
	# Setting the direction to move
	if Input.is_action_just_pressed("up"):
		newdirection = 0
	
	if Input.is_action_just_pressed("duck"):
		newdirection = 180
	
	if Input.is_action_just_pressed("move_left"):
		newdirection = -90
	
	if Input.is_action_just_pressed("move_right"):
		newdirection = 90
	
	var rndx = (floor(position.x / 32) * 32) + 16
	var rndy = (floor(position.x / 32) * 32) + 16
	
	# Change direction from the grid
	if true:#position.x == rndx and position.y == rndy:
		for child in UIHelpers.get_level().get_children():
			if child.is_in_group("tilemap"):
				var playerpos = child.world_to_map(UIHelpers.get_player().position)
				var tile_id = child.get_cellv(playerpos)
				var tile_name = child.get_tileset().tile_get_name(tile_id)
				
				if tile_name == "Pathing":
					var tile_pos = child.get_cell_autotile_coord(playerpos.x, playerpos.y)
					var bitmask = child.get_tileset().autotile_get_bitmask(tile_id, tile_pos)
					print(bitmask)
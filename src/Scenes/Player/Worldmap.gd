extends Node2D

var dead = false
var state = "big"
var moving = false
var direction = 180

const MOVE_SPEED = 8

func _ready():
	position = Vector2(0,0)
	for child in get_tree().current_scene.get_node("Level").get_children():
		if child.is_in_group("spawnpoint"):
			position = child.position

func _process(delta):
	if UIHelpers._get_scene().editmode:
		return
	
	# Setting the direction to move
	if Input.is_action_just_pressed("up"):
		moving = true
		direction = 0
	
	if Input.is_action_just_pressed("duck"):
		moving = true
		direction = 180
	
	if Input.is_action_just_pressed("move_left"):
		moving = true
		direction = -90
	
	if Input.is_action_just_pressed("move_right"):
		moving = true
		direction = 90
	
	# Moving across the path
	if moving:
		for child in UIHelpers.get_level().get_children():
			if child.is_in_group("tilemap"):
				var playerpos = child.world_to_map(UIHelpers.get_player().position)
				var tile_id = child.get_cellv(playerpos)
				var tile_name = child.get_tileset().tile_get_name(tile_id)
				
				if tile_name == "Pathing":
					var tile_pos = child.get_cell_autotile_coord(playerpos.x, playerpos.y)
					
					var up_tiles = []
					var down_tiles = [Vector2(2,0), Vector2(3,0), Vector2(3,1), Vector2(3,2), Vector2(2,3)]
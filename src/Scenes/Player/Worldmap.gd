extends Node2D

var dead = false
var state = "big"
var moving = false

func _ready():
	position = Vector2(0,0)
	for child in get_tree().current_scene.get_node("Level").get_children():
		if child.is_in_group("spawnpoint"):
			position = child.position

func _process(delta):
	if UIHelpers._get_scene().editmode:
		return
	
	for child in UIHelpers.get_level().get_children():
		if child.is_in_group("tilemap"):
			var playerpos = child.world_to_map(UIHelpers.get_player().position)
			var tile_id = child.get_cellv(playerpos)
			var tile_name = child.get_tileset().tile_get_name(tile_id)
			if tile_name == "Pathing":
				pass
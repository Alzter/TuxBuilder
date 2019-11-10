extends Control

var tile_type = ""
var tileset = null

# Called when the node enters the scene tree for the first time.
func _ready():
	if UIHelpers.get_level().worldmap:
		tileset = UIHelpers.get_editor().get_node("WorldMap")
	else:
		tileset = UIHelpers.get_editor().get_node("TileMap")
	
	# Get the tile from the TileMap
	tile_type = tileset.get_tileset().find_tile_by_name(str(tile_type))
	
	# Then set the texture to the tile
	var selected_texture = tileset.get_tileset().tile_get_texture(tile_type)
	$Control/Sprite.texture = (selected_texture)
	if tileset.get_tileset().tile_get_tile_mode(tile_type) == 1:
		$Control/Sprite.region_rect.position = tileset.get_tileset().autotile_get_icon_coordinate(tile_type) * 32
	else: $Control/Sprite.region_rect.position = tileset.get_tileset().tile_get_region(tile_type).position

func _on_Button_pressed():
	UIHelpers.get_editor().tile_type = tile_type
	UIHelpers.get_editor().get_node("UI/SideBar/VBoxContainer/HBoxContainer/EraserButton").pressed = false
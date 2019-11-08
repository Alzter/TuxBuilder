extends "EditorBase.gd"

var tile_type = ""
var tileset = null

# Called when the node enters the scene tree for the first time.
func _ready():
	if UIHelpers.get_level().worldmap:
		tileset = UIHelpers._get_scene().get_node("Editor/WorldMap")
	else:
		tileset = UIHelpers._get_scene().get_node("Editor/TileMap")
	
	# Get the tile from the TileMap
	tile_type = tileset.get_tileset().find_tile_by_name(str(tile_type))
	
	# Then set the texture to the tile
	var selected_texture = tileset.get_tileset().tile_get_texture(tile_type)
	$Control/Sprite.texture = (selected_texture)
	$Control/Sprite.region_rect.position = tileset.get_tileset().autotile_get_icon_coordinate(tile_type) * 32

func _on_Button_pressed():
	get_editor().tile_type = tile_type
	get_tree().current_scene.get_node("Editor/UI/SideBar/VBoxContainer/HBoxContainer/EraserButton").pressed = false
extends Control

var tile_type = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	# Get the tile from the TileMap
	tile_type = get_tree().current_scene.get_node("Editor/TileMap").get_tileset().find_tile_by_name(str(tile_type))
	
	# Then set the texture to the tile
	var selected_texture = get_tree().current_scene.get_node("Editor/TileMap").get_tileset().tile_get_texture(tile_type)
	$Control/Sprite.texture = (selected_texture)
	$Control/Sprite.region_rect.position = get_tree().current_scene.get_node("Editor/TileMap").get_tileset().autotile_get_icon_coordinate(tile_type) * 128

func _on_Button_pressed():
	get_tree().current_scene.get_node("Editor").tile_type = tile_type
	get_tree().current_scene.get_node("Editor/UI/SideBar/VBoxContainer/HBoxContainer/EraserButton").pressed = false
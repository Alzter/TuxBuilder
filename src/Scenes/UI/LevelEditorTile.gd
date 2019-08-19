extends Node2D

var tile_type = ""
var tilemap_selected = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	tile_type = get_tree().current_scene.get_node(str("Level/", tilemap_selected)).get_tileset().find_tile_by_name(str(tile_type))
	
	var selected_texture = get_tree().current_scene.get_node(str("Level/", tilemap_selected)).get_tileset().tile_get_texture(0)
	$Control/Sprite.texture = (selected_texture)
	$Control/Sprite.region_rect.position = get_tree().current_scene.get_node(str("Level/", tilemap_selected)).get_tileset().autotile_get_icon_coordinate(tile_type) * get_tree().current_scene.get_node(str("Level/", tilemap_selected)).cell_size

func _on_Button_pressed():
	get_tree().current_scene.get_node("Editor").tile_type = tile_type
	get_tree().current_scene.get_node("Editor/UI/SideBar/VBoxContainer/HBoxContainer/EraserButton").pressed = false
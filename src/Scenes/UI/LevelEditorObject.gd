extends Control

var object_type = ""
var object_category = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	var selected_texture = load(str("res://Scenes/", object_category, "/", object_type, ".tscn")).instance().get_node("AnimatedSprite").get_sprite_frames().get_frame("default",0)
	$Control/Sprite.texture = (selected_texture)
	

func _on_Button_pressed():
	get_tree().current_scene.get_node("Editor").object_type = object_type
	get_tree().current_scene.get_node("Editor").object_category = object_category
	get_tree().current_scene.get_node("Editor/UI/SideBar/VBoxContainer/HBoxContainer/EraserButton").pressed = false
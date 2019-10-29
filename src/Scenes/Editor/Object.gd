extends Control

var object_type = ""
var object_category = ""
var object_location = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	get_object_texture(str("res://Scenes/Objects/", object_category, "/", object_type))

func _on_Button_pressed():
	get_tree().current_scene.get_node("Editor").object_type = object_type
	get_tree().current_scene.get_node("Editor").object_category = object_category
	get_tree().current_scene.get_node("Editor/UI/SideBar/VBoxContainer/HBoxContainer/EraserButton").pressed = false

func get_object_texture(object_location):
	$Control/Sprite.scale = Vector2(0.25,0.25)
	$Control/Sprite.position = Vector2(16,16)
	
	# If the object has an animated sprite, set the thumbnail to that
	if load(object_location).instance().has_node("Control/AnimatedSprite"):
		var selected_texture = load(object_location).instance().get_node("Control/AnimatedSprite").get_sprite_frames().get_frame("default",0)
		$Control/Sprite.scale = load(object_location).instance().get_node("Control").scale
		$Control/Sprite.position += load(object_location).instance().get_node("Control/AnimatedSprite").offset
		$Control/Sprite.position += load(object_location).instance().get_node("Control/AnimatedSprite").position
		$Control/Sprite.texture = (selected_texture)
	
	# If the object has an animated sprite, set the thumbnail to that
	elif load(object_location).instance().has_node("AnimatedSprite"):
		var selected_texture = load(object_location).instance().get_node("AnimatedSprite").get_sprite_frames().get_frame("default",0)
		$Control/Sprite.scale = load(object_location).instance().get_node("AnimatedSprite").scale
		$Control/Sprite.position += load(object_location).instance().get_node("AnimatedSprite").offset
		$Control/Sprite.position += load(object_location).instance().get_node("AnimatedSprite").position
		$Control/Sprite.texture = (selected_texture)
	
	# Otherwise if it has a sprite, set the thumbnail to that
	elif load(object_location).instance().has_node("Sprite"):
		var selected_texture = load(object_location).instance().get_node("Sprite").texture
		$Control/Sprite.scale = load(object_location).instance().get_node("Sprite").scale
		$Control/Sprite.position += load(object_location).instance().get_node("Sprite").offset
		$Control/Sprite.position += load(object_location).instance().get_node("Sprite").position
		$Control/Sprite.texture = (selected_texture)
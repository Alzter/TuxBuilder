extends Node2D

export var scroll_speed = Vector2(1,1)
export var move_speed = Vector2()
export var moving = false
export var tint = Color(1,1,1,1)
export var filepath = ""
var move_pos = Vector2()
export var original_name = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	position = Vector2(0,0)
	
	modulate = tint
	
	# Hide unselected TileMaps if a TileMap is selected
	if get_tree().current_scene.editmode == true and get_class() == "TileMap":
		if get_tree().current_scene.get_node("Editor").layer_selected_type == "TileMap":
			if get_tree().current_scene.get_node("Editor").layer_selected != name:
				modulate *= Color(1,1,1,0.25)
	
	# Scrolling
	if scroll_speed.x != 1:
		position.x = UIHelpers.get_camera().position.x * (1 - scroll_speed.x)
	if scroll_speed.y != 1:
		position.y = UIHelpers.get_camera().position.y * (1 - scroll_speed.y)
	
	# Moving
	if moving and get_tree().current_scene.editmode == false:
		if move_speed.x != 0:
			move_pos.x += move_speed.x
		if move_speed.y != 0:
			move_pos.y += move_speed.y
	
	position += move_pos
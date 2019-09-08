extends Node2D

export var scroll_speed = Vector2(1,1)
export var move_speed = Vector2()
export var moving = false
export var filepath = ""
var move_pos = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	position = Vector2(0,0)
	
	# Scrolling
	if scroll_speed.x != 1:
		position.x = get_tree().current_scene.get_node("Camera2D").position.x * (1 - scroll_speed.x)
	if scroll_speed.y != 1:
		position.y = get_tree().current_scene.get_node("Camera2D").position.y * (1 - scroll_speed.y)
	
	# Moving
	if moving and get_tree().current_scene.editmode == false:
		if move_speed.x != 0:
			move_pos.x += move_speed.x
		if move_speed.y != 0:
			move_pos.y += move_speed.y
	
	position += move_pos
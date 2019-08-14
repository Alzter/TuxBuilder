extends Node2D

func _ready():
	$Grid.rect_size = Vector2(get_viewport().size.x + 32, get_viewport().size.y + 32)
	$Camera2D.current = true

func _process(delta):
	$Grid.rect_size = Vector2(get_viewport().size.x + 32, get_viewport().size.y + 32)
	$Grid.rect_position = Vector2($Camera2D.position.x - (get_viewport().size.x / 2), $Camera2D.position.y - (get_viewport().size.y / 2))
	$Grid.rect_position = Vector2(floor($Grid.rect_position.x / 32) * 32, floor($Grid.rect_position.y / 32) * 32)
	
	if Input.is_action_pressed("click_left"):
		pass
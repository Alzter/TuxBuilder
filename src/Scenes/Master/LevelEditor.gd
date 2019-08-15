extends Node2D

const CAMERA_MOVE_SPEED = 20
var tilemap_selected = "TileMap"
var tile_selected = Vector2(0,0)

func _ready():
	$Grid.visible = false
	
func _process(delta):
	$Grid.rect_size = Vector2(get_viewport().size.x + 32, get_viewport().size.y + 32)
	$Grid.rect_position = Vector2(get_tree().current_scene.get_node("Camera2D").position.x - (get_viewport().size.x / 2), get_tree().current_scene.get_node("Camera2D").position.y - (get_viewport().size.y / 2))
	$Grid.rect_position = Vector2(floor($Grid.rect_position.x / 32) * 32, floor($Grid.rect_position.y / 32) * 32)
	$Grid.visible = true

	if Input.is_action_pressed("click_left"):
		var tile_selected = get_tree().current_scene.get_node(str("Level/", tilemap_selected)).world_to_map(get_global_mouse_position())
		get_tree().current_scene.get_node(str("Level/", tilemap_selected)).set_cellv(tile_selected, 0)
		get_tree().current_scene.get_node(str("Level/", tilemap_selected)).update_bitmask_region(Vector2(1,1))
	
	if Input.is_action_pressed("up"):
		get_tree().current_scene.get_node("Camera2D").position.y -= CAMERA_MOVE_SPEED
		
	if Input.is_action_pressed("duck"):
		get_tree().current_scene.get_node("Camera2D").position.y += CAMERA_MOVE_SPEED
		
	if Input.is_action_pressed("move_left"):
		get_tree().current_scene.get_node("Camera2D").position.x -= CAMERA_MOVE_SPEED
		
	if Input.is_action_pressed("move_right"):
		get_tree().current_scene.get_node("Camera2D").position.x += CAMERA_MOVE_SPEED
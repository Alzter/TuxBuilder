extends TileMap

var grid_x = 0
var grid_y = 0
var mouse_pos = Vector2(0,0)

func _process(delta):
	mouse_pos = get_local_mouse_position()
	grid_x = floor(mouse_pos.x / get_cell_size().x) * get_cell_size().x + (get_cell_size().x / 2)
	grid_y = floor(mouse_pos.y / get_cell_size().y) * get_cell_size().y + (get_cell_size().y / 2)
	
	if Input.is_action_just_pressed("click_left"):
		set_cell(grid_x,grid_y,1)
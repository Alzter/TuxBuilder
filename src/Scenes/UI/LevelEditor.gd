extends Node2D

const CAMERA_MOVE_SPEED = 32
var category_selected = "Tiles"
var tilemap_selected = "TileMap"
var tile_type = 0
var tile_selected = Vector2(0,0)
var old_tile_selected = Vector2(0,0)
var mouse_down = false
var anim_in = false

func _ready():
	anim_in = get_tree().current_scene.editmode
	visible = false
	$UI.offset = Vector2(get_viewport().size.x * 9999,get_viewport().size.y * 9999)
	$UI/SideBar/VBoxContainer/TilesButton.grab_focus()
	populate_lists()

func _process(delta):
	$UI/SideBar/VBoxContainer/TilesButton.text = ""
	$UI/SideBar/VBoxContainer/ObjectsButton.text = ""
	$Grid.rect_size = Vector2(get_viewport().size.x + 32, get_viewport().size.y + 32)
	$Grid.rect_position = Vector2(get_tree().current_scene.get_node("Camera2D").position.x - (get_viewport().size.x / 2), get_tree().current_scene.get_node("Camera2D").position.y - (get_viewport().size.y / 2))
	$Grid.rect_position = Vector2(floor($Grid.rect_position.x / 32) * 32, floor($Grid.rect_position.y / 32) * 32)
	
	if get_tree().current_scene.editmode == false:
		# Move out animation
		if anim_in == true:
			anim_in = false
			$UI/AnimationPlayer.play("MoveOut")
		if $UI/AnimationPlayer.current_animation != "MoveOut":
			visible = false
			$UI.offset = Vector2 (get_viewport().size.x * 9999,get_viewport().size.y * 9999)
			return
	else:
		# Move in animation
		if anim_in == false:
			anim_in = true
			$UI/AnimationPlayer.play("MoveIn")
		visible = true
		$UI.offset = Vector2(0,0)
		
	# Navigation
	if Input.is_action_pressed("ui_up"):
		get_tree().current_scene.get_node("Camera2D").position.y -= CAMERA_MOVE_SPEED
		
	if Input.is_action_pressed("ui_down"):
		get_tree().current_scene.get_node("Camera2D").position.y += CAMERA_MOVE_SPEED
		
	if Input.is_action_pressed("ui_left"):
		get_tree().current_scene.get_node("Camera2D").position.x -= CAMERA_MOVE_SPEED
		
	if Input.is_action_pressed("ui_right"):
		get_tree().current_scene.get_node("Camera2D").position.x += CAMERA_MOVE_SPEED
	
	# Placing tiles
	tile_selected = get_tree().current_scene.get_node(str("Level/", tilemap_selected)).world_to_map(get_global_mouse_position())
	update_selected_tile()
	if Input.is_action_pressed("click_left"):
		if get_viewport().get_mouse_position().x < get_viewport().size.x - 128 and get_viewport().get_mouse_position().y < get_viewport().size.y - 64:
			if tile_selected != old_tile_selected or mouse_down == false:
				if $UI/SideBar/VBoxContainer/HBoxContainer/EraserButton.pressed == true:
					get_tree().current_scene.get_node(str("Level/", tilemap_selected)).set_cellv(tile_selected, -1)
				else: get_tree().current_scene.get_node(str("Level/", tilemap_selected)).set_cellv(tile_selected, tile_type)
				get_tree().current_scene.get_node(str("Level/", tilemap_selected)).update_bitmask_area(tile_selected)
		mouse_down = true
	else: mouse_down = false
	old_tile_selected = tile_selected

func update_selected_tile():
	$SelectedTile.visible = true
	if get_viewport().get_mouse_position().x < get_viewport().size.x - 128 and get_viewport().get_mouse_position().y < get_viewport().size.y - 64:
		if $UI/SideBar/VBoxContainer/HBoxContainer/EraserButton.pressed == true:
			$SelectedTile.texture = load("res://Sprites/Editor/EraseSelect.png")
			$SelectedTile.region_rect = Rect2(0,0,32,32)
			$SelectedTile.modulate = Color(1,1,1,1)
			$EraserSprite.visible = true
		else:
			var selected_texture = get_tree().current_scene.get_node(str("Level/", tilemap_selected)).get_tileset().tile_get_texture(tile_type)
			$SelectedTile.texture = (selected_texture)
			$SelectedTile.region_rect.position = get_tree().current_scene.get_node(str("Level/", tilemap_selected)).get_tileset().autotile_get_icon_coordinate(tile_type) * get_tree().current_scene.get_node(str("Level/", tilemap_selected)).cell_size
			$SelectedTile.modulate = Color(1,1,1,0.25)
			$EraserSprite.visible = false
		$SelectedTile.position.x = (tile_selected.x + 0.5) * get_tree().current_scene.get_node(str("Level/", tilemap_selected)).cell_size.x
		$SelectedTile.position.y = (tile_selected.y + 0.5) * get_tree().current_scene.get_node(str("Level/", tilemap_selected)).cell_size.y
		$EraserSprite.position = $SelectedTile.position

# Buttons
func _on_TilesButton_pressed():
	category_selected = "Tiles"

func _on_ObjectsButton_pressed():
	category_selected = "Objects"

func populate_lists():
	var tilecategories = ["Ground","Blocks"]
	var groundtiles = ["Snow","Snow","Snow","Snow","Snow","Snow","Snow","Snow","Snow","Snow","Snow","Snow","Snow","Snow","Snow","Snow","Snow","Snow","Snow","Snow","Snow","Snow","Snow","Snow","Snow","Snow","Snow","Snow","Snow","Snow",]
	
	var objectcategories = ["BadGuys"]
	
	for i in range(0, tilecategories.size()):
		$UI/SideBar/VBoxContainer/TilesButton.add_item(tilecategories[i])
		var tilecategory = load("res://Scenes/UI/LevelEditorCategory.tscn").instance()
		tilecategory.item = tilecategories[i]
		$UI/SideBar/Panel/ScrollContainer/SidebarList.add_child(tilecategory)
		for i in range (0, groundtiles.size()): # Replace groundtiles with str(tilecategories[i] + "tiles")
			var tile = load("res://Scenes/UI/LevelEditorTile.tscn").instance()
			tile.tile_type = groundtiles[i] # Replace groundtiles with str(tilecategories[i] + "tiles")
			tile.tilemap_selected = tilemap_selected
			tilecategory.get_node("VBoxContainer/Content").add_child(tile)
		
	for i in range(0, objectcategories.size()):
		$UI/SideBar/VBoxContainer/ObjectsButton.add_item(objectcategories[i])
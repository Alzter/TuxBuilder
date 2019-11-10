extends Node2D

const CAMERA_MOVE_SPEED = 32
var category_selected = "Tiles"
var layer_selected = ""
var layer_selected_type = ""
var layerfile = null
var tile_type = 0
var tile_selected = Vector2(0,0)
var old_tile_selected = Vector2(0,0)
var object_category = ""
var object_type = ""
var old_object_type = ""
var mouse_down = false
var anim_in = false
var rect_start_pos = Vector2() # Where you started clicking for the rectangle select
var dragging_object = false
var dragpos = Vector2()
var object_dragged = ""
var movetime_up = 0
var movetime_down = 0
var movetime_left = 0
var movetime_right = 0
var player_drag_half = "bottom"
var player_hovered = false
var expanding = false
var expandingobject = ""
var expandingdir = ""
var expandpos = Vector2()
var stop = false
var dir = Directory.new()
var clickdisable = false
var tilemap = null

func _ready():
	if UIHelpers.get_level().worldmap: # Worldmap Tiles
		tilemap = $WorldMap
	else:
		tilemap = $TileMap # Level Tiles
	
	$GrabArea.offset = Vector2(9999999,99999999)
	$Settings/Popup/Panel/VBoxContainer/Name/LevelName.text = UIHelpers.get_level().level_name
	$Settings/Popup/Panel/VBoxContainer/Creator/LevelCreator.text = UIHelpers.get_level().level_creator
	$Settings/Popup/Panel/VBoxContainer/Music/OptionButton.clear()
	
	# Get all the files from Scenes/Editor/Layers
	var music = list_files_in_directory("res://Audio/Music/")
	for file in music:
		# If the file is a scene, add it to the OptionButton
		if ".ogg" in file and not ".import" in file:
			var item = file
			item.erase(item.length() - 4,4)
			$Settings/Popup/Panel/VBoxContainer/Music/OptionButton.add_item(item)
	
	anim_in = get_tree().current_scene.editmode
	visible = false
	$UI.offset = Vector2(get_viewport().size.x * 9999,get_viewport().size.y * 9999)
	$UI/SideBar/VBoxContainer/TilesButton.grab_focus()
	update_tiles()
	update_layers()
	select_first_solid_tilemap()

func _process(_delta):
	layerfile = get_tree().current_scene.get_node(str("Level/", layer_selected))
	if layerfile == null:
		layer_selected == ""
		layer_selected_type = ""
		print("ERROR! There is no level loaded!")
	
	if stop == true:
		$SelectedArea.visible = false
		$EraserSprite.visible = false
		$SelectedTile.visible = false
		return
	
	# General positioning stuff
	$UI/SideBar/VBoxContainer/TilesButton.text = ""
	$UI/SideBar/VBoxContainer/ObjectsButton.text = ""
	
	$Grid.rect_size = Vector2((get_viewport().size.x + 32) * 4 * UIHelpers.get_camera().zoom.x, (get_viewport().size.y + 32) * 4 * UIHelpers.get_camera().zoom.y)
	$Grid.rect_position = Vector2(UIHelpers.get_camera().position.x - (get_viewport().size.x / 2) * UIHelpers.get_camera().zoom.x, UIHelpers.get_camera().position.y - (get_viewport().size.y / 2) * UIHelpers.get_camera().zoom.y)
	$Grid.rect_position = Vector2(floor($Grid.rect_position.x / 32) * 32, floor($Grid.rect_position.y / 32) * 32)
	if layer_selected_type == "TileMap" and category_selected == "Tiles":
		$Grid.rect_position += Vector2(fmod(layerfile.position.x, 32),fmod(layerfile.position.y, 32))
	
	$UI/BottomBar/ScrollContainer/HBoxContainer.rect_min_size.y = 64
	$UI/BottomBar/ScrollContainer.rect_size.y = 64
	if $UI/BottomBar/ScrollContainer.rect_size.y != 64:
		$UI/BottomBar/ScrollContainer/HBoxContainer.rect_min_size.y = 52
		$UI/BottomBar/ScrollContainer.rect_size.y = 64
	
	# Show and hide
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
	
	
	# Editor settings menu
	if Input.is_action_just_pressed("pause") and !clickdisable:
		if $Settings/Popup.visible:
			$Settings/Popup.hide()
		else:
			$Settings/Popup.popup()
	
	if $Settings/Popup.visible or $Settings/Exit.visible or $UI/AddLayer.visible:
		$SelectedTile.visible = false
		clickdisable = true
		UIHelpers.get_level().level_name = $Settings/Popup/Panel/VBoxContainer/Name/LevelName.text
		UIHelpers.get_level().level_creator = $Settings/Popup/Panel/VBoxContainer/Creator/LevelCreator.text
		return
	
	# Navigation
	if Input.is_action_pressed("ui_up"):
		UIHelpers.get_camera().position.y -= CAMERA_MOVE_SPEED
		movetime_up += 1
	elif Input.is_action_just_released("ui_up"): movetime_up = -1
	else: movetime_up = 0
	
	if Input.is_action_pressed("ui_down"):
		UIHelpers.get_camera().position.y += CAMERA_MOVE_SPEED
		movetime_down += 1
	elif Input.is_action_just_released("ui_down"): movetime_down = -1
	else: movetime_down = 0
	
	if Input.is_action_pressed("ui_left"):
		UIHelpers.get_camera().position.x -= CAMERA_MOVE_SPEED
		movetime_left += 1
	elif Input.is_action_just_released("ui_left"): movetime_left = -1
	else: movetime_left = 0
	
	if Input.is_action_pressed("ui_right"):
		UIHelpers.get_camera().position.x += CAMERA_MOVE_SPEED
		movetime_right += 1
	elif Input.is_action_just_released("ui_right"): movetime_right = -1
	else: movetime_right = 0
	
	# Round player position
	UIHelpers.get_player().position.x = (floor(UIHelpers.get_player().position.x / 32) * 32) + 16
	if UIHelpers.get_level().worldmap:
		UIHelpers.get_player().position.y = (floor(UIHelpers.get_player().position.y / 32) * 32) + 16
	else:
		UIHelpers.get_player().position.y = round(UIHelpers.get_player().position.y / 32) * 32
	
	# Delay the player movement by one frame to sync with the camera
	if !UIHelpers.get_level().worldmap:
		if movetime_up != 1 and movetime_up != 0:
			UIHelpers.get_player().position.y -= CAMERA_MOVE_SPEED
		if movetime_down != 1 and movetime_down != 0:
			UIHelpers.get_player().position.y += CAMERA_MOVE_SPEED
		if movetime_left != 1 and movetime_left != 0:
			UIHelpers.get_player().position.x -= CAMERA_MOVE_SPEED
		if movetime_right != 1 and movetime_right != 0:
			UIHelpers.get_player().position.x += CAMERA_MOVE_SPEED
	
	# Disable rectangle select for objects
	if category_selected == "Objects":
		$UI/SideBar/VBoxContainer/HBoxContainer/SelectButton.disabled = true
		$UI/SideBar/VBoxContainer/HBoxContainer/SelectButton.pressed = false
		$UI/SideBar/VBoxContainer/HBoxContainer/SelectButton/TextureRect.self_modulate = Color(1,1,1,0.5)
	else:
		$UI/SideBar/VBoxContainer/HBoxContainer/SelectButton.disabled = false
		$UI/SideBar/VBoxContainer/HBoxContainer/SelectButton/TextureRect.self_modulate = Color(1,1,1,1)
	
	# Placing tiles / objects
	if layer_selected_type == "TileMap" and category_selected == "Tiles":
		tile_selected = layerfile.world_to_map(Vector2(get_global_mouse_position().x - ((1 - layerfile.scroll_speed.x) * UIHelpers.get_camera().position.x), get_global_mouse_position().y - ((1 - layerfile.scroll_speed.y) * UIHelpers.get_camera().position.y)))
	else: tile_selected = tilemap.world_to_map(get_global_mouse_position())
	update_selected_tile()
	
	# Click disable
	if not Input.is_action_pressed("click_left"):
		clickdisable = false
	
	# Drag the player
	if player_hovered and Input.is_action_just_pressed("click_left") and !dragging_object and !expanding:
		dragging_object = true
		object_dragged = "Player"
		dragpos = Vector2(0,0)
		UIHelpers.get_player().get_node("Control/AnimatedSprite").scale += Vector2(0.25,0.25)
		if $SelectedTile.position == Vector2(UIHelpers.get_player().position.x,UIHelpers.get_player().position.y - 16):
			player_drag_half = "top"
		else: player_drag_half = "bottom"
	
	var object_hovered = false
	# If clicking on a tile occupied by an object, pick up the object
	if !clickdisable and $UI/SideBar/VBoxContainer/HBoxContainer/EraserButton.pressed == false and !dragging_object and !expanding:
		for child in get_tree().current_scene.get_node("Level").get_children():
			if not child.is_in_group("layers") and not child.is_in_group("expandable"):
				if child.position == $SelectedTile.position:
						$SelectedTile.visible = false
						object_hovered = true
						if Input.is_action_just_pressed("click_left"):
							dragging_object = true
							object_dragged = child.get_name()
							child.scale += Vector2(0.25,0.25)
							dragpos = Vector2(0,0)
							return
						if Input.is_action_just_pressed("click_right") and child.is_in_group("popup"):
							child.get_node("CanvasLayer/Popup").popup()
							clickdisable = true
	
	# If clicking on an expandable area, drag it
	if !clickdisable and !object_hovered and not($GrabArea/C1.is_hovered()) and not($GrabArea/C2.is_hovered()) and not($GrabArea/C3.is_hovered()) and not($GrabArea/C4.is_hovered()) and $UI/SideBar/VBoxContainer/HBoxContainer/EraserButton.pressed == false and !dragging_object and !expanding:
		for child in get_tree().current_scene.get_node("Level").get_children():
			if child.is_in_group("expandable"):
				if $SelectedTile.position.x >= child.position.x and $SelectedTile.position.y >= child.position.y and $SelectedTile.position.x <= child.position.x + (child.get_node("Control").rect_size.x - 32) and $SelectedTile.position.y <= child.position.y + (child.get_node("Control").rect_size.y - 32):
					$SelectedTile.visible = false
					object_hovered = true
					if Input.is_action_just_pressed("click_right") and child.is_in_group("popup"):
						child.get_node("CanvasLayer/Popup").popup()
						clickdisable = true
					elif Input.is_action_just_pressed("click_left"):
						dragging_object = true
						object_dragged = child.get_name()
						dragpos = Vector2(child.position.x - $SelectedTile.position.x, child.position.y - $SelectedTile.position.y)
						return
	
	# Show expandable area buttons
	$GrabArea.offset = Vector2(9999999,99999999)
	if !clickdisable and UIHelpers._get_scene().editmode and $UI/SideBar/VBoxContainer/HBoxContainer/EraserButton.pressed == false and !dragging_object and !expanding:
		for child in get_tree().current_scene.get_node("Level").get_children():
			if child.is_in_group("expandable"):
				if child.is_in_group("popup"):
					if child.get_node("CanvasLayer/Popup").visible:
						object_hovered = true
						$SelectedTile.visible = false
						return
				if $SelectedTile.position.x >= child.position.x - 32 and $SelectedTile.position.y >= child.position.y - 32 and $SelectedTile.position.x <= child.position.x + (child.get_node("Control").rect_size.x - 32) + 32 and $SelectedTile.position.y <= child.position.y + (child.get_node("Control").rect_size.y - 32) + 32:
					$GrabArea/C1.rect_position = Vector2((child.position.x) - 16, (child.position.y) - 16)
					$GrabArea/C2.rect_position = Vector2((child.position.x + (child.get_node("Control").rect_size.x - 32) + 16), (child.position.y) - 16)
					$GrabArea/C3.rect_position = Vector2((child.position.x) - 16, (child.position.y + (child.get_node("Control").rect_size.y - 32) + 16))
					$GrabArea/C4.rect_position = Vector2((child.position.x + (child.get_node("Control").rect_size.x - 32) + 16), (child.position.y + (child.get_node("Control").rect_size.y - 32) + 16))
					$GrabArea.scale = Vector2(1,1) / UIHelpers.get_camera().zoom
					$GrabArea.offset = (UIHelpers.get_camera().position * -1 * $GrabArea.scale) - Vector2(get_viewport().size.x * -0.5, get_viewport().size.y * -0.5) - (Vector2(11,11) * $GrabArea.scale)
					if $GrabArea/C1.is_hovered() or $GrabArea/C2.is_hovered() or $GrabArea/C3.is_hovered() or $GrabArea/C4.is_hovered():
						$SelectedTile.visible = false
						object_hovered = true
					
					if $GrabArea/C1.pressed:
						expanding = true
						expandingobject = child.get_name()
						expandingdir = ""
						expandpos = Vector2(child.position.x + (child.get_node("Control").rect_size.x - 32), child.position.y + (child.get_node("Control").rect_size.y - 32))
					
					if $GrabArea/C2.pressed:
						expanding = true
						expandingobject = child.get_name()
						expandingdir = ""
						expandpos = Vector2(child.position.x, child.position.y + (child.get_node("Control").rect_size.y - 32))
						
					if $GrabArea/C3.pressed:
						expanding = true
						expandingobject = child.get_name()
						expandingdir = ""
						expandpos = Vector2(child.position.x + (child.get_node("Control").rect_size.x - 32), child.position.y)
					
					if $GrabArea/C4.pressed:
						expanding = true
						expandingobject = child.get_name()
						expandingdir = ""
						expandpos = Vector2(child.position.x, child.position.y)
						
	
	# Let go of dragged objects
	if not Input.is_action_pressed("click_left") and dragging_object == true:
		dragging_object = false
		$GrabSprite.visible = false
		if object_dragged != "Player":
			if not get_tree().current_scene.get_node(str("Level/", object_dragged)).is_in_group("expandable"):
				get_tree().current_scene.get_node(str("Level/", object_dragged)).scale -= Vector2(0.25,0.25)
			if not get_tree().current_scene.get_node(str("Level/", object_dragged)).is_in_group("stackable"):
				for child in get_tree().current_scene.get_node("Level").get_children():
					if child.position == $SelectedTile.position and child.get_name() != object_dragged and not child.is_in_group("stackable"):
						child.queue_free()
		else: UIHelpers.get_player().get_node("Control/AnimatedSprite").scale -= Vector2(0.25,0.25)
	
	# Drag the object
	if Input.is_action_pressed("click_left") and dragging_object == true:
		$SelectedTile.visible = false
		$GrabSprite.visible = true
		$GrabSprite.position = $SelectedTile.position
		if object_dragged != "Player":
			get_tree().current_scene.get_node(str("Level/", object_dragged)).position = $SelectedTile.position + dragpos
		else:
			UIHelpers.get_player().position = $SelectedTile.position
			if !UIHelpers.get_level().worldmap:
				if player_drag_half == "top":
					UIHelpers.get_player().position.y += 16
				else: UIHelpers.get_player().position.y -= 16

	# Expand resizable areas
	if expanding:
		var expobject = get_tree().current_scene.get_node(str("Level/", expandingobject))
		var expandposmap = tilemap.world_to_map(expandpos)
		if Input.is_action_pressed("click_left"):
			# Drag Horizontal
			if tilemap.world_to_map(get_global_mouse_position()).x >= expandposmap.x:
				expobject.position.x = expandpos.x
				expobject.get_node("Control").rect_size.x = ((tilemap.world_to_map(get_global_mouse_position()).x - expandposmap.x) * 32) + 32
			else:
				expobject.position.x = (tilemap.world_to_map(get_global_mouse_position()).x * 32) + 16
				expobject.get_node("Control").rect_size.x = ((expandposmap.x - tilemap.world_to_map(get_global_mouse_position()).x) * 32) + 32
			
			# Drag Vertical
			if tilemap.world_to_map(get_global_mouse_position()).y >= expandposmap.y:
				expobject.position.y = expandpos.y
				expobject.get_node("Control").rect_size.y = ((tilemap.world_to_map(get_global_mouse_position()).y - expandposmap.y) * 32) + 32
			else:
				expobject.position.y = (tilemap.world_to_map(get_global_mouse_position()).y * 32) + 16
				expobject.get_node("Control").rect_size.y = ((expandposmap.y - tilemap.world_to_map(get_global_mouse_position()).y) * 32) + 32
			
			expobject.boxsize.x = expobject.get_node("Control").rect_size.x
			expobject.boxsize.y = expobject.get_node("Control").rect_size.y
			
		else: expanding = false

	if Input.is_action_pressed("click_left") and !dragging_object and !expanding and !clickdisable:
		# If the mouse isn't on the level editor UI or zoom buttons
		if get_viewport().get_mouse_position().x < get_viewport().size.x - 128 and get_viewport().get_mouse_position().y < get_viewport().size.y - 64 and (tile_selected != old_tile_selected or mouse_down == false) and $UI/BottomBar/Zoom/ZoomIn.is_hovered() == false and $UI/BottomBar/Zoom/ZoomDefault.is_hovered() == false and $UI/BottomBar/Zoom/ZoomOut.is_hovered() == false:
			
			# Tile placing / erasing
			if category_selected == "Tiles":
				
				# Only works if the layer selected is a TileMap
				if layer_selected_type == "TileMap":
					
					# Rectangle Tile Placing / Erasing
					if $UI/SideBar/VBoxContainer/HBoxContainer/SelectButton.pressed:
						var startx = 0
						var endx = 0
						var starty = 0
						var endy = 0
						if tile_selected.x >= rect_start_pos.x:
							startx = rect_start_pos.x
							endx = tile_selected.x + 1
						else:
							endx = rect_start_pos.x + 1
							startx = tile_selected.x
						
						if tile_selected.y >= rect_start_pos.y:
							starty = rect_start_pos.y
							endy = tile_selected.y + 1
						else:
							endy = rect_start_pos.y + 1
							starty = tile_selected.y
						
						for i in range(startx, endx):
							for i2 in range(starty, endy):
								if $UI/SideBar/VBoxContainer/HBoxContainer/EraserButton.pressed:
									layerfile.set_cellv(Vector2(i,i2), -1)
								else:
									layerfile.set_cellv(Vector2(i,i2), tile_type)
						layerfile.update_bitmask_region(Vector2(startx,starty),Vector2(endx,endy))
					
					# Tile erasing
					elif $UI/SideBar/VBoxContainer/HBoxContainer/EraserButton.pressed:
						layerfile.set_cellv(tile_selected, -1)
						layerfile.update_bitmask_area(tile_selected)
					
					# Tile placing
					else:
						layerfile.set_cellv(tile_selected, tile_type)
						layerfile.update_bitmask_area(tile_selected)
			
			# Object placing / erasing
			else:
				
				# Object erasing (also happens when placing objects so they don't stack)
				var erasedobject = false
				for child in get_tree().current_scene.get_node("Level").get_children():
					if child.position == $SelectedTile.position and not child.is_in_group("expandable"):
						child.queue_free()
						erasedobject = true
				if !erasedobject:
					for child in get_tree().current_scene.get_node("Level").get_children():
						if child.is_in_group("expandable"):
							if $SelectedTile.position.x >= child.position.x and $SelectedTile.position.y >= child.position.y and $SelectedTile.position.x <= child.position.x + (child.get_node("Control").rect_size.x - 32) and $SelectedTile.position.y <= child.position.y + (child.get_node("Control").rect_size.y - 32):
								child.queue_free()
				
				# Object placing
				if $UI/SideBar/VBoxContainer/HBoxContainer/EraserButton.pressed == false and object_type != "":
					var object = load(str("res://Scenes/Objects/", object_category, "/", object_type)).instance()
					object.position = $SelectedTile.position
					get_tree().current_scene.get_node("Level").add_child(object)
					object.set_owner(get_tree().current_scene.get_node("Level"))
					
					var objectname = object_type
					objectname.erase(objectname.length() -5, 5)
					
					# If the object is in the group "oneonly", delete all other instances of it
					if object.is_in_group("oneonly"):
						object.set_name(objectname)
						for child in get_tree().current_scene.get_node("Level").get_children():
							if child.filename == object.filename and not child.is_in_group("layers"):
								if child.name != object.name: child.queue_free()
						object.set_name(objectname)
					
					# Resize expandable objects
					if object.is_in_group("expandable"):
						expanding = true
						expandingobject = object.get_name()
						expandingdir = ""
						expandpos = object.position
					
					# If the object isn't expandable drag it instead
					elif not Input.is_action_pressed("action") or object.is_in_group("oneonly"):
						dragging_object = true
						dragpos = Vector2(0,0)
						object_dragged = object.get_name()
						object.scale += Vector2(0.25,0.25)
		
		mouse_down = true
	else: mouse_down = false
	old_tile_selected = tile_selected

func update_selected_tile():
	$SelectedArea.visible = false
	$EraserSprite.visible = false
	$SelectedTile.visible = false
	$SelectedTile.scale = Vector2(1,1)
	$SelectedTile.region_rect.size = Vector2(32,32)
	$SelectedTile.centered = true
	$SelectedTile.region_enabled = false
	player_hovered = false
	
	if clickdisable or not (get_viewport().get_mouse_position().x < get_viewport().size.x - 128 and get_viewport().get_mouse_position().y < get_viewport().size.y - 64):
		if clickdisable:
			$SelectedTile.visible = false
		return
	
	if layer_selected_type != "TileMap" and category_selected == "Tiles":
		return
	
	if not ($UI/BottomBar/Zoom/ZoomIn.is_hovered() == false and $UI/BottomBar/Zoom/ZoomDefault.is_hovered() == false and $UI/BottomBar/Zoom/ZoomOut.is_hovered() == false):
		return
	
	if layer_selected_type == "TileMap" and category_selected == "Tiles":
		$SelectedTile.position.x = ((tile_selected.x + 0.5) * 32) + (UIHelpers.get_camera().position.x * (1 - layerfile.scroll_speed.x))
		$SelectedTile.position.y = ((tile_selected.y + 0.5) * 32) + (UIHelpers.get_camera().position.y * (1 - layerfile.scroll_speed.y))
	else:
		$SelectedTile.position.x = (tile_selected.x + 0.5) * 32
		$SelectedTile.position.y = (tile_selected.y + 0.5) * 32
	
	if UIHelpers.get_level().worldmap and ($SelectedTile.position == Vector2(UIHelpers.get_player().position.x,UIHelpers.get_player().position.y - 16) and UIHelpers.get_player().state != "small") or $SelectedTile.position == Vector2(UIHelpers.get_player().position.x,UIHelpers.get_player().position.y + 16) and dragging_object == false:
		player_hovered = true
		return
	if UIHelpers.get_level().worldmap and ($SelectedTile.position == Vector2(UIHelpers.get_player().position.x,UIHelpers.get_player().position.y)) and dragging_object == false:
		player_hovered = true
		return
	
	if dragging_object or expanding:
		return
	
	# Rectangle selection
	$SelectedArea.visible = false
	if $UI/SideBar/VBoxContainer/HBoxContainer/SelectButton.pressed == true and Input.is_action_pressed("click_left"):
		# Start rectangle selection
		if Input.is_action_just_pressed("click_left"):
			rect_start_pos = tile_selected
		
		$SelectedArea.rect_position.x = (rect_start_pos.x) * 32
		$SelectedArea.rect_position.y = (rect_start_pos.y) * 32
		$SelectedArea.rect_scale.x = (-1 * ($SelectedArea.rect_position.x - ($SelectedTile.position.x))) / 32
		$SelectedArea.rect_scale.y = (-1 * ($SelectedArea.rect_position.y - ($SelectedTile.position.y))) / 32
		$SelectedArea.rect_scale.x += 0.5 * ($SelectedArea.rect_scale.x / abs($SelectedArea.rect_scale.x))
		$SelectedArea.rect_scale.y += 0.5 * ($SelectedArea.rect_scale.y / abs($SelectedArea.rect_scale.y))
		if $SelectedArea.rect_scale.x < 0:
			$SelectedArea.rect_position.x += 32
			$SelectedArea.rect_scale.x -= 1
		if $SelectedArea.rect_scale.y < 0:
			$SelectedArea.rect_position.y += 32
			$SelectedArea.rect_scale.y -= 1
		$SelectedArea.visible = true
	
	# Eraser selection
	elif $UI/SideBar/VBoxContainer/HBoxContainer/EraserButton.pressed == true:
		$SelectedArea.color = Color(1,0,0,0.5)
		$EraserSprite.visible = true
		$SelectedTile.visible = true
		$SelectedTile.texture = load("res://Sprites/Editor/EraseSelect.png")
		$SelectedTile.scale = Vector2(0.25,0.25)
		$SelectedTile.region_enabled = false
		$SelectedTile.modulate = Color(1,1,1,1)
		$SelectedTile.offset = Vector2(0,0)
		$EraserSprite.position = $SelectedTile.position
		old_object_type = ""
	
	else:
		$SelectedArea.color = Color(0,1,0,0.5)
		$EraserSprite.visible = false
		$SelectedTile.visible = true
		$SelectedTile.modulate = Color(1,1,1,0.5)
		
		# Tile selection
		if category_selected == "Tiles":
			$SelectedTile.offset = Vector2(0,0)
			var selected_texture = tilemap.get_tileset().tile_get_texture(tile_type)
			$SelectedTile.texture = (selected_texture)
			if tilemap.get_tileset().tile_get_tile_mode(tile_type) == 1:
				$SelectedTile.region_rect.position = tilemap.get_tileset().autotile_get_icon_coordinate(tile_type) * 32
			else:
				$SelectedTile.region_rect.position = tilemap.get_tileset().tile_get_region(tile_type).position
				$SelectedTile.region_rect.size = tilemap.get_tileset().tile_get_region(tile_type).size
				$SelectedTile.centered = false
				$SelectedTile.offset = Vector2(-16,-16)
			$SelectedTile.region_enabled = true
			old_object_type = ""

		else:
			# Object Selection
			if object_type != old_object_type:
				get_object_texture(str("res://Scenes/Objects/", object_category, "/", object_type))
			old_object_type = object_type
			$SelectedTile.region_enabled = false

# Buttons
func _on_TilesButton_pressed():
	if category_selected != "Tiles":
		category_selected = "Tiles"
		for child in $UI/SideBar/ScrollContainer/SidebarList.get_children():
			child.queue_free()
		update_tiles()

func _on_ObjectsButton_pressed():
	if category_selected != "Objects":
		category_selected = "Objects"
		for child in $UI/SideBar/ScrollContainer/SidebarList.get_children():
			child.queue_free()
		update_objects()

func update_tiles():
	var child = load("res://Scenes/Editor/Category.tscn").instance()
	child.item = "Tiles"
	$UI/SideBar/ScrollContainer/SidebarList.add_child(child)
	
	var tiles = tilemap.get_tileset().get_tiles_ids()
	for i in tiles.size():
		var child2 = load("res://Scenes/Editor/Tile.tscn").instance()
		child2.tile_type = tilemap.get_tileset().tile_get_name(tiles[i])
		child.get_node("VBoxContainer/Content").add_child(child2)

func update_objects(): # Update the objects list from the editor using the scenes from Scenes/Objects
	# Delete existing children of the objects/tiles list
	for child in $UI/SideBar/ScrollContainer/SidebarList.get_children():
		child.queue_free()
	
	# Find all the folders in Scenes/Objects
	var categories = list_files_in_directory("res://Scenes/Objects/")
	
	# For every folder in Scenes/Objects
	for category in categories:
		if (category != "Map" and !UIHelpers.get_level().worldmap) or (category == "Map" and UIHelpers.get_level().worldmap): # Change category for Worldmaps
			
			# Create a category
			var child = load("res://Scenes/Editor/Category.tscn").instance()
			child.item = category
			$UI/SideBar/ScrollContainer/SidebarList.add_child(child)
			
			# Then for every file inside each folder
			var objects = list_files_in_directory(str("res://Scenes/Objects/", category, "/"))
			for object in objects:
				
				# If it's a scene, create an object button inside that category
				if ".tscn" in object:
					var child2 = load("res://Scenes/Editor/Object.tscn").instance()
					child2.object_category = category
					child2.object_type = object
					child.get_node("VBoxContainer/Content").add_child(child2)
					
					# Set the object selected to this object if none are selected
					if object_type == "":
						object_type = child2.object_type
						object_category = child2.object_category

func get_object_texture(object_location): # Get the texture for an object
	if object_type == "":
		return
	
	$SelectedTile.scale = Vector2(1,1)
	$SelectedTile.region_enabled = false
	$SelectedTile.offset = Vector2(0,0)
	
	# If the object has an animated sprite, set the thumbnail to that
	if load(object_location).instance().has_node("Control/AnimatedSprite"):
		var selected_texture = load(object_location).instance().get_node("Control/AnimatedSprite").get_sprite_frames().get_frame("default",0)
		$SelectedTile.scale = load(object_location).instance().get_node("Control").rect_scale
		$SelectedTile.offset += load(object_location).instance().get_node("Control/AnimatedSprite").offset
		$SelectedTile.offset += load(object_location).instance().get_node("Control/AnimatedSprite").position
		$SelectedTile.texture = (selected_texture)
	
	# If the object has an animated sprite, set the thumbnail to that
	if load(object_location).instance().has_node("AnimatedSprite"):
		var selected_texture = load(object_location).instance().get_node("AnimatedSprite").get_sprite_frames().get_frame("default",0)
		$SelectedTile.scale = load(object_location).instance().get_node("AnimatedSprite").scale
		$SelectedTile.offset += load(object_location).instance().get_node("AnimatedSprite").offset
		$SelectedTile.offset += load(object_location).instance().get_node("AnimatedSprite").position
		$SelectedTile.texture = (selected_texture)
	
	# Otherwise if it has a sprite, set the thumbnail to that
	elif load(object_location).instance().has_node("Sprite"):
		var selected_texture = load(object_location).instance().get_node("Sprite").texture
		$SelectedTile.scale = load(object_location).instance().get_node("Sprite").scale
		$SelectedTile.offset += load(object_location).instance().get_node("Sprite").offset
		$SelectedTile.offset += load(object_location).instance().get_node("Sprite").position
		$SelectedTile.texture = (selected_texture)

# Add all the layers from Scenes/Editor/Layers
func _on_LayerAdd_button_down():
	$UI/AddLayer/VBoxContainer/OptionButton.clear()
	
	# Get all the files from Scenes/Editor/Layers
	var layers = list_files_in_directory("res://Scenes/Editor/Layers/")
	if UIHelpers.get_level().worldmap:
		layers = list_files_in_directory("res://Scenes/Editor/Layers/Worldmap/") # Different layers for Worldmap editing
	var tilemappos = 0
	for layer in layers:
		# If the file is a scene, add it to the OptionButton
		if ".tscn" in layer:
			if "tilemap" in layer:
				tilemappos = $UI/AddLayer/VBoxContainer/OptionButton.items.size()
			var item = layer
			item.erase(item.length() - 5,5)
			$UI/AddLayer/VBoxContainer/OptionButton.add_icon_item(load(str("res://Sprites/Editor/LayerIcons/", item, ".png")),item)
	
	$UI/AddLayer.popup()
	$UI/AddLayer/VBoxContainer/OptionButton.selected = tilemappos

func _on_AddLayer_popup_hide():
	$UI/BottomBar/LayerAdd.pressed = false

func _on_LayerConfirmation_pressed():
	$UI/AddLayer.hide()
	# Set the selected var to the selected item of the OptionButton
	var selected = $UI/AddLayer/VBoxContainer/OptionButton.get_item_text($UI/AddLayer/VBoxContainer/OptionButton.selected)
	
	# Then find the scene with the same name in Scenes/Editors/Layers
	var layer = load(str("res://Scenes/Editor/Layers/", selected, ".tscn")).instance()
	# Or in Scenes/Editors/Layers/Worldmap for layers when editing Worldmaps
	if UIHelpers.get_level().worldmap:
		layer = load(str("res://Scenes/Editor/Layers/Worldmap/", selected, ".tscn")).instance()
	layer.z_index = $UI/AddLayer/VBoxContainer/Zaxis/SpinBox.value
	layer.original_name = str(selected)
	
	# Then add the layer
	get_tree().current_scene.get_node("Level").add_child(layer)
	layer.set_owner(get_tree().current_scene.get_node("Level"))
	layer.set_name($UI/AddLayer/VBoxContainer/Name/LineEdit.text)
	if "@" in layer.get_name():
		var newname = layer.get_name()
		newname.replace("@","")
		layer.set_name(newname)
	
	# If the layer isn't in the group "layers", add it to the group so it shows in the layer menu
	if not layer.is_in_group("layers"): layer.add_to_group("layers")
	
	# Select the layer
	layer_selected = layer.get_name()
	layer_selected_type = layer.get_class()
	layerfile = get_tree().current_scene.get_node(str("Level/", layer_selected))
	
	# And update the layers list to reflect this
	update_layers()

func update_layers(): # Updates the list of layers at the bottom
	# Clear the existing layer list
	for child in $UI/BottomBar/ScrollContainer/HBoxContainer.get_children():
		child.queue_free()
	
	# For every child in the Level node
	for child in get_tree().current_scene.get_node("Level").get_children():
		# If it counts as a layer (needs to be in "layers" group)
		if child.is_in_group("layers"):
			# Make a layer node to represent it and add it as a child
			var layer = load("res://Scenes/Editor/Layer.tscn").instance()
			layer.type = child.get_class()
			layer.layername = child.get_name()
			layer.original_name = child.original_name
			layer.z_axis = child.z_index
			layer.set_name(child.get_name())
			$UI/BottomBar/ScrollContainer/HBoxContainer.add_child(layer)

func select_first_solid_tilemap():
	for i in get_tree().get_nodes_in_group("tilemap"):
		if i.get_class() == "TileMap":
			if i.get_collision_layer() == 31:
				layer_selected = i.get_name()
				layer_selected_type = "TileMap"
				layerfile = get_tree().current_scene.get_node(str("Level/", layer_selected))
				return

func list_files_in_directory(path):
    var files = []
    dir = Directory.new()
    dir.open(path)
    dir.list_dir_begin()

    while true:
        var file = dir.get_next()
        if file == "":
            break
        elif not file.begins_with("."):
            files.append(file)

    dir.list_dir_end()

    return files

func _on_ZoomIn_pressed():
	get_tree().current_scene.camera_zoom -= 0.25
	get_tree().current_scene.camera_zoom_speed = 5

func _on_ZoomDefault_pressed():
	get_tree().current_scene.camera_zoom = 1
	get_tree().current_scene.camera_zoom_speed = 5

func _on_ZoomOut_pressed():
	get_tree().current_scene.camera_zoom += 0.25
	get_tree().current_scene.camera_zoom_speed = 5

func _on_Play_pressed():
	get_tree().current_scene.editmode_toggle()

func _on_SettingsConfirmation_pressed():
	$Settings/Popup.hide()

func _on_ReturnMenu_pressed():
	$Settings/Popup.hide()
	$Settings/Exit.popup()

func _on_Yes_pressed():
	$UI/AnimationPlayer.play("MoveOut")
	get_tree().current_scene.get_node("CanvasLayer/AnimationPlayer").play("Circle Out")
	yield(get_tree().current_scene.get_node("CanvasLayer/AnimationPlayer"), "animation_finished")
	get_tree().paused = false
	get_tree().change_scene("res://Scenes/UI/MainMenu.tscn")

func _on_No_pressed():
	$Settings/Exit.hide()

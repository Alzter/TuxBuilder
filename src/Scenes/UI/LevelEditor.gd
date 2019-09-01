extends Node2D

const CAMERA_MOVE_SPEED = 32
var category_selected = "Tiles"
var layer_selected = ""
var layer_selected_type = ""
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
var object_dragged = ""
var movetime_up = 0
var movetime_down = 0
var movetime_left = 0
var movetime_right = 0
var player_drag_half = "bottom"
var player_hovered = false
var stop = false
var files = []
var files2 = []
var dir = Directory.new()

func _ready():
	anim_in = get_tree().current_scene.editmode
	visible = false
	$UI.offset = Vector2(get_viewport().size.x * 9999,get_viewport().size.y * 9999)
	$UI/SideBar/VBoxContainer/TilesButton.grab_focus()
	update_tiles()
	update_layers()
	select_first_solid_tilemap()

func _process(_delta):
	if stop == true:
		$SelectedArea.visible = false
		$EraserSprite.visible = false
		$SelectedTile.visible = false
		$SelectedTile.offset = Vector2(0,0)
		return
	
	# General positioning stuff
	$UI/SideBar/VBoxContainer/TilesButton.text = ""
	$UI/SideBar/VBoxContainer/ObjectsButton.text = ""
	$Grid.rect_size = Vector2(get_viewport().size.x + 32, get_viewport().size.y + 32)
	$Grid.rect_position = Vector2(get_tree().current_scene.get_node("Camera2D").position.x - (get_viewport().size.x / 2), get_tree().current_scene.get_node("Camera2D").position.y - (get_viewport().size.y / 2))
	$Grid.rect_position = Vector2(floor($Grid.rect_position.x / 32) * 32, floor($Grid.rect_position.y / 32) * 32)
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
	
	# Navigation
	if Input.is_action_pressed("ui_up"):
		get_tree().current_scene.get_node("Camera2D").position.y -= CAMERA_MOVE_SPEED
		movetime_up += 1
	elif Input.is_action_just_released("ui_up"): movetime_up = -1
	else: movetime_up = 0
	
	if Input.is_action_pressed("ui_down"):
		get_tree().current_scene.get_node("Camera2D").position.y += CAMERA_MOVE_SPEED
		movetime_down += 1
	elif Input.is_action_just_released("ui_down"): movetime_down = -1
	else: movetime_down = 0
	
	if Input.is_action_pressed("ui_left"):
		get_tree().current_scene.get_node("Camera2D").position.x -= CAMERA_MOVE_SPEED
		movetime_left += 1
	elif Input.is_action_just_released("ui_left"): movetime_left = -1
	else: movetime_left = 0
	
	if Input.is_action_pressed("ui_right"):
		get_tree().current_scene.get_node("Camera2D").position.x += CAMERA_MOVE_SPEED
		movetime_right += 1
	elif Input.is_action_just_released("ui_right"): movetime_right = -1
	else: movetime_right = 0
	
	# Round player position
	get_tree().current_scene.get_node("Player").position.x = (floor(get_tree().current_scene.get_node("Player").position.x / 32) * 32) + 16
	get_tree().current_scene.get_node("Player").position.y = round(get_tree().current_scene.get_node("Player").position.y / 32) * 32
	
	# Delay the player movement by one frame to sync with the camera
	if movetime_up != 1 and movetime_up != 0:
		get_tree().current_scene.get_node("Player").position.y -= CAMERA_MOVE_SPEED
	if movetime_down != 1 and movetime_down != 0:
		get_tree().current_scene.get_node("Player").position.y += CAMERA_MOVE_SPEED
	if movetime_left != 1 and movetime_left != 0:
		get_tree().current_scene.get_node("Player").position.x -= CAMERA_MOVE_SPEED
	if movetime_right != 1 and movetime_right != 0:
		get_tree().current_scene.get_node("Player").position.x += CAMERA_MOVE_SPEED
	
	# Disable rectangle select for objects
	if category_selected == "Objects":
		$UI/SideBar/VBoxContainer/HBoxContainer/SelectButton.disabled = true
		$UI/SideBar/VBoxContainer/HBoxContainer/SelectButton.pressed = false
		$UI/SideBar/VBoxContainer/HBoxContainer/SelectButton/TextureRect.self_modulate = Color(1,1,1,0.5)
	else:
		$UI/SideBar/VBoxContainer/HBoxContainer/SelectButton.disabled = false
		$UI/SideBar/VBoxContainer/HBoxContainer/SelectButton/TextureRect.self_modulate = Color(1,1,1,1)
	
	# Placing tiles / objects
	tile_selected = $TileMap.world_to_map(get_global_mouse_position())
	update_selected_tile()
	
	# Drag the player
	if player_hovered == true and Input.is_action_just_pressed("click_left") and dragging_object == false:
		dragging_object = true
		object_dragged = "Player"
		get_tree().current_scene.get_node("Player/Control/AnimatedSprite").scale += Vector2(0.25,0.25)
		if $SelectedTile.position == Vector2(get_tree().current_scene.get_node("Player").position.x,get_tree().current_scene.get_node("Player").position.y - 16):
			player_drag_half = "top"
		else: player_drag_half = "bottom"
	
	# If clicking on a tile occupied by an object, pick up the object
	if category_selected == "Objects" and $UI/SideBar/VBoxContainer/HBoxContainer/EraserButton.pressed == false and dragging_object == false:
		for child in get_tree().current_scene.get_node("Level").get_children():
			if not child.is_in_group("layers"):
				if child.position == $SelectedTile.position:
						$SelectedTile.visible = false
						if Input.is_action_just_pressed("click_left"):
							dragging_object = true
							object_dragged = child.get_name()
							child.scale += Vector2(0.25,0.25)
							return
	
	# Let go of dragged objects
	if not Input.is_action_pressed("click_left") and dragging_object == true:
		dragging_object = false
		$GrabSprite.visible = false
		if object_dragged != "Player":
			get_tree().current_scene.get_node(str("Level/", object_dragged)).scale -= Vector2(0.25,0.25)
			for child in get_tree().current_scene.get_node("Level").get_children():
				if child.position == $SelectedTile.position and child.get_name() != object_dragged and not child.is_in_group("stackable"):
					child.queue_free()
		else: get_tree().current_scene.get_node("Player/Control/AnimatedSprite").scale -= Vector2(0.25,0.25)
	
	# Drag the object
	if Input.is_action_pressed("click_left") and dragging_object == true:
		$SelectedTile.visible = false
		$GrabSprite.visible = true
		$GrabSprite.position = $SelectedTile.position
		if object_dragged != "Player":
			get_tree().current_scene.get_node(str("Level/", object_dragged)).position = $SelectedTile.position
		else:
			get_tree().current_scene.get_node("Player").position = $SelectedTile.position
			if player_drag_half == "top":
				get_tree().current_scene.get_node("Player").position.y += 16
			else: get_tree().current_scene.get_node("Player").position.y -= 16
	
	if Input.is_action_pressed("click_left") and dragging_object == false:
		# If the mouse isn't on the level editor UI
		if get_viewport().get_mouse_position().x < get_viewport().size.x - 128 and get_viewport().get_mouse_position().y < get_viewport().size.y - 64 and (tile_selected != old_tile_selected or mouse_down == false) and $UI/AddLayer.visible == false:
			
			# Tile placing / erasing
			if category_selected == "Tiles":
				
				# Only works if the layer selected is a TileMap
				if layer_selected_type == "TileMap":
					# Tile erasing
					if $UI/SideBar/VBoxContainer/HBoxContainer/SelectButton.pressed == true:
						
						# Rectangle Tile Erasing
						pass
						
					elif $UI/SideBar/VBoxContainer/HBoxContainer/EraserButton.pressed == true:
						get_tree().current_scene.get_node(str("Level/", layer_selected)).set_cellv(tile_selected, -1)
						get_tree().current_scene.get_node(str("Level/", layer_selected)).update_bitmask_area(tile_selected)
					
					
					# Tile placing
					elif $UI/SideBar/VBoxContainer/HBoxContainer/SelectButton.pressed == true:
						
						# Rectangle Tile Placing
						pass
						
					else:
						get_tree().current_scene.get_node(str("Level/", layer_selected)).set_cellv(tile_selected, tile_type)
						get_tree().current_scene.get_node(str("Level/", layer_selected)).update_bitmask_area(tile_selected)
			
			# Object placing / erasing
			else:
				
				# Object erasing (also happens when placing objects so they don't stack)
				for child in get_tree().current_scene.get_node("Level").get_children():
					if child.position == $SelectedTile.position:
						child.queue_free()
				
				# Object placing
				if $UI/SideBar/VBoxContainer/HBoxContainer/EraserButton.pressed == false and object_type != "":
					var object = load(str("res://Scenes/Objects/", object_category, "/", object_type)).instance()
					object.position = $SelectedTile.position
					get_tree().current_scene.get_node("Level").add_child(object)
					object.set_owner(get_tree().current_scene.get_node("Level"))
					object.set_name(object_type)
					if not Input.is_action_pressed("action"):
						dragging_object = true
						object_dragged = object.get_name()
						object.scale += Vector2(0.25,0.25)
		
		mouse_down = true
	else: mouse_down = false
	old_tile_selected = tile_selected

func update_selected_tile():
	$SelectedArea.visible = false
	$EraserSprite.visible = false
	$SelectedTile.visible = false
	$SelectedTile.offset = Vector2(0,0)
	player_hovered = false
	
	if not (get_viewport().get_mouse_position().x < get_viewport().size.x - 128 and get_viewport().get_mouse_position().y < get_viewport().size.y - 64) or $UI/AddLayer.visible == true:
		return
	
	if layer_selected_type != "TileMap" and category_selected == "Tiles":
		return
	
	$SelectedTile.position.x = (tile_selected.x + 0.5) * 32
	$SelectedTile.position.y = (tile_selected.y + 0.5) * 32
	$SelectedTile.offset = Vector2(0,0)
	
	if ($SelectedTile.position == Vector2(get_tree().current_scene.get_node("Player").position.x,get_tree().current_scene.get_node("Player").position.y - 16) and get_tree().current_scene.get_node("Player").state != "small") or $SelectedTile.position == Vector2(get_tree().current_scene.get_node("Player").position.x,get_tree().current_scene.get_node("Player").position.y + 16) and dragging_object == false:
		player_hovered = true
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
		$SelectedTile.region_rect = Rect2(0,0,32,32)
		$SelectedTile.modulate = Color(1,1,1,1)
		$EraserSprite.position = $SelectedTile.position
		old_object_type = ""
	
	else:
		$SelectedArea.color = Color(0,1,0,0.5)
		$EraserSprite.visible = false
		$SelectedTile.visible = true
		$SelectedTile.modulate = Color(1,1,1,0.25)
		
		# Tile selection
		if category_selected == "Tiles":
			var selected_texture = $TileMap.get_tileset().tile_get_texture(tile_type)
			$SelectedTile.texture = (selected_texture)
			$SelectedTile.region_rect.position = $TileMap.get_tileset().autotile_get_icon_coordinate(tile_type) * 32
			$SelectedTile.region_enabled = true
			old_object_type = ""

		else:
			# Object Selection
			if object_type != old_object_type:
				get_object_texture(str("res://Scenes/Objects/", object_category, "/", object_type))
			old_object_type = object_type

# Buttons
func _on_TilesButton_pressed():
	if category_selected != "Tiles":
		category_selected = "Tiles"
		for child in $UI/SideBar/Panel/ScrollContainer/SidebarList.get_children():
			child.queue_free()
		update_tiles()

func _on_ObjectsButton_pressed():
	if category_selected != "Objects":
		category_selected = "Objects"
		for child in $UI/SideBar/Panel/ScrollContainer/SidebarList.get_children():
			child.queue_free()
		update_objects()

func update_tiles():
	var child = load("res://Scenes/Editor/Category.tscn").instance()
	child.item = "Tiles"
	$UI/SideBar/Panel/ScrollContainer/SidebarList.add_child(child)
	
	var tiles = $TileMap.get_tileset().get_tiles_ids()
	for i in tiles.size():
		var child2 = load("res://Scenes/Editor/Tile.tscn").instance()
		child2.tile_type = $TileMap.get_tileset().tile_get_name(tiles[i])
		child.get_node("VBoxContainer/Content").add_child(child2)

func update_objects(): # Update the objects list from the editor using the scenes from Scenes/Objects
	# Delete existing children of the objects/tiles list
	for child in $UI/SideBar/Panel/ScrollContainer/SidebarList.get_children():
		child.queue_free()
	
	# Find all the folders in Scenes/Objects
	list_files_in_directory("res://Scenes/Objects/")
	
	# For every folder in Scenes/Objects
	for i in files.size():
		
		# Create a category
		var child = load("res://Scenes/Editor/Category.tscn").instance()
		var category = files[i]
		child.item = category
		$UI/SideBar/Panel/ScrollContainer/SidebarList.add_child(child)
		
		# Then for every file inside each folder
		list_files_in_directory_2(str("res://Scenes/Objects/", category, "/"))
		for i in files2.size():
			
			# If it's a scene, create an object button inside that category
			if ".tscn" in files2[i]:
				var child2 = load("res://Scenes/Editor/Object.tscn").instance()
				child2.object_category = category
				child2.object_type = files2[i]
				child.get_node("VBoxContainer/Content").add_child(child2)
				
				# Set the object selected to this object if none are selected
				if object_type == "":
					object_type = child2.object_type
					object_category = child2.object_category

func get_object_texture(object_location): # Get the texture for an object
	if object_type == "":
		return
	
	$SelectedTile.region_enabled = false
	
	# If the object has an animated sprite, set the thumbnail to that
	if load(object_location).instance().has_node("AnimatedSprite"):
		var selected_texture = load(object_location).instance().get_node("AnimatedSprite").get_sprite_frames().get_frame("default",0)
		$SelectedTile.offset += load(object_location).instance().get_node("AnimatedSprite").offset
		$SelectedTile.texture = (selected_texture)
	
	# Otherwise if it has a sprite, set the thumbnail to that
	elif load(object_location).instance().has_node("Sprite"):
		var selected_texture = load(object_location).instance().get_node("Sprite").texture
		$SelectedTile.offset += load(object_location).instance().get_node("Sprite").offset
		$SelectedTile.texture = (selected_texture)

# Add all the layers from Scenes/Editor/Layers
func _on_LayerAdd_button_down():
	$UI/AddLayer/VBoxContainer/OptionButton.clear()
	
	# Get all the files from Scenes/Editor/Layers
	list_files_in_directory("res://Scenes/Editor/Layers/")
	for i in files.size():
		# If the file is a scene, add it to the OptionButton
		if ".tscn" in files[i]:
			var item = files[i]
			item.erase(item.length() - 5,5)
			$UI/AddLayer/VBoxContainer/OptionButton.add_icon_item(load(str("res://Sprites/Editor/LayerIcons/", item, ".png")),item)
	
	$UI/AddLayer.popup()

func _on_AddLayer_popup_hide():
	$UI/BottomBar/LayerAdd.pressed = false

func _on_LayerConfirmation_pressed():
	$UI/AddLayer.hide()
	# Set the selected var to the selected item of the OptionButton
	var selected = $UI/AddLayer/VBoxContainer/OptionButton.get_item_text($UI/AddLayer/VBoxContainer/OptionButton.selected)
	
	# Then find the scene with the same name in Scenes/Editors/Layers
	var layer = load(str("res://Scenes/Editor/Layers/", selected, ".tscn")).instance()
	layer.z_index = $UI/AddLayer/VBoxContainer/Zaxis/SpinBox.value
	
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
			layer.z_axis = child.z_index
			layer.set_name(child.get_name())
			$UI/BottomBar/ScrollContainer/HBoxContainer.add_child(layer)

func select_first_solid_tilemap():
	for i in get_tree().get_nodes_in_group("tilemap"):
		if i.get_class() == "TileMap":
			if i.get_collision_layer() == 519:
				layer_selected = i.get_name()
				layer_selected_type = "TileMap"
				return

func list_files_in_directory(path):
    files = []
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

func list_files_in_directory_2(path): # Dupe of list files in directory used to list sub-files
    files2 = []
    dir = Directory.new()
    dir.open(path)
    dir.list_dir_begin()

    while true:
        var file = dir.get_next()
        if file == "":
            break
        elif not file.begins_with("."):
            files2.append(file)

    dir.list_dir_end()

    return files2
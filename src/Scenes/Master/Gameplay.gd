extends Node2D

var editmode = false
var editsaved = false # Using an edited version of a level
var can_edit = true
var current_level = ""
var player_position = Vector2(0,0)
var level_bound_left = 0
var level_bound_right = 0
var level_bound_bottom = 0
var level_bound_top = 0
var camera_smooth_time = 0

func _ready():
	editmode = false
	editsaved = false
	load_level("TEST")
	load_player()
	load_editor()
	load_ui()
	level_bounds()

func _process(_delta):
	if get_viewport().size.x > get_viewport().size.y:
		$CanvasLayer/CircleTransition.rect_size.x = get_viewport().size.x
		$CanvasLayer/CircleTransition.rect_size.y = get_viewport().size.x
		$CanvasLayer/CircleTransition.rect_position.y = 0.5 * (get_viewport().size.y - get_viewport().size.x)
	else:
		$CanvasLayer/CircleTransition.rect_size.x = get_viewport().size.y
		$CanvasLayer/CircleTransition.rect_size.y = get_viewport().size.y
		$CanvasLayer/CircleTransition.rect_position.x = 0.5 * (get_viewport().size.x - get_viewport().size.y)
	
	if Input.is_action_just_pressed("click_right"):
		if $CanvasLayer/AnimationPlayer.is_playing() == false and can_edit == true:
			if editmode == false:
				player_position = get_node("Player").position
				clear_ui()
				clear_player()
				clear_level()
				if editsaved == false:
					load_level(current_level)
				else: load_edited_level()
				load_player()
				get_node("Player").position = player_position
				editmode = true
			else:
				camera_smooth_time = 20
				save_edited_level()
				load_ui()
				editmode = false
	
	if editmode == false:
		level_bounds()
		camera_to_level_bounds()
		if camera_smooth_time == 0:
			$Camera2D.drag_margin_v_enabled = true
	else:
		camera_bounds_remove()
		$Camera2D.drag_margin_v_enabled = false
	
	if camera_smooth_time > 0:
		$Camera2D.smoothing_enabled = true
		camera_smooth_time -= 1
		if camera_smooth_time < 10:
			$Camera2D.smoothing_speed += 3
		else: $Camera2D.smoothing_speed = 10
	else:
		$Camera2D.smoothing_enabled = false
		$Camera2D.smoothing_speed = 10
		camera_smooth_time = 0

func restart_level():
	editmode = false
	$CanvasLayer/AnimationPlayer.play("Circle Out")
	yield(get_node("CanvasLayer/AnimationPlayer"), "animation_finished")
	clear_ui()
	clear_player()
	clear_level()
	if editsaved == false:
		load_level(current_level)
	else: load_edited_level()
	load_ui()
	load_player()
	$CanvasLayer/AnimationPlayer.play("Circle In")

func save_edited_level():
	var packed_scene = PackedScene.new()
	packed_scene.pack(get_tree().get_current_scene().get_node("Level"))
	ResourceSaver.save("res://Scenes/Levels/EditedLevel/EditedLevel.tscn", packed_scene)
	editsaved = true

func load_edited_level():
	var packed_scene = load("res://Scenes/Levels/EditedLevel/EditedLevel.tscn")
	var scene_instance = packed_scene.instance()
	scene_instance.set_name("Level")
	add_child(scene_instance)
	level_to_grid()

func load_level(level):
	current_level = str(level)
	var scene = load(str("res://Scenes/Levels/", level ,".tscn"))
	var scene_instance = scene.instance()
	scene_instance.set_name("Level")
	add_child(scene_instance)
	level_to_grid()

func level_to_grid():
	for child in get_tree().current_scene.get_node("Level").get_children():
		if not child.is_in_group("tilemap"):
			child.position.x = floor(child.position.x / 32) * 32
			child.position.y = floor(child.position.y / 32) * 32
			child.position.x += 16
			child.position.y += 16

func clear_level():
	var scene = get_node("Level")
	remove_child(scene)
	scene.call_deferred("free")

func load_editor():
	var scene = load("res://Scenes/UI/LevelEditor.tscn")
	var scene_instance = scene.instance()
	scene_instance.set_name("Editor")
	add_child(scene_instance)

func clear_editor():
	var scene = get_node("Editor")
	remove_child(scene)

func load_ui():
	var scene = load("res://Scenes/UI/LevelUI.tscn")
	var scene_instance = scene.instance()
	scene_instance.set_name("LevelUI")
	add_child(scene_instance)

func clear_ui():
	var scene = get_node("LevelUI")
	for i in scene.get_children():
		i.queue_free()
	remove_child(scene)
	scene.call_deferred("free")

func load_player():
	var scene = load("res://Scenes/Player/Player.tscn")
	var scene_instance = scene.instance()
	scene_instance.set_name("Player")
	add_child(scene_instance)

func clear_player():
	var scene = get_node("Player")
	for i in scene.get_children():
		i.queue_free()
	remove_child(scene)
	scene.call_deferred("free")

func level_bounds():
	level_bound_left = 0
	level_bound_right = 0
	level_bound_top = 0
	level_bound_bottom = 0
	for child in get_tree().get_nodes_in_group("tilemap"):
		var child_name = child.get_name()
		if get_tree().current_scene.get_node(str("Level/", child_name)).get_used_rect().position.x * get_tree().current_scene.get_node(str("Level/", child_name)).get_cell_size().x < level_bound_left:
			level_bound_left = get_tree().current_scene.get_node(str("Level/", child_name)).get_used_rect().position.x * get_tree().current_scene.get_node(str("Level/", child_name)).get_cell_size().x
		
		if get_tree().current_scene.get_node(str("Level/", child.get_name())).get_used_rect().end.x * get_tree().current_scene.get_node(str("Level/", child_name)).get_cell_size().x > level_bound_right:
			level_bound_right = get_tree().current_scene.get_node(str("Level/", child_name)).get_used_rect().end.x * get_tree().current_scene.get_node(str("Level/", child_name)).get_cell_size().x
		
		if get_tree().current_scene.get_node(str("Level/", child.get_name())).get_used_rect().position.y * get_tree().current_scene.get_node(str("Level/", child_name)).get_cell_size().y < level_bound_top:
			level_bound_top = get_tree().current_scene.get_node(str("Level/", child_name)).get_used_rect().position.y * get_tree().current_scene.get_node(str("Level/", child_name)).get_cell_size().y
		
		if get_tree().current_scene.get_node(str("Level/", child.get_name())).get_used_rect().end.y * get_tree().current_scene.get_node(str("Level/", child.get_name())).get_cell_size().y > level_bound_bottom:
			level_bound_bottom = get_tree().current_scene.get_node(str("Level/", child_name)).get_used_rect().end.y * get_tree().current_scene.get_node(str("Level/", child_name)).get_cell_size().y

func camera_bounds_remove():
	$Camera2D.limit_left = -10000000
	$Camera2D.limit_right = 10000000
	$Camera2D.limit_top = -10000000
	$Camera2D.limit_bottom = 10000000

func camera_to_level_bounds():
	$Camera2D.limit_left = level_bound_left
	$Camera2D.limit_right = level_bound_right
	if $Camera2D.limit_right < get_viewport().size.x: # If the tilemap is thinner than the window, align the camera to the left
		$Camera2D.limit_right = get_viewport().size.x
	$Camera2D.limit_top = level_bound_top
	if $Camera2D.limit_top > get_viewport().size.y * -1: # If the tilemap is shorter than the window, align the camera to the bottom
		$Camera2D.limit_top = get_viewport().size.y * -1
	$Camera2D.limit_bottom = level_bound_bottom


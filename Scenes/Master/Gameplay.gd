extends Node2D

var editmode = false
var editsaved = false # Using an edited version of a level
var current_level = ""
var camera = Vector2(0,0)

func _ready():
	editmode = true
	load_level("TEST")
	load_player()
	load_editor()
	
func _process(delta):
	if Input.is_action_just_pressed("click_right"):
		if editmode == false:
			camera = get_node("Player").position
			clear_ui()
			clear_player()
			clear_level()
			clear_editor()
			if editsaved == false:
				load_level(current_level)
			else: load_edited_level()
			load_player()
			load_editor()
			get_node("Editor/Camera2D").position = camera
			editmode = true
		else:
			save_edited_level()
			get_node("Player/Camera2D").current = true
			clear_editor()
			load_ui()
			editmode = false

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

func load_level(level):
	current_level = str(level)
	var scene = load(str("res://Scenes/Levels/", level ,".tscn"))
	var scene_instance = scene.instance()
	scene_instance.set_name("Level")
	add_child(scene_instance)

func clear_level():
	var scene = get_node("Level")
	remove_child(scene)
	scene.call_deferred("free")

func load_editor():
	var scene = load("res://Scenes/Master/LevelEditor.tscn")
	var scene_instance = scene.instance()
	scene_instance.set_name("Editor")
	add_child(scene_instance)

func clear_editor():
	var scene = get_node("Editor")
	remove_child(scene)

func load_ui():
	var scene = load("res://UI/LevelUI.tscn")
	var scene_instance = scene.instance()
	scene_instance.set_name("LevelUI")
	add_child(scene_instance)

func clear_ui():
	var scene = get_node("LevelUI")
	for i in get_children():
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
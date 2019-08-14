extends Node2D

var editmode = true
var current_level = ""

func _ready():
	load_level("TEST")
	load_player()
	

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

func load_player():
	var scene = load("res://Scenes/Player/Player.tscn")
	var scene_instance = scene.instance()
	scene_instance.set_name("Player")
	add_child(scene_instance)

func clear_player():
	var scene = get_node("Player")
	remove_child(scene)
	scene.call_deferred("free")

func _process(delta):
	if Input.is_action_just_pressed("click_right"):
		if editmode == false:
			editmode = true
			clear_player()
			clear_level()
			load_level(current_level)
			load_player()
			$LevelUI.coins = 0
		else: editmode = false
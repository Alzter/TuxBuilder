extends Node

func _get_scene():
	return get_tree().current_scene

func get_camera():
	return _get_scene().get_node("Camera2D")

func get_player():
	return _get_scene().get_node("Player")

func get_level():
	return _get_scene().get_node("Level")
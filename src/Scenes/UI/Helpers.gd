extends Node

func _get_scene():
	return get_tree().current_scene

func get_camera():
	return _get_scene().get_node("Camera2D")
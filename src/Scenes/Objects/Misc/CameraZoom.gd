extends "Expandable.gd"

export var camera_zoom = 2
export var camera_zoom_speed = 20

func activate():
	get_tree().current_scene.camera_zoom = camera_zoom
	get_tree().current_scene.camera_zoom_speed = camera_zoom_speed
extends "Expandable.gd"

export var camera_zoom = 2
export var camera_zoom_speed = 20

func _process(delta):
	visible = get_tree().current_scene.editmode

func activate(body):
	get_tree().current_scene.camera_zoom = camera_zoom
	get_tree().current_scene.camera_zoom_speed = camera_zoom_speed

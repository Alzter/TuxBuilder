extends "Expandable.gd"

export var camera_zoom = 1
export var camera_zoom_speed = 1

func activate():
	get_tree().current_scene.camera_zoom = camera_zoom
	get_tree().current_scene.camera_zoom_speed = camera_zoom_speed

func _ready():
	$CanvasLayer/Popup/Panel/VBoxContainer/ZoomLevel/SpinBox.value = camera_zoom
	$CanvasLayer/Popup/Panel/VBoxContainer/ZoomSpeed/SpinBox.value = camera_zoom_speed

func _process(delta):
	camera_zoom = $CanvasLayer/Popup/Panel/VBoxContainer/ZoomLevel/SpinBox.value
	camera_zoom_speed = $CanvasLayer/Popup/Panel/VBoxContainer/ZoomSpeed/SpinBox.value
extends Area2D

export var camera_zoom = 2
export var camera_zoom_speed = 20

func _process(delta):
	visible = get_tree().current_scene.editmode

func _on_Area2D_area_entered(area):
	if area.get_parent().is_in_group("player") and get_tree().current_scene.editmode == false:
		get_tree().current_scene.camera_zoom = camera_zoom
		get_tree().current_scene.camera_zoom_speed = camera_zoom_speed

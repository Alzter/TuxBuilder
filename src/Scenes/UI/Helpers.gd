extends Node

func _ready():
	# Upscale everything if the display requires it (crude hiDPI support).
	# This prevents 2D elements from being too small on hiDPI displays.
	if OS.get_screen_dpi() >= 192 and OS.get_screen_size().x >= 2048:
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_DISABLED, SceneTree.STRETCH_ASPECT_IGNORE, Vector2(), 2)

func _get_scene():
	return get_tree().current_scene

func get_camera():
	return _get_scene().get_node("Camera2D")

func get_player():
	return _get_scene().get_node("Player")

func get_level():
	return _get_scene().get_node("Level")

func get_editor():
	return _get_scene().get_node("Editor")

func file_dialog(directory, filetype, save):
	var dialog = load("res://Scenes/UI/FileSelect.tscn").instance()
	dialog.set_name("FileSelect")
	dialog.directory = directory
	dialog.filetype = filetype
	dialog.save = save
	_get_scene().add_child(dialog)
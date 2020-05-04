extends Control

func _ready():
	$VBoxContainer/HBoxContainer/FullscreenCheck.pressed = Settings.config.get_value("video", "fullscreen", false)
	$VBoxContainer/HBoxContainer2/VSyncCheck.pressed = Settings.config.get_value("video", "vsync", true)

func _on_FullscreenCheck_toggled(button_pressed: bool):
	OS.window_fullscreen = button_pressed
	Settings.config.set_value("video", "fullscreen", button_pressed)

func _on_VSyncCheck_toggled(button_pressed: bool) -> void:
	OS.vsync_enabled = button_pressed
	Settings.config.set_value("video", "vsync", button_pressed)

func _on_Back_pressed():
	get_parent().get_node("Panel").show()
	hide()

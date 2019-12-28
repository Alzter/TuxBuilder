extends Popup

func _ready():
	if OS.window_fullscreen:
		$VBoxContainer/HBoxContainer/FullscreenCheck.pressed = true
	if OS.vsync_enabled:
		$VBoxContainer/HBoxContainer2/VSyncCheck.pressed = true

func _on_FullscreenCheck_pressed():
	OS.window_fullscreen = !OS.window_fullscreen

func _on_VSyncCheck_pressed():
	OS.vsync_enabled = !OS.vsync_enabled

func _on_Back_pressed():
	get_parent().get_node("Panel").show()
	hide()

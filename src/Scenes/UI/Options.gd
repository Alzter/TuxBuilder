extends Popup

func _ready():
	if OS.window_fullscreen == true:
		$VBoxContainer/HBoxContainer/FullscreenCheck.pressed = true
	if OS.vsync_enabled == true:
		$VBoxContainer/HBoxContainer2/VSyncCheck.pressed = true

func _on_FullscreenCheck_pressed():
	if OS.window_fullscreen == true:
		OS.window_fullscreen = false
	else:
		OS.window_fullscreen = true

func _on_VSyncCheck_pressed():
	if OS.vsync_enabled == true:
		OS.vsync_enabled = false
	else:
		OS.vsync_enabled = true

func _on_Back_pressed():
	get_parent().get_node("Panel").show()
	hide()
extends Popup

func _input(event):
	if get_tree().current_scene.get_node("Player").dead == false and get_tree().current_scene.get_node("CanvasLayer/AnimationPlayer").is_playing() == false:
		if event.is_action_pressed("pause") && get_tree().paused == false:
			get_tree().paused = true
			show()
		elif event.is_action_pressed("pause") && get_tree().paused == true:
			get_tree().paused = false
			hide()

func _on_Resume_pressed():
	get_tree().paused = false
	self.hide()

func _on_Restart_pressed():
	get_tree().current_scene.call("restart_level")
	get_tree().paused = false

func _on_Options_pressed():
	pass # Replace with function body.

func _on_QuitLevel_pressed():
	pass # Replace with function body.

func _on_MainMenu_pressed():
	pass # Replace with function body.

func _on_QuitGame_pressed():
	get_tree().quit()

extends Control

func _ready():
	$Panel/VBoxContainer/StartGame.grab_focus()
	$FadeIn.show()
	$AnimationPlayer.play("Appear")

func _on_StartGame_pressed():
	pass # Replace with function body.

func _on_Options_pressed():
	$Options.show()
	$Panel.hide()

func _on_Options_popup_hide():
	$Panel.show()

func _on_LevelEditor_pressed():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Scenes/Master/Gameplay.tscn")

func _on_Credits_pressed():
	pass # Replace with function body.

func _on_Quit_pressed():
	get_tree().quit()

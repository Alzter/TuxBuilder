extends Button

func _on_Button_pressed():
	UIHelpers._get_scene().get_node("FileSelect").selectedfile = text
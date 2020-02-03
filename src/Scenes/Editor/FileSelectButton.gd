extends Button

func _on_Button_pressed():
	var fileselect = UIHelpers._get_scene().get_node("FileSelect")
	if not "." in text:
		if fileselect.selectedfile == text and fileselect.movable:
			fileselect.directory = str(fileselect.directory, "/", text)
			fileselect.reload()
	fileselect.selectedfile = text

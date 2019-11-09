extends CanvasLayer

var directory = null
var dir = Directory.new()
var selectedfile = null
var selectdir = null

func _ready():
	$Popup.popup()
	reload()

func _process(delta):
	if $Popup.visible == false:
		queue_free()
	UIHelpers.get_editor().clickdisable = true
	for child in $Popup/Panel/VBoxContainer/ScrollContainer/Files.get_children():
		if selectedfile == child.text:
			child.pressed = true
		else: child.pressed = false

func reload():
	
	# Make sure directory ends in /
	if !directory.ends_with("/"):
		directory = str(directory, "/")
	
	selectedfile = null # Clear selected file
	
	# Delete existing children
	for child in $Popup/Panel/VBoxContainer/ScrollContainer/Files.get_children():
		child.queue_free()
		
	$Popup/Panel/VBoxContainer/TopBar/DirectoryName.text = directory # Update top text
	
	# Get all the files in the directory, then add each as a button node
	var files = list_files_in_directory(directory)
	for file in files:
		var child = load("res://Scenes/Editor/FileSelectButton.tscn").instance()
		child.text = file
		$Popup/Panel/VBoxContainer/ScrollContainer/Files.add_child(child)

func _on_Back_pressed():
	var dir2 = directory.trim_suffix("/")
	var end = dir2.rfind("/")
	dir2.erase(end, dir2.length() - end)
	if dir2.length() > 1:
		directory = dir2
	reload()

func _on_Reload_pressed():
	reload()

func _on_OK_pressed():
	queue_free()

func _on_Cancel_pressed():
	queue_free()

func list_files_in_directory(path):
	var files = []
	dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)
	
	dir.list_dir_end()
	
	return files
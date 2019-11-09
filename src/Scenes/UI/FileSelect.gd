extends CanvasLayer

var directory = "res://Scenes//Levels"
var dir = Directory.new()
var selectedfile = null

func _ready():
	$Popup.popup()
	reload()

func reload():
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
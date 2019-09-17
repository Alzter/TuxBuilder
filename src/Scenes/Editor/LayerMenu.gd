extends Control

var layername2 = ""
var hide = false
var layer = null # Where to get the layer from
var files = []
var dir = Directory.new()
var filepathold = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	# Stop editor doing stuff
	get_tree().current_scene.get_node("Editor").stop = true
	
	# Get the layer
	layer = get_tree().current_scene.get_node(str("Level/", get_parent().layername))
	
	# Set name
	$Popup/Panel/VBoxContainer/Name/LineEdit.text = get_parent().layername
	
	if get_parent().original_name == "Background":
		$Popup/Panel/VBoxContainer/Zaxis.hide()
	else:
		$Popup/Panel/VBoxContainer/Zaxis/SpinBox.value = get_parent().z_axis
		$Popup/Panel/VBoxContainer/Zaxis.show()
	
	print(get_parent().original_name)
	
	# Set solid checkbox
	if get_parent().original_name == "TileMap":
		if layer.get_collision_layer() != 0:
			$Popup/Panel/VBoxContainer/Solid/CheckBox.pressed = true
		else: $Popup/Panel/VBoxContainer/Solid/CheckBox.pressed = false
		$Popup/Panel/VBoxContainer/Solid.show()
	else:
		$Popup/Panel/VBoxContainer/Solid/CheckBox.disabled = true
		$Popup/Panel/VBoxContainer/Solid/CheckBox.pressed = false
		$Popup/Panel/VBoxContainer/Solid.hide()
	
	# Set tint box
	if get_parent().original_name == "Background":
		$Popup/Panel/VBoxContainer/Tint.hide()
	else:
		$Popup/Panel/VBoxContainer/Tint/ColorPickerButton.color = layer.tint
		$Popup/Panel/VBoxContainer/Tint.show()
	
	# Set scroll and move speed
	$Popup/Panel/VBoxContainer/ScrollX/SpinBox.value = layer.scroll_speed.x
	$Popup/Panel/VBoxContainer/ScrollY/SpinBox.value = layer.scroll_speed.y
	$Popup/Panel/VBoxContainer/MoveX/SpinBox.value = layer.move_speed.x
	$Popup/Panel/VBoxContainer/MoveY/SpinBox.value = layer.move_speed.y
	$Popup/Panel/VBoxContainer/Moving/CheckBox.pressed = layer.moving
	
	$Popup/Panel/VBoxContainer/CustomProperties.hide()
	for child in $Popup/Panel/VBoxContainer/CustomProperties.get_children():
		hide()
	$Popup/Panel/VBoxContainer/CustomProperties/TextureRect.show()
	
	# File selecting for things like backgrounds or particles
	if layer.filepath != "":
		$Popup/Panel/VBoxContainer/CustomProperties.show()
		$Popup/Panel/VBoxContainer/CustomProperties/Filelist/OptionButton.clear()
		list_files_in_directory(layer.filepath)
		for i in files.size():
			if ".tscn" in files[i]:
				var item = files[i]
				item.erase(item.length() - 5,5)
				$Popup/Panel/VBoxContainer/CustomProperties/Filelist/OptionButton.add_item(item)
	
	$Popup.popup()

func _process(_delta):
	
	# Change layer name
	if get_parent().layername != $Popup/Panel/VBoxContainer/Name/LineEdit.text:
		if get_tree().current_scene.get_node("Editor").layer_selected == get_parent().layername:
			get_tree().current_scene.get_node("Editor").layer_selected = $Popup/Panel/VBoxContainer/Name/LineEdit.text
		get_tree().current_scene.get_node(str("Level/", get_parent().layername)).name = $Popup/Panel/VBoxContainer/Name/LineEdit.text
		get_parent().layername = $Popup/Panel/VBoxContainer/Name/LineEdit.text
		layer = get_tree().current_scene.get_node(str("Level/", get_parent().layername))
	
	# Change layer z axis
	get_parent().z_axis = $Popup/Panel/VBoxContainer/Zaxis/SpinBox.value
	layer.z_index = get_parent().z_axis
	
	# Change layer solidity
	if not (get_parent().type == "TileMap"):
		$Popup/Panel/VBoxContainer/Solid/CheckBox.disabled = true
		$Popup/Panel/VBoxContainer/Solid/CheckBox.pressed = false
	elif $Popup/Panel/VBoxContainer/Solid/CheckBox.pressed == true:
		layer.set_collision_layer(31)
		layer.set_collision_mask(31)
	else:
		layer.set_collision_layer(0)
		layer.set_collision_mask(0)
	
	# Change layer tint
	layer.tint = $Popup/Panel/VBoxContainer/Tint/ColorPickerButton.color
	
	# Change layer scroll and move speed
	layer.scroll_speed.x = $Popup/Panel/VBoxContainer/ScrollX/SpinBox.value
	layer.scroll_speed.y = $Popup/Panel/VBoxContainer/ScrollY/SpinBox.value
	layer.move_speed.x = $Popup/Panel/VBoxContainer/MoveX/SpinBox.value
	layer.move_speed.y = $Popup/Panel/VBoxContainer/MoveY/SpinBox.value
	layer.moving = $Popup/Panel/VBoxContainer/Moving/CheckBox.pressed
	
	# Change background/particle
	if layer.filepath != "":
		for child in layer.get_children():
			child.queue_free()
		var selected = $Popup/Panel/VBoxContainer/CustomProperties/Filelist/OptionButton.get_item_text($Popup/Panel/VBoxContainer/CustomProperties/Filelist/OptionButton.selected)
		var child = load(str(layer.filepath, "/", selected, ".tscn")).instance()
		layer.add_child(child)
		child.set_owner(get_tree().current_scene.get_node("Level"))
	filepathold = $Popup/Panel/VBoxContainer/CustomProperties/Filelist/OptionButton.selected
	
	# Delete if not in edit mode
	if get_tree().current_scene.editmode == false:
		get_tree().current_scene.get_node("Editor").stop = false
		queue_free()

func _on_OK_pressed():
	get_tree().current_scene.get_node("Editor").stop = false
	queue_free()

func _on_Popup_popup_hide():
	if hide == false:
		get_tree().current_scene.get_node("Editor").stop = false
		queue_free()

func _on_DeleteButton_pressed():
	hide = true
	$Popup.hide()
	$DeleteConfirmation.show()

func _on_DeleteYes_pressed():
	if get_tree().current_scene.get_node("Editor").layer_selected == get_parent().layername:
		get_tree().current_scene.get_node("Editor").layer_selected = ""
		get_tree().current_scene.get_node("Editor").layer_selected_type = ""
	get_parent().queue_free()
	layer.queue_free()
	get_tree().current_scene.get_node("Editor").stop = false
	queue_free()

func _on_DeleteNo_pressed():
	$Popup.popup()
	$DeleteConfirmation.hide()
	hide = false

func list_files_in_directory(path):
    files = []
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
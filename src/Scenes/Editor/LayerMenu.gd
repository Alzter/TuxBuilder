extends Control

var type = ""
var layername = ""
var layername2 = ""
var z_axis = 0
var hide = false
var layer = null # Where to get the layer from

# Called when the node enters the scene tree for the first time.
func _ready():
	# Stop editor doing stuff
	get_tree().current_scene.get_node("Editor").stop = true
	
	# Get the layer
	layer = get_tree().current_scene.get_node(str("Level/", layername))
	
	# Set name and Z axis
	$Popup/Panel/VBoxContainer/Name/LineEdit.text = layername
	$Popup/Panel/VBoxContainer/Zaxis/SpinBox.value = z_axis
	
	# Set solid checkbox
	if not (type == "TileMap"):
		$Popup/Panel/VBoxContainer/Solid/CheckBox.disabled = true
		$Popup/Panel/VBoxContainer/Solid/CheckBox.pressed = false
	elif layer.get_collision_layer() != 0:
		$Popup/Panel/VBoxContainer/Solid/CheckBox.pressed = true
	else: $Popup/Panel/VBoxContainer/Solid/CheckBox.pressed = false
	
	# Set tint box
	$Popup/Panel/VBoxContainer/Tint/ColorPickerButton.color = layer.modulate
	
	# Set scroll and move speed
	$Popup/Panel/VBoxContainer/ScrollX/SpinBox.value = layer.scroll_speed.x
	$Popup/Panel/VBoxContainer/ScrollY/SpinBox.value = layer.scroll_speed.y
	$Popup/Panel/VBoxContainer/MoveX/SpinBox.value = layer.move_speed.x
	$Popup/Panel/VBoxContainer/MoveY/SpinBox.value = layer.move_speed.y
	$Popup/Panel/VBoxContainer/Moving/CheckBox.pressed = layer.moving
	
	$Popup.popup()

func _process(_delta):
	
	# Change layer name
	layername2 = $Popup/Panel/VBoxContainer/Name/LineEdit.text
	if layer.get_name() != layername2:
		get_tree().current_scene.get_node(str("Editor/UI/BottomBar/ScrollContainer/HBoxContainer/", layername)).layername = layername2
		layer.set_name(layername2)
		if get_tree().current_scene.get_node("Editor").layer_selected == layername:
			get_tree().current_scene.get_node("Editor").layer_selected = layername2
		layername = layername2
		layer = get_tree().current_scene.get_node(str("Level/", layername))
	
	# Change layer z axis
	z_axis = $Popup/Panel/VBoxContainer/Zaxis/SpinBox.value
	if layer.z_index != z_axis:
		layer.z_index = z_axis
		get_tree().current_scene.get_node(str("Editor/UI/BottomBar/ScrollContainer/HBoxContainer/", layername)).z_axis = z_axis
	
	# Change layer solidity
	if not (type == "TileMap"):
		$Popup/Panel/VBoxContainer/Solid/CheckBox.disabled = true
		$Popup/Panel/VBoxContainer/Solid/CheckBox.pressed = false
	elif $Popup/Panel/VBoxContainer/Solid/CheckBox.pressed == true:
		layer.set_collision_layer(31)
		layer.set_collision_mask(31)
	else:
		layer.set_collision_layer(0)
		layer.set_collision_mask(0)
	
	# Change layer tint
	layer.modulate = $Popup/Panel/VBoxContainer/Tint/ColorPickerButton.color
	
	# Change layer scroll and move speed
	layer.scroll_speed.x = $Popup/Panel/VBoxContainer/ScrollX/SpinBox.value
	layer.scroll_speed.y = $Popup/Panel/VBoxContainer/ScrollY/SpinBox.value
	layer.move_speed.x = $Popup/Panel/VBoxContainer/MoveX/SpinBox.value
	layer.move_speed.y = $Popup/Panel/VBoxContainer/MoveY/SpinBox.value
	layer.moving = $Popup/Panel/VBoxContainer/Moving/CheckBox.pressed
	
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
	if get_tree().current_scene.get_node("Editor").layer_selected == layername:
		get_tree().current_scene.get_node("Editor").layer_selected = ""
		get_tree().current_scene.get_node("Editor").layer_selected_type = ""
	get_tree().current_scene.get_node(str("Editor/UI/BottomBar/ScrollContainer/HBoxContainer/", layername)).queue_free()
	layer.queue_free()
	get_tree().current_scene.get_node("Editor").stop = false
	queue_free()

func _on_DeleteNo_pressed():
	$Popup.popup()
	$DeleteConfirmation.hide()
	hide = false
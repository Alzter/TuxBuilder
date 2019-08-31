extends Control

var type = ""
var layername = ""
var layername2 = ""
var z_axis = 0
var hide = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# Stop editor doing stuff
	get_tree().current_scene.get_node("Editor").stop = true
	
	# Set name and Z axis
	$Popup/Panel/VBoxContainer/Name/LineEdit.text = layername
	$Popup/Panel/VBoxContainer/Zaxis/SpinBox.value = z_axis
	
	# Set solid checkbox
	if not (type == "TileMap"):
		$Popup/Panel/VBoxContainer/Solid/CheckBox.disabled = true
		$Popup/Panel/VBoxContainer/Solid/CheckBox.pressed = false
	elif get_tree().current_scene.get_node(str("Level/", layername)).get_collision_layer() != 0:
		$Popup/Panel/VBoxContainer/Solid/CheckBox.pressed = true
	else: $Popup/Panel/VBoxContainer/Solid/CheckBox.pressed = false
	
	# Set tint box
	$Popup/Panel/VBoxContainer/Tint/ColorPickerButton.color = get_tree().current_scene.get_node(str("Level/", layername)).modulate
	
	$Popup.popup()

func _process(_delta):
	
	# Change layer name
	layername2 = $Popup/Panel/VBoxContainer/Name/LineEdit.text
	if get_tree().current_scene.get_node(str("Level/", layername)).get_name() != layername2:
		get_tree().current_scene.get_node(str("Editor/UI/BottomBar/ScrollContainer/HBoxContainer/", layername)).layername = layername2
		get_tree().current_scene.get_node(str("Level/", layername)).set_name(layername2)
		if get_tree().current_scene.get_node("Editor").layer_selected == layername:
			get_tree().current_scene.get_node("Editor").layer_selected = layername2
		layername = layername2
	
	# Change layer z axis
	z_axis = $Popup/Panel/VBoxContainer/Zaxis/SpinBox.value
	if get_tree().current_scene.get_node(str("Level/", layername)).z_index != z_axis:
		get_tree().current_scene.get_node(str("Level/", layername)).z_index = z_axis
		get_tree().current_scene.get_node(str("Editor/UI/BottomBar/ScrollContainer/HBoxContainer/", layername)).z_axis = z_axis
	
	# Change layer solidity
	if not (type == "TileMap"):
		$Popup/Panel/VBoxContainer/Solid/CheckBox.disabled = true
		$Popup/Panel/VBoxContainer/Solid/CheckBox.pressed = false
	elif $Popup/Panel/VBoxContainer/Solid/CheckBox.pressed == true:
		get_tree().current_scene.get_node(str("Level/", layername)).set_collision_layer(519)
		get_tree().current_scene.get_node(str("Level/", layername)).set_collision_mask(519)
	else:
		get_tree().current_scene.get_node(str("Level/", layername)).set_collision_layer(0)
		get_tree().current_scene.get_node(str("Level/", layername)).set_collision_mask(0)
	
	# Change layer tint
	get_tree().current_scene.get_node(str("Level/", layername)).modulate = $Popup/Panel/VBoxContainer/Tint/ColorPickerButton.color
	
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
	get_tree().current_scene.get_node(str("Level/", layername)).queue_free()
	get_tree().current_scene.get_node("Editor").stop = false
	queue_free()

func _on_DeleteNo_pressed():
	$Popup.popup()
	$DeleteConfirmation.hide()
	hide = false
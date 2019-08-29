extends Control

var type = ""
var layername = ""
var z_axis = 0

func _ready():
	$Panel/LineEdit.text = str(layername)
	$Panel/SpinBox.value = z_axis

func _process(_delta):
	# Layer name editing
	if $Panel/LineEdit.text != layername:
		get_tree().current_scene.get_node(str("Level/", layername)).set_name($Panel/LineEdit.text)
		layername = $Panel/LineEdit.text
		get_tree().current_scene.get_node("Editor").layer_selected = layername
	
	# Layer Z-axis editing
		z_axis = $Panel/SpinBox.value
		get_tree().current_scene.get_node(str("Level/", layername)).z_index = z_axis
	
	$Panel.modulate = Color(0.5,0.5,0.5,1)
	if type == "TileMap":
		if layername == get_tree().current_scene.get_node("Editor").layer_selected:
			$Panel.modulate = Color(1,1,1,1)

func _on_Button_pressed():
	if type == "TileMap":
		get_tree().current_scene.get_node("Editor").layer_selected = layername
extends Control

var type = ""
var layername = ""
var z_axis = 0
var original_name = ""

func _ready():
	$Panel/Label.text = str(layername)
	$Panel/Panel/Zaxis.text = str(z_axis)
	$Panel/Icon.texture = load(str("res://Sprites/Editor/LayerIcons/", type, ".png"))
	if layername == get_tree().current_scene.get_node("Editor").layer_selected and get_tree().current_scene.get_node(str("Level/",layername)).filepath != "":
		settings()

func _process(_delta):
	# Update text
	$Panel/Label.text = str(layername)
	$Panel/Panel/Zaxis.text = str(z_axis)
	set_name(str(layername))
	
	# Highlight if selected
	$Panel.modulate = Color(0.5,0.5,0.5,1)
	if layername == get_tree().current_scene.get_node("Editor").layer_selected:
		$Panel.modulate = Color(1,1,1,1)

func _on_Button_pressed():
	get_tree().current_scene.get_node("Editor").layer_selected = layername
	get_tree().current_scene.get_node("Editor").layer_selected_type = type

func _on_LayerSettings_pressed():
	settings()

func settings():
	var popup = load("res://Scenes/Editor/LayerMenu.tscn").instance()
	add_child(popup)
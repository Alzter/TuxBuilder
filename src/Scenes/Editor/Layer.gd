extends Control

var type = ""
var layername = ""
var z_axis = ""

func _ready():
	$Panel/Label.text = str(type)
	$Panel/Panel/Label.text = str(z_axis)

func _process(_delta):
	$Panel.modulate = Color(0.5,0.5,0.5,1)
	if type == "TileMap":
		if layername == get_tree().current_scene.get_node("Editor").tilemap_selected:
			$Panel.modulate = Color(1,1,1,1)

func _on_Button_pressed():
	if type == "TileMap":
		get_tree().current_scene.get_node("Editor").tilemap_selected = layername
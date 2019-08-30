extends Control

var type = ""
var layername = ""
var layername2 = ""
var z_axis = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Popup/Panel/VBoxContainer/Name/LineEdit.text = layername
	get_tree().paused
	$Popup.popup()

func _process(_delta):
	layername2 = $Popup/Panel/VBoxContainer/Name/LineEdit.text
	if get_tree().current_scene.get_node(str("Level/", layername)).get_name() != layername2:
		get_tree().current_scene.get_node(str("Editor/UI/BottomBar/ScrollContainer/HBoxContainer/", layername)).layername = layername2
		get_tree().current_scene.get_node(str("Level/", layername)).set_name(layername2)
		if get_tree().current_scene.get_node("Editor").layer_selected == layername:
			get_tree().current_scene.get_node("Editor").layer_selected = layername2
		layername = layername2

func _on_OK_pressed():
	queue_free()
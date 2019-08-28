extends Control

var type = ""
var z_axis = ""

func _ready():
	$Panel/Label.text = str(type)
	$Panel/Panel/Label.text = str(z_axis)
extends Node2D

var item = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/Button/Label.text = str(item)
	$VBoxContainer/Button.pressed = true

func _process(delta):
	if $VBoxContainer/Button.pressed == true:
		$VBoxContainer/Button/Arrow.rect_rotation = -90
		$VBoxContainer/Content.visible = true
	else:
		$VBoxContainer/Button/Arrow.rect_rotation = 180
		$VBoxContainer/Content.visible = false
extends Control

var item = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	item = item.capitalize()
	$VBoxContainer/Button/Label.text = str(item)
	$VBoxContainer/Button.pressed = true

func _process(delta):
	if $VBoxContainer/Button.pressed == true:
		$VBoxContainer/Button/Arrow.rect_rotation = -90
		$VBoxContainer/Content.visible = true
		rect_min_size.y = 32 + ($VBoxContainer/Content.get_child_count() * 32)
	else:
		$VBoxContainer/Button/Arrow.rect_rotation = 180
		$VBoxContainer/Content.visible = false
		rect_min_size.y = 32
	rect_size.y = rect_min_size.y
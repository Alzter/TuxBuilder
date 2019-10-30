extends "Expandable.gd"

export var speed_x = 0
export var speed_y = 0

func activate():
	body.velocity.x += speed_x
	body.velocity.y += speed_y
	body.wind = 3
	if body.run_max < abs(speed_x):
		body.run_max = abs(speed_x)

func _ready():
	$CanvasLayer/Popup/Panel/VBoxContainer/SpeedX/SpinBox.value = speed_x
	$CanvasLayer/Popup/Panel/VBoxContainer/SpeedY/SpinBox.value = speed_y

func _process(delta):
	speed_x = $CanvasLayer/Popup/Panel/VBoxContainer/SpeedX/SpinBox.value
	speed_y = $CanvasLayer/Popup/Panel/VBoxContainer/SpeedY/SpinBox.value
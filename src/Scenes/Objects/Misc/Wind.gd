extends "Expandable.gd"

export var speed_x = 0
export var speed_y = 0

func activate():
	body.velocity.x += speed_x
	body.velocity.y += speed_y * 0.25
	body.wind = 3
	if body.run_max < abs(speed_x) * 2:
		body.run_max = abs(speed_x) * 2

func _ready():
	$CanvasLayer/Popup/Panel/VBoxContainer/SpeedX/SpinBox.value = speed_x
	$CanvasLayer/Popup/Panel/VBoxContainer/SpeedY/SpinBox.value = speed_y

func _process(delta):
	$CPUParticles2D.emission_rect_extents = (boxsize - Vector2(32,32)) * 0.5
	$CPUParticles2D.position = $CPUParticles2D.emission_rect_extents
	$CPUParticles2D.gravity = Vector2(speed_x,speed_y) * 10
	$CPUParticles2D.position += $CPUParticles2D.gravity * -0.05
	$CPUParticles2D.angle = rad2deg( Vector2($CPUParticles2D.gravity.x,$CPUParticles2D.gravity.y).angle() ) * -1
	
	speed_x = $CanvasLayer/Popup/Panel/VBoxContainer/SpeedX/SpinBox.value
	speed_y = $CanvasLayer/Popup/Panel/VBoxContainer/SpeedY/SpinBox.value

func appear(appear):
	$Control/ColorRect.visible = appear
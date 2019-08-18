extends Popup

var background_opacity = 0
var panel_sizemult = 1
var panel_size = Vector2(0,0)

func _ready():
	hide()
	get_tree().paused = false
	panel_size = $Control/VBoxContainer/Panel.rect_size

func _input(event):
	if get_tree().current_scene.get_node("Player").dead == false and get_tree().current_scene.get_node("CanvasLayer/AnimationPlayer").is_playing() == false:
		if event.is_action_pressed("pause") && get_tree().paused == false:
			get_tree().paused = true
			show()
			background_opacity = 0
			panel_sizemult = 0.1
		elif event.is_action_pressed("pause") && get_tree().paused == true:
			get_tree().paused = false

func _process(delta):
	if get_tree().paused == true:
		background_opacity += 0.25
		if background_opacity > 1: background_opacity = 1
		panel_sizemult = panel_sizemult + (1 - panel_sizemult) / 3
		$Background.self_modulate = Color(1, 1, 1, background_opacity)
	else:
		background_opacity -= 0.25
		panel_sizemult -= 0.25
		if panel_sizemult <= 0:
				hide()
	$Control/VBoxContainer/Panel.rect_size.x = panel_size.x * panel_sizemult
	$Control/VBoxContainer/Panel.rect_position.x = (panel_size.x * (1 - panel_sizemult)) * 0.5
	$Control/VBoxContainer/Panel.rect_size.y = panel_size.y * panel_sizemult
	$Control/VBoxContainer/Panel.rect_position.y = (panel_size.y * (1 - panel_sizemult)) * 0.5

func _on_Resume_pressed():
	get_tree().paused = false
	self.hide()

func _on_Restart_pressed():
	get_tree().current_scene.call("restart_level")

func _on_Options_pressed():
	pass # Replace with function body.

func _on_QuitLevel_pressed():
	pass # Replace with function body.

func _on_MainMenu_pressed():
	pass # Replace with function body.
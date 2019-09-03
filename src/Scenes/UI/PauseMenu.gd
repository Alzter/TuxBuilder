extends Popup

var background_opacity = 0
var panel_sizemult = 1
var panel_size = Vector2(0,0)

func _ready():
	hide()
	get_tree().paused = false
	panel_size = $Panel.rect_size

func _input(event):
	if get_tree().current_scene.get_node("Player").dead == false and get_tree().current_scene.get_node("CanvasLayer/AnimationPlayer").is_playing() == false:
		if Input.is_action_just_pressed("pause") && get_tree().paused == false:
			get_tree().paused = true
			show()
			background_opacity = 0
			panel_sizemult = 0.1
			$Panel/VBoxContainer/Continue.grab_focus()
		elif Input.is_action_just_pressed("pause") && get_tree().paused == true:
			get_tree().paused = false

func _process(_delta):
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
	$Panel.rect_size.x = panel_size.x * panel_sizemult
	$Panel.rect_position.x = round(get_viewport().size.x / 2) + ($Panel.rect_size.x * -0.5)
	$Panel.rect_size.y = panel_size.y * panel_sizemult
	$Panel.rect_position.y = round(get_viewport().size.y / 2) + ($Panel.rect_size.y * -0.5)
	$Background.rect_size = get_viewport().size

func _on_Resume_pressed():
	get_tree().paused = false

func _on_Restart_pressed():
	get_tree().current_scene.call("restart_level")

func _on_Options_pressed():
	$Options.show()

func _on_QuitLevel_pressed():
	pass # Replace with function body.

func _on_MainMenu_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://Scenes/UI/MainMenu.tscn")

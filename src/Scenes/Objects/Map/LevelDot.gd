extends Node

export var level = ""
export var cleared = false

func _process(delta):
	if cleared:
		$AnimatedSprite.play("clear")
	else: 
		$AnimatedSprite.play("default")
	
	if $CanvasLayer/Popup.visible:
		UIHelpers.get_editor().clickdisable = true

func _on_Button_pressed():
	$CanvasLayer/Popup.hide()

func _on_Load_pressed():
	$CanvasLayer/Popup.hide()
	UIHelpers.file_dialog("res://Scenes//Levels/")
	
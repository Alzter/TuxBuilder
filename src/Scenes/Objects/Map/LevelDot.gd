extends Node2D

export var level = ""
export var invisible = false
export var autoplay = false
export var cleared = false

func _ready():
	if level != "":
		$DisplayName.text = load(level).instance().level_name
	$CanvasLayer/BottomName.text = $DisplayName.text
	$CanvasLayer/BottomName.hide()
	$CanvasLayer/Popup/Panel/VBoxContainer/Invisible/CheckBox.pressed = invisible
	$CanvasLayer/Popup/Panel/VBoxContainer/AutoPlay/CheckBox.pressed = autoplay

func _process(delta):
	$AnimatedSprite.show()
	if invisible:
		if UIHelpers._get_scene().editmode:
			$AnimatedSprite.play("invisible")
		else: $AnimatedSprite.hide()
	elif cleared:
		$AnimatedSprite.play("clear")
	else: 
		$AnimatedSprite.play("default")
	
	if $CanvasLayer/Popup.visible:
		UIHelpers.get_editor().clickdisable = true
	$DisplayName.visible = UIHelpers._get_scene().editmode
	
	invisible = $CanvasLayer/Popup/Panel/VBoxContainer/Invisible/CheckBox.pressed
	autoplay = $CanvasLayer/Popup/Panel/VBoxContainer/AutoPlay/CheckBox.pressed
	
	$CanvasLayer/BottomName.hide()
	if UIHelpers.get_player().position == position: # Level hovered
		if !UIHelpers._get_scene().editmode:
			$CanvasLayer/BottomName.show()
		if Input.is_action_just_pressed("jump") or autoplay: # Play level
			pass

func _on_Button_pressed():
	$CanvasLayer/Popup.hide()

func _on_Load_pressed():
	$CanvasLayer/Popup.hide()
	UIHelpers.file_dialog("res://Scenes//Levels/")
	yield(UIHelpers._get_scene().get_node("FileSelect"), "tree_exiting")
	if UIHelpers._get_scene().get_node("FileSelect").cancel == false:
		level = UIHelpers._get_scene().get_node("FileSelect").selectdir
		$DisplayName.text = load(level).instance().level_name
	$CanvasLayer/BottomName.text = $DisplayName.text
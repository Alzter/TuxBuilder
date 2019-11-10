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
	
	if $CanvasLayer/Popup.visible or $CanvasLayer/Error.visible:
		UIHelpers.get_editor().clickdisable = true
	$DisplayName.visible = UIHelpers._get_scene().editmode
	
	invisible = $CanvasLayer/Popup/Panel/VBoxContainer/Invisible/CheckBox.pressed
	autoplay = $CanvasLayer/Popup/Panel/VBoxContainer/AutoPlay/CheckBox.pressed
	
	$CanvasLayer/BottomName.hide()
	if !UIHelpers._get_scene().editmode and UIHelpers.get_player().position == position: # Level hovered
		$CanvasLayer/BottomName.show()
		if level != "" and (Input.is_action_just_pressed("jump") or (autoplay and !cleared)): # Play level
			play()

func play(): # Play the level
	get_tree().current_scene.get_node("CanvasLayer/AnimationPlayer").play("Circle Out")
	yield(get_tree().current_scene.get_node("CanvasLayer/AnimationPlayer"), "animation_finished")
	

func _on_Button_pressed():
	$CanvasLayer/Popup.hide()

func _on_Load_pressed():
	$CanvasLayer/Popup.hide()
	UIHelpers.file_dialog("res://Scenes//Levels/") # Bring up file select
	
	yield(UIHelpers._get_scene().get_node("FileSelect"), "tree_exiting")
	
	# After exiting the file select, attempt to load the level if "OK" was pressed
	if UIHelpers._get_scene().get_node("FileSelect").cancel == false:
		
		# Make sure the level is valid by checking its filetype and if it has a level name (utterly foolproof)
		var selectdir = UIHelpers._get_scene().get_node("FileSelect").selectdir
		if ".tscn" in selectdir:
			if load(selectdir).instance().get("level_name") != null:
				level = selectdir
				$DisplayName.text = load(level).instance().level_name
				$CanvasLayer/Popup.popup()
			
			else:
				$CanvasLayer/Error.popup()
		
		else:
			$CanvasLayer/Error.popup()
	
	# Otherwise don't do anything
	else:
		$CanvasLayer/Popup.popup()
	$CanvasLayer/BottomName.text = $DisplayName.text

func _on_ErrorButton_pressed():
	$CanvasLayer/Error.hide()
	$CanvasLayer/Popup.popup()
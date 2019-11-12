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
			UIHelpers._get_scene().load_level_from_map(level)
			UIHelpers.get_player().can_move = false

func _on_Button_pressed():
	$CanvasLayer/Popup.hide()

func _on_Load_pressed():
	$CanvasLayer/Popup.hide()
	UIHelpers.file_dialog("res://Scenes//Levels/") # Bring up file select
	
	yield(UIHelpers._get_scene().get_node("FileSelect"), "tree_exiting")
	
	# After exiting the file select, attempt to load the level if "OK" was pressed
	if UIHelpers._get_scene().get_node("FileSelect").cancel == false:
		var selectdir = UIHelpers._get_scene().get_node("FileSelect").selectdir
		# Pass to Gameplay.gd to check if the level is valid
		if UIHelpers._get_scene().check_level_valid(selectdir) == true:
			level = selectdir
			$DisplayName.text = load(str(level)).instance().level_name
			$CanvasLayer/Popup.popup()
		else:
			$CanvasLayer/Error.popup()
	
	# Otherwise don't do anything
	else:
		$CanvasLayer/Popup.popup()
	$CanvasLayer/BottomName.text = $DisplayName.text

func _on_ErrorButton_pressed():
	$CanvasLayer/Error.hide()
	$CanvasLayer/Popup.popup()
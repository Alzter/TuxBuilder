extends Node2D

var item = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/Label.text = str(item)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

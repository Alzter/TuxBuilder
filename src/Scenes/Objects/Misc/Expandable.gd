extends Node2D

export var boxsize = Vector2(1,1)
export var min_size = Vector2(1,1)
export var scale_h = true
export var scale_v = true

func _ready():
	$Control.rect_min_size = min_size * 32

func _process(delta):
	visible = UIHelpers._get_scene().editmode
	
	for i in get_tree().get_nodes_in_group("player"):
		if UIHelpers._get_scene().editmode == false:
			if i.position.x >= position.x and i.position.x <= position.x + boxsize.x and i.position.y >= position.y and i.position.y <= position.y + boxsize.y:
				activate()
	
	$Control.rect_size = boxsize

# To be overwritten by sub-classes
func activate():
	pass;
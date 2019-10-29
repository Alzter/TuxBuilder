extends Node2D

export var size = Vector2(1,1)
export var min_size = Vector2(1,1)
export var scale_h = true
export var scale_v = true

onready var hitbox = $Area2D/CollisionShape2D

func _process(delta):
	$Control.rect_size = size
	hitbox.position = (size * 0.5) - Vector2(16,16)
	hitbox.shape.extents = size * 0.5
	
	for body in $Area2D.get_overlapping_bodies():
		if body.is_in_group("player"):
			activate()

# To be overwritten by sub-classes
func activate():
	pass;
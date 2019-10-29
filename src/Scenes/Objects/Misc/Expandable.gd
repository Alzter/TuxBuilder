extends Node2D

export var boxsize = Vector2(1,1)
export var min_size = Vector2(1,1)
export var scale_h = true
export var scale_v = true

onready var hitbox = $Area2D/CollisionShape2D

func _ready():
	$Control.rect_min_size = min_size * 32

func _process(delta):
	for body in $Area2D.get_overlapping_bodies():
		if body.is_in_group("player"):
			activate()
	
	$Control.rect_size = boxsize
	hitbox.position = ($Control.rect_size * 0.5) - Vector2(16,16)
	hitbox.shape.extents = $Control.rect_size * 0.5

# To be overwritten by sub-classes
func activate():
	pass;
extends Node2D

export var size = Vector2(1,1)
export var min_size = Vector2(1,1)
export var scale_h = true
export var scale_v = true

# Make Area2D fit control box
func _process(delta):
	if has_node("Control"):
		$Control.rect_size = size
	
	if has_node("Area2D/CollisionShape2D") and has_node("Control"):
		$Area2D/CollisionShape2D.shape.extents.x = $Control.rect_size.x / 2
		$Area2D/CollisionShape2D.position.x = max(0, ($Control.rect_size.x - 32) / 2)
		$Area2D/CollisionShape2D.shape.extents.y = $Control.rect_size.y / 2
		$Area2D/CollisionShape2D.position.y = max(0, ($Control.rect_size.y - 32) / 2)
	
	if get_tree().current_scene.editmode == false:
		for body in $Area2D.get_overlapping_bodies():
			if body.is_in_group("Player"):
				activate(body)

# To be overwritten by sub-classes
func activate(body):
	pass
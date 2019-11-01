extends Node

onready var host = get_owner()

func _step(delta):
	host.set_animation("buttjump")
	
	# Buttjump hitboxes
	if host.get_node("ButtjumpTimer").time_left == 0:
		host.get_node("ButtjumpHitbox/CollisionShape2D").disabled = false
		
		# Change the buttjump hitbox's size so it always collides before Tux hits the ground
		if host.velocity.y > 0:
			host.get_node("ButtjumpHitbox/CollisionShape2D").shape.extents = Vector2(25,16 + (host.velocity.y * delta))
			host.get_node("ButtjumpHitbox/CollisionShape2D").position.y = (host.velocity.y * delta)
		else:
			host.get_node("ButtjumpHitbox/CollisionShape2D").shape.extents = Vector2(25,16)
			host.get_node("ButtjumpHitbox/CollisionShape2D").position.y = 0
	else:
		host.get_node("ButtjumpHitbox/CollisionShape2D").shape.extents = Vector2(0,0)
		host.get_node("ButtjumpHitbox/CollisionShape2D").disabled = true
extends Node

onready var host = get_owner()

var restarted = false # Should Tux call restart level

func _step(delta):
	if Input.is_action_pressed("pause"):
		if !restarted:
			UIHelpers._get_scene().call("restart_level")
			restarted = true
	if host.position.y >= UIHelpers.get_camera().limit_bottom and host.velocity.y > 0:
		if !restarted:
			UIHelpers._get_scene().call("restart_level")
			restarted = true
		host.visible = false
		return
	host.get_node("Control/AnimatedSprite").z_index = 999
	host.get_node("Hitbox").disabled = true
	host.get_node("ButtjumpHitbox/CollisionShape2D").disabled = true
	host.velocity.x = 0
	host.velocity.y += host.GRAVITY
	host.position += host.velocity * delta
extends Node

onready var host = get_owner()

# State Controller
func _process(delta):
	print(host.velocity.y)
	host.get_node("Hitbox").disabled = UIHelpers._get_scene().editmode
	if UIHelpers._get_scene().editmode:
		host.get_node("Hitbox").disabled = true;
		host.get_node("SmallHitbox").disabled = true;
		host.set_animation("idle")
		return
	if !UIHelpers._get_scene().editmode:
		if host.player_state != "Dead":
			host.hitbox(delta)
			host._step(delta)
		get_node(str(host.player_state))._step(delta)
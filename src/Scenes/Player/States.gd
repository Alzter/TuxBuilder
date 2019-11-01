extends Node

onready var host = get_owner()

func _process(delta):
	host.get_node("Hitbox").disabled = UIHelpers._get_scene().editmode
	if UIHelpers._get_scene().editmode:
		host.set_animation("idle")
		return
	
	if host.player_state != "Dead":
		host._step(delta)
	get_node(str(host.player_state))._step(delta)
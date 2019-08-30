extends Position2D

func _process(_delta):
	visible = get_tree().current_scene.editmode
	set_name("SpawnPoint")
	if get_name() != ("SpawnPoint"):
		get_tree().current_scene.get_node("Level/SpawnPoint").queue_free()
		set_name("SpawnPoint")
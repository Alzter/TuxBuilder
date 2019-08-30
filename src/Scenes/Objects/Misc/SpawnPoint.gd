extends Position2D

func _ready():
	set_name("SpawnPoint")
	if get_name() != ("SpawnPoint"):
		queue_free()

func _process(_delta):
	visible = get_tree().current_scene.editmode
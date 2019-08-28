extends Area2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.play("spawn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_FireFlower_body_entered(body):
	if body.is_in_group("player"):
		body.state = "fire"
		$PickupSFX.play()
		queue_free()
		
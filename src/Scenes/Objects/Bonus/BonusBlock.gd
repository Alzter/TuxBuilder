extends StaticBody2D

var hit = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_BottomHitbox_area_entered(area):
	if hit == false:
		if area.get_name() == "HeadAttack":
			$Brick.play()
			$AnimatedSprite.play("empty")
			hit = true

extends "../Misc/Expandable.gd"

func activate():
	if Input.is_action_just_pressed("up"):
		body.position.x = position.x
		body.climbing = true
		body.velocity = Vector2(0,0)

func appear(true):
	pass
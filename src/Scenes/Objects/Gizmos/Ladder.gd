extends "../Misc/Expandable.gd"

func activate():
	if Input.is_action_just_pressed("up") and body.player_state == "Movement":
		body.position.x = position.x
		body.player_state = "Climbing"
		body.velocity = Vector2(0,0)
		body.position.y -= 2
		body.climbtop = position.y
		body.climbbottom = position.y + boxsize.y

func appear(true):
	pass
extends Area2D

var collected = false
var active = false
var velocity = Vector2(0,0)

func _physics_process(delta):
	if active == true:
		position += velocity * delta
		velocity.y += 20

func _on_1Up_body_entered(body):
	if body.is_in_group("player") and collected == false:
		active = false
		collected = true
		var counter = get_tree().get_nodes_in_group("CoinCounter")[0]
		counter.coins = counter.coins + 100
		$AnimationPlayer.play("collect")

func appear(dir, hitdown):
	active = true
	velocity = Vector2(200 * dir, -500)
	if hitdown == true: velocity = Vector2(0, 500)
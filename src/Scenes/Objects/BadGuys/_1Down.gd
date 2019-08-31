extends Area2D

var collected = false
var active = false
var velocity = Vector2(0,0)
var volume = -40

func _physics_process(delta):
	if active == true:
		position += velocity * delta
		velocity.y += 20

func _process(delta):
	if collected == false and get_tree().current_scene.editmode == false:
		$Humming.volume_db = volume
		if $Humming.playing == false: $Humming.play()
		if volume < -15: volume += 5
	else:
		$Humming.stop()
		volume = -80

func _on_1Up_body_entered(body):
	if body.is_in_group("player") and collected == false:
		active = false
		collected = true
		$AnimationPlayer.play("collect")
		body.call("kill")

func appear(dir):
	active = true
	velocity = Vector2(200 * dir, -500)
extends Area2D

var collected = false
var volume = -80

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
		collected = true
		$AnimationPlayer.play("collect")
		body.call("kill")
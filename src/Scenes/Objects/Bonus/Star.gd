extends Area2D

func _ready():
	pass # Replace with function body.

func _on_Star_body_entered(body):
	if body.is_in_group("player"):
		body.star_invincibility()
		$AnimationPlayer.play("pickup")
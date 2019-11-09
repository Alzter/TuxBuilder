extends Node

export var level = ""
export var cleared = false

func _process(delta):
	if cleared:
		$AnimatedSprite.play("clear")
	else: 
		$AnimatedSprite.play("default")
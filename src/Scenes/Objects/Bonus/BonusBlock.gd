extends StaticBody2D

var hit = false
var hitdirection = 0
var stored = "" # Whatever is inside the bonus block

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().current_scene.editmode == false:
		for child in get_tree().current_scene.get_node("Level").get_children():
			if child.position == position and child.get_name() != self.get_name() and not child.is_in_group("layers"):
				stored = child.filename
				child.queue_free()

#func _process(_delta):
#	pass

func _on_BottomHitbox_area_entered(area):
	if hit == false:
		if area.get_name() == "HeadAttack":
			if area.get_parent().position.x > self.position.x:
				hitdirection = -1
			else: hitdirection = 1
			$AnimatedSprite.play("empty")
			$AnimationPlayer.play("hit")
			hit = true
			if stored != "":
				var child = load(str(stored)).instance()
				child.position = position
				if child.name != "Coin":
					$Upgrade.play()
					child.position.y -= 32
				get_tree().current_scene.get_node("Level").add_child(child)
				if child.has_method("appear"):
					child.call("appear", hitdirection)

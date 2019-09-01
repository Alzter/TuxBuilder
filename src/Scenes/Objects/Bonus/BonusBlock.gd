extends StaticBody2D

var hit = false
var hitdirection = 0
var stored = "" # Whatever is inside the bonus block
var childstored = null

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().current_scene.editmode == false:
		for child in get_tree().current_scene.get_node("Level").get_children():
			if child.position == position and child.get_name() != self.get_name() and not child.is_in_group("layers"):
				stored = child.filename
				childstored = load(str(stored)).instance()
				childstored.position = position
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
				if childstored.name != "Coin":
					$Upgrade.play()
					childstored.position.y -= 32
				get_tree().current_scene.get_node("Level").add_child(childstored)
				if childstored.has_method("appear"):
					childstored.call("appear", hitdirection)

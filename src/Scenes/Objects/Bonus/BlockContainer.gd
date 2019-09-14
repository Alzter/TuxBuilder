extends KinematicBody2D

var hit = false
var hitdirection = 0
var stored = "" # Whatever is inside the bonus block
var childstored = null
var hitdirectionstored = 0
var hitdownstored = false
var player = null

# To be overridden by sub-classes
func on_empty_hit():
	pass

func _ready():
	if get_tree().current_scene.editmode == false:
		for child in get_tree().current_scene.get_node("Level").get_children():
			if child.position == position and child.get_name() != self.get_name() and not child.is_in_group("layers"):
				stored = child.filename
				childstored = load(str(stored)).instance()
				childstored.position = position
				child.queue_free()

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		player = body
		if body.position.y > position.y:
			if body.position.x > self.position.x:
				hit(-1,false)
			else: hit(1,false)
		
		elif body.buttjump == true or body.get_node("ButtjumpLandTimer").time_left > 0:
			if body.position.x > self.position.x:
				hit(-1,true)
			else: hit(1,true)

# Hit the block
func hit(hitdirection, hitdown):
	if hit == true: return
	
	hitdirectionstored = hitdirection
	hitdownstored = hitdown
	hit = true
	
	# Spawn contents
	if stored != "":
		
		$AnimatedSprite.play("empty")
		if hitdown == true:
			$AnimationPlayer.play("hitdown")
		else: $AnimationPlayer.play("hit")
		
		if not childstored.is_in_group("coin"):
			$Upgrade.play()
			
			if hitdown == true:
				childstored.position.y += 32
			else: childstored.position.y -= 32
			
		get_tree().current_scene.get_node("Level").add_child(childstored)
		if childstored.has_method("appear"):
			childstored.appear(hitdirection,hitdown)
	else: on_empty_hit()

# Kill enemies on top of block
func _on_TopHitbox_area_entered(area):
	if area.get_parent().is_in_group("badguys"):
		area.get_parent().kill()
	if area.is_in_group("coin"):
		area.appear(0,false)

func _on_TopHitbox_body_entered(body):
	if body.is_in_group("bonusblock") and body.name != name:
		body.hit(hitdirectionstored,hitdownstored)

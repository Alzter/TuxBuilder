extends ParallaxBackground

func _process(delta):
	scroll_base_scale = get_parent().scroll_speed
	scroll_base_offset = get_parent().move_pos

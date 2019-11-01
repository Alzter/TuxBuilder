extends Control

# Returns the editor node
func get_editor():
	return get_tree().current_scene.get_node("Editor")
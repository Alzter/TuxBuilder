# A persistent settings manager using the ConfigFile class. Settings are saved
# automatically when the project exits.
extends Node

const CONFIG_PATH = "user://settings.ini"

var config := ConfigFile.new()

func _ready() -> void:
	config.load(CONFIG_PATH)

	OS.window_fullscreen = Settings.config.get_value("video", "fullscreen", false)
	OS.vsync_enabled = Settings.config.get_value("video", "vsync", true)

func _exit_tree() -> void:
	config.save(CONFIG_PATH)

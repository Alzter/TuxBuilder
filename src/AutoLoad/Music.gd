# Singleton to handle music playback.
# This makes sure music isn't interrupted when switching scenes.
extends AudioStreamPlayer

func play_music(music: AudioStream) -> void:
	stream = music
	play()

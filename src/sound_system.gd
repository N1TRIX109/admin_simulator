extends AudioStreamPlayer

@export var streamMusic: AudioStream
@export var MusicNode: AudioStreamPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func playMusic():
	$MusicStream.stream = streamMusic
	$MusicStream.play()


	

extends Node2D

var a: float

func _ready() -> void:
	Scenetransition.camera_2d.enabled = false
	SoundSystem.streamMusic = preload("res://last breath.wav")
	SoundSystem.playMusic()
	
func _process(delta: float) -> void:
	pass

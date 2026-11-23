extends Node2D
var webview: WebView = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Scenetransition.bpm = 0.0
	SoundSystem.streamMusic = null
	SoundSystem.playMusic()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Scenetransition.transition_fade("res://scenes/mainmenu_concept.tscn")

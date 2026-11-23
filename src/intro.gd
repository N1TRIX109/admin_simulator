extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		$AnimationPlayer.pause()
		Scenetransition.transition_fade("res://scenes/mainmenu_concept.tscn")
	SoundSystem.stream = null
	SoundSystem.playMusic()
	await $AnimationPlayer.animation_finished
	Scenetransition.transition_fade("res://scenes/mainmenu_concept.tscn")


func shake():
	Scenetransition.camshake = 10.0

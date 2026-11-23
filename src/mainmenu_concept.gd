extends Node2D

@onready var play: Area2D = $play
@onready var cards: Area2D = $cards


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SoundSystem.stream = preload("res://snd/click.ogg")
	play.button_press.connect(transition)
	SoundSystem.streamMusic = preload("res://placeholder_audio.ogg")
	SoundSystem.playMusic()
	cards.button_press.connect(cardsfunc)


func transition():
	Scenetransition.transition_fade("res://scenes/tutorial.tscn")
	if SaveGame.tutorCompleted == true:
		Scenetransition.transition_fade("res://scenes/MainGameScene.tscn")


func cardsfunc():
	Scenetransition.transition_fade("res://scenes/placeholder.tscn")

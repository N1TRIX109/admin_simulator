extends Node2D

## Tutorial scene. Plays an intro dialogue through the DialogueSystem on
## the DialogueBox node, then marks the tutorial as completed.

@onready var dialogue: DialogueSystem = $DialogueBox

## Leave "speaker" empty (or out) to hide the name plate for a line.
const INTRO_LINES := [
	{"speaker": "???", "text": "Welcome to the Admin Simulator"},
	{"speaker": "???", "text": "In this step by step tutorial i'll teach you to be a proffessional in this job!"},
	{"speaker": "???", "text": "(i think.. maybe..)"},
	{"speaker": "???", "text": "Oh! Forgot to introduce myself"},
	{"speaker": "Bluey", "text": "My name is [wave]Bluey Shapochkin[/wave], but can me call just Bluey!"},
	{"speaker": "Bluey", "text": "So, that job is quiet simple:"},
	{"speaker": "Bluey", "text": "You must answer the question by the time to get some score"},
	{"speaker": "Bluey", "text": "With score, you can buy some items in the shop, like autoban or something else!"},
	{"speaker": "Bluey", "text": "It's unnecessary if you want to have fun, but it makes your job way effective"},
	{"speaker": "Bluey", "text": "And that's not one way you can earn score"},
	{"speaker": "Bluey", "text": "you can also play minigames"},
	{"speaker": "Bluey", "text": "Try your best to make a big score!"},
	{"speaker": "Bluey", "text": "I think, that's enough for you"},
	{"speaker": "Bluey", "text": "Oh, damn, i almost forgot"},
	{"speaker": "Bluey", "text": "[shake]DONT[/shake]"},
	{"speaker": "Bluey", "text": "[shake]PRESS[/shake]"},
	{"speaker": "Bluey", "text": "[shake]SEVEN[/shake]"},
	{"speaker": "Bluey", "text": "[shake]NEVER[/shake]"},
	{"speaker": "Bluey", "text": "Okay, well, that's all."},
	{"speaker": "Bluey", "text": "Good Luck!!!!"},
]


func _ready() -> void:
	SoundSystem.streamMusic = preload("res://tutorial_theme.ogg")
	SoundSystem.playMusic() 
	dialogue.dialogue_finished.connect(_on_dialogue_finished)
	dialogue.start(INTRO_LINES)



func _process(delta: float) -> void:
	if dialogue._index == 14:
		dialogue.characters_per_second = 20
		SoundSystem.MusicNode.volume_db = -99.0
	if dialogue._index == 18:
		dialogue.characters_per_second = 30
	
func _on_dialogue_finished() -> void:
	SaveGame.tutorCompleted = true
	Scenetransition.transition_fade("res://scenes/MainGameScene.tscn")
	
	SaveGame.save_game()
	

extends Node2D

const CHARS_PER_SECOND: float = 120.0
const RESULT_PAUSE: float = 1.4
const POINTS_PER_CORRECT: int = 10

@onready var timer_label: Label = $TimerLabel
@onready var timer: Timer = $Timer
var waitTimer = 45.00
const CASES: Array[Dictionary] = [
	{ "text": "oekchips is a real cheat", "correct": "ban" },
	{ "text": "thekostyaxdd should die", "correct": "ban" },
	{ "text": "telling about Kostyanaya Friday as a good mod", "correct": "ban" },
	{ "text": "said joke about skid.exe", "correct": "unban" },
	{ "text": "user said that born to be flower is worse than skid.exe rework", "correct": "ban" },
	{ "text": "the user is bacon2 hater", "correct": "unban" },
	{
		"text": "user is making pizza tower slop like bacon2 rework or bacon2 new hope",
		"correct": "ban",
	},
	{ "text": "A quiet regular just came back after a long break.", "correct": "unban" },
	{ "text": "user made a RAT virus using born to be flowers source code", "correct": "ban" },
	{ "text": "Someone has been saying n-words about two weeks", "correct": "ban" },
	{ "text": "user said that born to be flowers is fully shit", "correct": "ban" },
	{ "text": "user supporting DrGoodVaccation", "correct": "ban" },
	{ "text": "user said that skid.exe is a worst meme in 2026", "correct": "ban" },
	{ "text": "user sent tiktok with baldi meme", "correct": "unban" },
	{ "text": "gdnick should die", "correct": "unban" },
	{ "text": "axolot should die", "correct": "unban" },
	{ "text": "phant1k should die", "correct": "ban" },
	{ "text": "basik should die", "correct": "ban" },
	{ "text": "user said that satro is a good human", "correct": "ban" },
	{ "text": "45 aek is a worst fnf mod", "correct": "ban" },
	{ "text": "user said that kostya kombat ultra deluxe is a very good project", "correct": "ban" },
]

@onready var title_label: Label = $Label
@onready var question_label: Label = $Question
@onready var type_sound: AudioStreamPlayer = $TypeSound
@onready var score_label: Label = $Score

var shake_titlelabelel: float = 0.005
var time: float
var a:float
var current_case: Dictionary = { }
var full_text: String = ""
var revealed_chars: int = 0
var is_typing: bool = false
var accepting_input: bool = false
var b:float
var _type_accum: float = 0.0
var _blip_toggle: bool = false
var _on_type_done: Callable = Callable()
var _last_index: int = -1
var isPressed: bool = false

func _ready() -> void:
	Scenetransition.camera_2d.enabled = true
	SoundSystem.MusicNode.volume_db = 0.0
	SoundSystem.streamMusic = preload("res://placeholder_maingame.ogg")
	SoundSystem.playMusic()
	$Ban.button_press.connect(_on_ban_pressed)
	$Noban.button_press.connect(_on_unban_pressed)
	_refresh_score_label()
	_start_round()
	timerChecker()


func _process(delta: float) -> void:
	timer_label.text = "%.2f" % timer.time_left
	
	a += b
	Scenetransition.camera_2d.position += Vector2(randf_range(-a,a),randf_range(-a,a))
	if Input.is_action_just_pressed("seven"):
		var camtween = get_tree().create_tween()
		camtween.tween_property(Scenetransition.camera_2d, "zoom", Vector2(5,5), 4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		camtween.play()
		timer.paused = true
		SoundSystem.stream = preload("res://snd/wind_sfx.ogg")
		SoundSystem.play()
		SoundSystem.playMusic()
		SoundSystem.MusicNode.stream = null
		b+=0.1
		await get_tree().create_timer(4).timeout
		SoundSystem.stop()
		get_tree().change_scene_to_file("res://scenes/secret.tscn")
	question_label.rotation = sin(time * 3) * 0.01
	if Input.is_action_just_pressed("ui_cancel"):
		Scenetransition.transition_fade("res://scenes/mainmenu_concept.tscn")
	time += delta
	title_label.position.y = sin(time * 1) * 6 + 70
	title_label.rotation = randf_range(-shake_titlelabelel, shake_titlelabelel)
	if is_typing:
		_advance_typing(delta)

# --- Typewriter (Undertale style) ---


func _type_text(text: String, done_callable: Callable) -> void:
	full_text = text
	revealed_chars = 0
	_type_accum = 0.0
	question_label.text = ""
	is_typing = true
	_on_type_done = done_callable


func _advance_typing(delta: float) -> void:
	_type_accum += delta * CHARS_PER_SECOND
	while _type_accum >= 1.0 and revealed_chars < full_text.length():
		_type_accum -= 1.0
		revealed_chars += 1
		if full_text[revealed_chars - 1] != " ":
			_blip_toggle = not _blip_toggle
			if _blip_toggle:
				_play_blip()
	question_label.text = full_text.substr(0, revealed_chars)
	if revealed_chars >= full_text.length():
		_finish_typing()


func _finish_typing() -> void:
	if not is_typing:
		return
	is_typing = false
	revealed_chars = full_text.length()
	question_label.text = full_text
	var done: Callable = _on_type_done
	_on_type_done = Callable()
	if done.is_valid():
		done.call()


func _play_blip() -> void:
	type_sound.pitch_scale = randf_range(1.4, 1.8)
	type_sound.volume_db = 4.5
	type_sound.stream = preload("res://snd/type.wav")
	type_sound.play()

# --- Round flow ---


func _start_round() -> void:
	question_label.modulate = Color.WHITE
	current_case = _pick_case()
	accepting_input = false
	var case_text: String = current_case.get("text", "")
	_type_text(case_text, _on_question_typed)


func _on_question_typed() -> void:
	accepting_input = true


func _refresh_score_label() -> void:
	score_label.text = "SCORE: %d" % [SaveGame.score]


func _pick_case() -> Dictionary:
	if CASES.size() <= 1:
		return CASES[0]
	var idx: int = randi() % CASES.size()
	while idx == _last_index:
		idx = randi() % CASES.size()
	_last_index = idx
	return CASES[idx]


func _on_ban_pressed() -> void:
	_answer("ban")


func _on_unban_pressed() -> void:
	_answer("unban")


func _answer(choice: String) -> void:
	# A click during the typewriter just reveals the whole line first.
	if is_typing:
		_finish_typing()
		return
	if not accepting_input:
		return
	accepting_input = false
	
	var correct: String = current_case.get("correct", "")
	
	var is_correct: bool = choice == correct
	if is_correct == true and timer.wait_time >= 2.0:
		waitTimer -= 0.1
		
	var verdict: String
	timer.start()
	timer.wait_time = waitTimer
	SaveGame.record_answer(is_correct, POINTS_PER_CORRECT)
	_refresh_score_label()
	_type_text(verdict, _on_result_typed)
	isPressed = true
	await get_tree().create_timer(1).timeout
	isPressed = false


func _on_result_typed() -> void:
	if is_inside_tree():
		_start_round()
		
func timerChecker():
	while true:
		timer.start(waitTimer)
		await timer.timeout
		if not is_inside_tree():
			return
		if isPressed == false:
			SaveGame.emit_signal("uncorrect")
			SoundSystem.stream = preload("res://snd/explosion.ogg")
			SoundSystem.play()
			SaveGame.score -= POINTS_PER_CORRECT
			SaveGame.save_game()
			_refresh_score_label()
			_start_round()
	

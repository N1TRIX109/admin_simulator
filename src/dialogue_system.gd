class_name DialogueSystem
extends ColorRect

## Reusable dialogue box for adminsim.
##
## Drives the pre-built nodes inside DialogueBox:
##   DialogueLabel  (RichTextLabel, bbcode)  -> the line text
##   CharacterLabel + CharacterRect          -> the speaker name plate
##
## It reveals text with a typewriter effect, advances on an input action and
## reports progress through signals.
##
## Lines are plain dictionaries:
##     { "speaker": "Смотритель", "text": "[shake]Привет![/shake]" }
## "speaker" is optional — an empty or missing speaker hides the name plate.

signal dialogue_started()
signal line_started(index: int, speaker: String, text: String)
signal line_finished(index: int)
signal dialogue_finished()

@export_group("Typing")
## Characters revealed per second while typing.
@export_range(1.0, 200.0, 1.0) var characters_per_second: float = 45.0
## Optional sound played while text is appearing.
@export var typing_sound: AudioStream
## Play the typing sound once every this many revealed characters.
@export_range(1, 20, 1) var typing_sound_every: int = 3

@export_group("Flow")
## Input action that completes the current line / advances to the next one.
@export var advance_action: StringName = &"ui_accept"
## Continue automatically once a line has been fully revealed.
@export var auto_advance: bool = false
## Seconds to wait before auto-advancing.
@export_range(0.0, 10.0, 0.1) var auto_advance_delay: float = 1.5
## Hide the whole box once the last line is done.
@export var hide_on_finish: bool = true
## Resize the speaker plate to fit the name.
@export var auto_resize_name_plate: bool = true

@onready var dialogue_label: RichTextLabel = $DialogueLabel
@onready var character_label: Label = $CharacterLabel
@onready var character_rect: ColorRect = $CharacterRect

var _lines: Array[Dictionary] = []
var _index: int = -1
var _typing: bool = false
var _fully_shown: bool = false
var _reveal: float = 0.0
var _target_chars: int = 0
var _plain_text: String = ""
var _last_sound_char: int = 0
var _auto_timer: float = 0.0
var _typing_player: AudioStreamPlayer


func _ready() -> void:
	_typing_player = AudioStreamPlayer.new()
	_typing_player.name = "TypingSound"
	add_child(_typing_player)
	if typing_sound != null:
		_typing_player.stream = typing_sound
	dialogue_label.bbcode_enabled = true
	visible = false
	set_process(false)


## True while a conversation is running.
func is_active() -> bool:
	return _index >= 0


## Begin a new conversation from an array of line dictionaries.
func start(lines: Array) -> void:
	_lines.clear()
	for line: Variant in lines:
		if line is Dictionary:
			_lines.append(line)
	if _lines.is_empty():
		return
	visible = true
	dialogue_started.emit()
	_show_line(0)


## Stop the current conversation immediately.
func stop() -> void:
	_index = -1
	_typing = false
	_fully_shown = false
	set_process(false)
	visible = false


## Complete the current line, or move to the next one when it is already done.
func advance() -> void:
	if not is_active():
		return
	if _typing:
		_reveal_all()
	else:
		_next_line()


func _unhandled_input(event: InputEvent) -> void:
	if not is_active():
		return
	if event.is_action_pressed(advance_action):
		get_viewport().set_input_as_handled()
		advance()


func _process(delta: float) -> void:
	if not is_active():
		return
	if _typing:
		_update_typing(delta)
	elif _fully_shown and auto_advance:
		_auto_timer += delta
		if _auto_timer >= auto_advance_delay:
			_auto_timer = 0.0
			_next_line()


func _next_line() -> void:
	var next: int = _index + 1
	if next >= _lines.size():
		_finish_dialogue()
	else:
		_show_line(next)


func _show_line(index: int) -> void:
	_index = index
	var line: Dictionary = _lines[index]
	var speaker: String = str(line.get("speaker", ""))
	var text: String = str(line.get("text", ""))
	_set_speaker(speaker)
	dialogue_label.text = text
	dialogue_label.visible_characters = 0
	_plain_text = dialogue_label.get_parsed_text()
	_target_chars = _plain_text.length()
	_reveal = 0.0
	_last_sound_char = 0
	_fully_shown = false
	_auto_timer = 0.0
	line_started.emit(index, speaker, text)
	if _target_chars <= 0:
		_finish_typing()
	else:
		_typing = true
		set_process(true)


func _update_typing(delta: float) -> void:
	_reveal += delta * characters_per_second
	var shown: int = int(_reveal)
	if shown > _target_chars:
		shown = _target_chars
	dialogue_label.visible_characters = shown
	_play_typing_sound(shown)
	if shown >= _target_chars:
		_finish_typing()


func _reveal_all() -> void:
	if not _typing:
		return
	dialogue_label.visible_characters = -1
	_finish_typing()


func _finish_typing() -> void:
	print(_index)
	if _fully_shown:
		return
	_typing = false
	_fully_shown = true
	_reveal = float(_target_chars)
	dialogue_label.visible_characters = -1
	_auto_timer = 0.0
	line_finished.emit(_index)
	if not auto_advance:
		set_process(false)


func _finish_dialogue() -> void:
	_index = -1
	_typing = false
	_fully_shown = false
	set_process(false)
	if hide_on_finish:
		visible = false
	dialogue_finished.emit()


func _play_typing_sound(shown: int) -> void:
	
	if _typing_player.stream == null:
		return
	_typing_player.pitch_scale = randf_range(0.95, 1.1)
	_typing_player.play()
	if shown <= _last_sound_char or shown - _last_sound_char < typing_sound_every:
		return
	_last_sound_char = shown
	var i: int = shown - 1
	
	if i < 0 or i >= _plain_text.length():
		return
	
	var ch: String = _plain_text[i]
	
	if ch.strip_edges() == "":
		return
	


func _set_speaker(speaker: String) -> void:
	var has_speaker: bool = speaker.strip_edges() != ""
	character_rect.visible = has_speaker
	character_label.visible = has_speaker
	if not has_speaker:
		return
	character_label.text = speaker
	if not auto_resize_name_plate:
		return
	var pad: float = character_label.position.x - character_rect.position.x
	var wanted: float = character_label.get_minimum_size().x
	character_label.size.x = wanted
	character_rect.size.x = wanted + pad * 2.0

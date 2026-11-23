extends Node

## Persistent progress for adminsim.
## Registered as the "SaveGame" autoload, so any scene can read/write it.

const SAVE_PATH: String = "user://adminsim_save.cfg"
const SECTION: String = "progress"

var score: int = 0
var correct_count: int = 0
var wrong_count: int = 0
signal correct
signal uncorrect
var tutorCompleted = false

func _ready() -> void:
	load_game()


func load_game() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		tutorCompleted = cfg.get_value(SECTION, "tutorCompleted", false)
		score = cfg.get_value(SECTION, "score", 0)
		correct_count = cfg.get_value(SECTION, "correct_count", 0)
		wrong_count = cfg.get_value(SECTION, "wrong_count", 0)


func save_game() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value(SECTION, "score", score)
	cfg.set_value(SECTION, "correct_count", correct_count)
	cfg.set_value(SECTION, "wrong_count", wrong_count)
	cfg.set_value(SECTION, "tutorCompleted", tutorCompleted)
	cfg.save(SAVE_PATH)


## Call after each answer. Adds points and persists immediately.
func record_answer(is_correct: bool, points: int) -> void:
	if is_correct:
		correct_count += 1
		score += points
		emit_signal("correct")
	else:
		wrong_count += 1
		score -= points
		emit_signal("uncorrect")
	save_game()


func reset_progress() -> void:
	score = 0
	correct_count = 0
	wrong_count = 0
	save_game()

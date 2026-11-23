extends Area2D
@export var text = "anystring"
@onready var button_label: Label = $Label
var scale_target_y = 1.0
var scale_target_x = 1.0
var shake_var = 0.001
@export var is_exit = false
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer
signal button_press
@export var ButtonColor: Color = Color.RED
@export var ExpandScale = 5.7
@export var OriginalScale = 5.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scale_target_y = scale.x
	scale_target_x = scale.y
	button_label.text = text
	self.mouse_entered.connect(buttn_hover)
	self.mouse_exited.connect(buttn_unhover)
	self.input_event.connect(buttn_action)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	scale.x = lerp(scale.x, scale_target_x, delta * 8)
	scale.y = lerp(scale.y, scale_target_y, delta * 8)
	rotation = randf_range(-shake_var, shake_var)


func buttn_hover():
	print("i'm hovered!")
	audio.pitch_scale = randf_range(0.9, 1.1)
	audio.play()
	scale_target_y = ExpandScale
	scale_target_x = ExpandScale + 1.0
	shake_var = 0.02
	button_label.modulate = ButtonColor


func buttn_unhover():
	print("i'm unhovered")
	audio.pitch_scale = randf_range(1.2, 1.5)
	audio.play()
	scale_target_y = OriginalScale
	scale_target_x = OriginalScale
	shake_var = 0.001

	button_label.modulate = Color.WHITE


func buttn_action(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
	):
		
		if is_exit == true:
			get_tree().quit()
		# emit signal for sdfjnsfdjs
		emit_signal("button_press")
		SoundSystem.play()
		scale = Vector2(5.0, 5.0)
	

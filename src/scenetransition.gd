extends CanvasLayer

@onready var timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera_2d: Camera2D = $Camera2D
var camshake = 0.0
var glowval = 0.0
var player: CharacterBody2D


func _ready() -> void:
	SaveGame.correct.connect(_correct)
	SaveGame.uncorrect.connect(uncorrect)


func transition_fade(scene: String):
	animation_player.play("animFade")

	timer.start()
	await timer.timeout
	get_tree().change_scene_to_file(scene)
	animation_player.play_backwards("animFade")


func _process(delta: float) -> void:
	if is_instance_valid(player):
		camera_2d.position = player.position
	if !is_instance_valid(player):
		camera_2d.position = Vector2(randf_range(-camshake, camshake), randf_range(-camshake, camshake)) + Vector2(
		576,
		324,
	)
	$WorldEnvironment.environment.glow_intensity = glowval
	camshake = lerp(camshake, 0.0, delta * 4)
	$UncorrectImage.position = Vector2(randf_range(-camshake, camshake), randf_range(-camshake, camshake)) + Vector2(
		536.0,
		311.0,
	)
	glowval = lerp(glowval, 0.0, delta * 4)
	$UncorrectImage.modulate.a = lerp($UncorrectImage.modulate.a, 0.0, delta * 4)
	if Input.is_action_just_pressed("debug_key"):
		transition_fade("res://scenes/mechanic test.tscn")


func _correct():
	camshake = 50.0
	$CPUParticles2D.restart()
	SoundSystem.volume_db = 0.0
	$CPUParticles2D.emitting = true
	SoundSystem.stream = preload("res://snd/correctclick.ogg")
	SoundSystem.pitch_scale = randf_range(1.1, 1.5)


func uncorrect():
	camshake = 200.0
	$UncorrectImage.modulate.a = 1.0
	SoundSystem.stream = preload("res://snd/explosion.ogg")
	SoundSystem.volume_db = 4.0
	SoundSystem.pitch_scale = randf_range(0.5, 0.7)

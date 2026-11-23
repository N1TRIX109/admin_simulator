extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:
	# 1. Получаем вектор ввода
	Scenetransition.camera_2d.position = position
	var direction := Vector2.ZERO
	direction.x = Input.get_axis("left", "right")
	direction.y = Input.get_axis("up", "down")
	direction = direction.normalized()

	# 2. Двигаем персонажа
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		update_animation(direction)
	else:
		velocity = lerp(velocity, Vector2.ZERO, delta * 16)
		animated_sprite.frame = 0

	move_and_slide()

func update_animation(dir:Vector2):
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			animated_sprite.flip_h = true
			animated_sprite.play("left")
		else:
			animated_sprite.play("left")
			animated_sprite.flip_h = false
	else:
		if dir.y > 0:
			animated_sprite.play("down")
			animated_sprite.flip_h = false
		else:
			animated_sprite.play("up")
			animated_sprite.flip_h = false

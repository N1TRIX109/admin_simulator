extends Sprite2D

var y_targ: float = 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
var time: float
func _process(delta: float) -> void:
	y_targ = lerp(y_targ, 130.0, delta * 4)
	time += delta
	position.y = sin(time * 1) * 9 + y_targ
	rotation = randf_range(-0.01,0.01)
	pass

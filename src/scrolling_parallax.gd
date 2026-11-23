class_name ScrollingParallax
extends ParallaxBackground

## Endless parallax movement for the minigame scenes.
##
## Scrolls the background continuously (and optionally with player input) so the
## far layer drifts away slowly while the near layer sweeps past faster, giving a
## sense of travelling through the level.
##
## ParallaxBackground.scroll_offset is recalculated by the engine whenever a
## Camera2D is active, so this drives each layer through its own
## `motion_offset` instead — that one is never overwritten. Seamless looping is
## done with each layer's `motion_mirroring`, so the content repeats forever
## instead of running out. Any hand-made duplicate copies of a layer's content
## must be hidden first — list them in `duplicate_nodes`.

@export_group("Scroll")
## Idle drift speed in pixels per second (drives each layer's motion_offset along X).
@export var auto_scroll_speed: float = 80.0
## Extra speed added by player input, pixels per second.
@export var max_manual_speed: float = 260.0
## Let left/right (and optionally up/down) drive the scroll.
@export var respond_to_input: bool = true

@export_subgroup("Input actions")
@export var action_left: StringName = &"left"
@export var action_right: StringName = &"right"
@export var action_up: StringName = &"up"
@export var action_down: StringName = &"down"
## How much of the vertical input is forwarded to the parallax (0 disables it).
@export_range(0.0, 1.0, 0.05) var vertical_ratio: float = 0.0

@export_group("Looping")
## Repeat each layer via motion_mirroring so it never ends.
@export var seamless_loop: bool = true
## Width of one tile of the background art, in pixels.
@export var tile_width: float = 1000.0
## Manual duplicate nodes to hide while seamless_loop is on.
@export var duplicate_nodes: Array[NodePath] = []

var _offset: Vector2 = Vector2.ZERO
var _layers: Array[ParallaxLayer] = []


func _ready() -> void:
	for path: NodePath in duplicate_nodes:
		var node: Node = get_node_or_null(path)
		if node is CanvasItem:
			(node as CanvasItem).visible = false
	for child: Node in get_children():
		if child is ParallaxLayer:
			var parallax_layer := child as ParallaxLayer
			_layers.append(parallax_layer)
			if seamless_loop:
				# Repeat distance must include the layer's own scale.
				parallax_layer.motion_mirroring = Vector2(tile_width * parallax_layer.scale.x, 0.0)


## Public control, e.g. for cutscenes.
func set_scrolling(enabled: bool) -> void:
	set_process(enabled)


func _process(delta: float) -> void:
	var velocity := Vector2(auto_scroll_speed, 0.0)
	if respond_to_input:
		velocity.x += Input.get_axis(action_left, action_right) * max_manual_speed
		velocity.y += Input.get_axis(action_up, action_down) * max_manual_speed * vertical_ratio
	_offset += velocity * delta
	# motion_offset is not multiplied by motion_scale by the engine, so apply the
	# depth ratio here: the near layer (bigger motion_scale) sweeps past faster.
	for parallax_layer: ParallaxLayer in _layers:
		parallax_layer.motion_offset = -_offset * parallax_layer.motion_scale
class_name EndlessWorld
extends Node2D

## Endless auto-scrolling scene for the bacontu minigame.
##
## ParallaxBackground is deliberately not used here: while a Camera2D is active
## the engine positions its layers itself (and pushed the far art off-screen),
## and its repeat rules are fiddly. Instead every layer is scrolled by hand and
## wrapped over its own period so nothing ever runs out:
##   - ground: the TileMap, rebuilt as a seamless mirrored column pattern;
##   - foreground bushes: the art already tiles, repeated every texture width;
##   - background landscape: does not tile, so its copies are horizontally
##     flipped (mirror-tiled), which is seamless for any artwork.

const FAR_TEXTURE: Texture2D = preload("res://img/bacontu minigame/bg_beakerFrontier/ffa8cc53-825c-4c98-8023-9d3df07a01dd.png")
const BUSH_TEXTURE: Texture2D = preload("res://img/bacontu minigame/bg_beakerBushes/50c0c411-1be0-48a2-a251-405f2ae961e4.png")

@export_group("Scroll")
## Base speed of the nearest layer (the ground), in pixels per second.
@export var scroll_speed: float = 120.0
## Scroll towards the left (the default, as if walking right). Flip for the other way.
@export var scroll_left: bool = true

@export_group("Background (far landscape)")
@export_range(0.0, 1.0, 0.01) var far_depth: float = 0.1
@export var far_scale: float = 1.5
@export var far_center_y: float = 263.0

@export_group("Foreground (bushes)")
@export_range(0.0, 1.0, 0.01) var bush_depth: float = 0.35
@export var bush_center_y: float = 129.0

@export_group("Ground")
@export_range(0.0, 2.0, 0.01) var ground_depth: float = 1.0
## Mirrored periods of the ground painted as a safety margin.
@export_range(2, 12, 1) var ground_periods: int = 5

@onready var tile_map: TileMap = $TileMap
@onready var background: Node2D = $Background
@onready var foreground: Node2D = $Foreground
@onready var camera: Camera2D = $Camera2D

var _far_width: float = 0.0
var _bush_width: float = 0.0
var _ground_base_x: float = 0.0
var _period_px: float = 0.0
var _time: float = 0.0
var _sign: float = 1.0


func _ready() -> void:
	_sign = -1.0 if scroll_left else 1.0
	camera.make_current()
	var view: Vector2 = get_viewport_rect().size
	camera.position = view * 0.5
	_build_background(view.x)
	_build_foreground(view.x)
	_ground_base_x = tile_map.position.x
	_build_seamless_ground()
	tile_map.position.x = _ground_base_x


func _process(delta: float) -> void:
	_time += delta
	var travel: float = scroll_speed * _time
	tile_map.position.x = _ground_base_x + _sign * fposmod(travel * ground_depth, _period_px)
	foreground.position.x = _sign * fposmod(travel * bush_depth, _bush_width)
	background.position.x = _sign * fposmod(travel * far_depth, _far_width * 2.0)


## Fills the far landscape layer with mirror-tiled copies (alternating flip).
func _build_background(screen_width: float) -> void:
	_far_width = FAR_TEXTURE.get_width() * far_scale
	var period: float = _far_width * 2.0
	var count: int = int(ceil((screen_width + period) / _far_width)) + 1
	for i: int in count:
		var sprite := Sprite2D.new()
		sprite.texture = FAR_TEXTURE
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var flip: float = -far_scale if i % 2 == 1 else far_scale
		sprite.scale = Vector2(flip, far_scale)
		sprite.position = Vector2(i * _far_width + _far_width * 0.5, far_center_y)
		background.add_child(sprite)


## Fills the bushes layer with plain repeated copies (that art tiles).
func _build_foreground(screen_width: float) -> void:
	_bush_width = BUSH_TEXTURE.get_width()
	var count: int = int(ceil((screen_width + _bush_width) / _bush_width)) + 1
	for i: int in count:
		var sprite := Sprite2D.new()
		sprite.texture = BUSH_TEXTURE
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.position = Vector2(i * _bush_width + _bush_width * 0.5, bush_center_y)
		foreground.add_child(sprite)


## Rebuilds the ground into a horizontally periodic, seamless pattern.
func _build_seamless_ground() -> void:
	var cells: Array = tile_map.get_used_cells(0)
	if cells.is_empty():
		return
	var min_x: int = 1 << 30
	var max_x: int = -(1 << 30)
	var min_y: int = 1 << 30
	var max_y: int = -(1 << 30)
	for cell: Vector2i in cells:
		min_x = mini(min_x, cell.x)
		max_x = maxi(max_x, cell.x)
		min_y = mini(min_y, cell.y)
		max_y = maxi(max_y, cell.y)
	# Snapshot the original tiles so we can stamp them elsewhere.
	var originals: Dictionary = {}
	for cell: Vector2i in cells:
		originals[cell] = [
			tile_map.get_cell_source_id(0, cell),
			tile_map.get_cell_atlas_coords(0, cell),
			tile_map.get_cell_alternative_tile(0, cell),
		]

	# Trim edge columns that are missing the top row (the art tapers at its ends);
	# keeping them would leave a notch at every mirror junction.
	var left: int = min_x
	while left < max_x and originals.get(Vector2i(left, min_y)) == null:
		left += 1
	var right: int = max_x
	while right > min_x and originals.get(Vector2i(right, min_y)) == null:
		right -= 1

	# One period = those columns followed by the reversed inner columns
	# (right-1 .. left+1, no duplicated edge column). Every junction is then a
	# natural one-column step, so the mirrored terrain tiles without a seam.
	var columns: Array[int] = []
	for x: int in range(left, right + 1):
		columns.append(x)
	for x: int in range(right - 1, left, -1):
		columns.append(x)
	var period_cols: int = columns.size()

	var tile_size: Vector2 = Vector2(tile_map.tile_set.tile_size)
	_period_px = float(period_cols) * tile_size.x * absf(tile_map.scale.x)

	# Paint one period to the left and ground_periods periods to the right.
	for col_index: int in range(-period_cols, period_cols * (ground_periods + 1)):
		var src_col: int = columns[posmod(col_index, period_cols)]
		var dst_col: int = min_x + col_index
		for y: int in range(min_y, max_y + 1):
			var info: Variant = originals.get(Vector2i(src_col, y))
			if info == null:
				continue
			tile_map.set_cell(0, Vector2i(dst_col, y), info[0], info[1], info[2])

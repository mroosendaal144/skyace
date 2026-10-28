extends Node2D

const SCROLL_SPEED := 30.0
var _screen_h := 1280.0
const SPAWN_MARGIN := 300.0
const MIN_ISLAND_SPACING := 400.0

var _decorations: Array[Dictionary] = []
var _rng := RandomNumberGenerator.new()
var _spawn_timer := 0.0
var _island_textures: Array[ImageTexture] = []
var _edge_left_textures: Array[ImageTexture] = []
var _edge_right_textures: Array[ImageTexture] = []
var _ship_textures: Array[ImageTexture] = []
var _level := 1

func _ready() -> void:
	_level = GameManager.current_level
	_screen_h = get_viewport_rect().size.y
	z_index = 1
	_rng.seed = int(Time.get_ticks_msec())

const DECORATION_FILES := [
	"island_01.png", "island_large_mountain.png", "island_medium_mountain.png",
	"island_long_narrow.png", "island_tiny_atoll.png", "island_volcano.png",
	"island_small_round.png", "island_micro_rocky.png", "island_lagoon_large.png",
	"island_diagonal_long.png", "island_small_lagoon.png", "island_tall_jungle.png",
	"island_small_peak.png", "island_tiny_palms.png", "island_rocky_mini.png",
	"edge_left_cliff.png", "edge_left_beach.png", "edge_left_jungle.png",
	"edge_right_cliff.png", "edge_right_beach.png", "edge_right_jungle.png",
]

func _load_textures() -> void:
	for file: String in DECORATION_FILES:
		var path := "res://textures/decorations/" + file
		var img := GameManager.load_image(path)
		if not img:
			continue
		if img.get_width() > 500:
			var sf := 480.0 / float(img.get_width())
			img.resize(480, int(img.get_height() * sf), Image.INTERPOLATE_BILINEAR)
		else:
			var new_w := int(img.get_width() * 1.2)
			var new_h := int(img.get_height() * 1.2)
			img.resize(new_w, new_h, Image.INTERPOLATE_BILINEAR)
		_feather_edges(img, 30)
		if file.begins_with("edge_left"):
			_edge_left_textures.append(ImageTexture.create_from_image(img))
		elif file.begins_with("edge_right"):
			_edge_right_textures.append(ImageTexture.create_from_image(img))
		elif file.begins_with("ship"):
			_ship_textures.append(ImageTexture.create_from_image(img))
		elif file.begins_with("island"):
			_island_textures.append(ImageTexture.create_from_image(img))

func _feather_edges(img: Image, margin: int) -> void:
	var w := img.get_width()
	var h := img.get_height()
	for y in h:
		for x in w:
			var dist_left := x
			var dist_right := w - 1 - x
			var dist_top := y
			var dist_bottom := h - 1 - y
			var dist := mini(mini(dist_left, dist_right), mini(dist_top, dist_bottom))
			if dist < margin:
				var c := img.get_pixel(x, y)
				if c.a > 0.0:
					c.a *= float(dist) / float(margin)
					img.set_pixel(x, y, c)


func _process(delta: float) -> void:
	if _decorations.is_empty():
		return
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = _rng.randf_range(2.0, 4.5)
		if _rng.randf() < 0.75:
			_spawn_any(-SPAWN_MARGIN)
		else:
			_spawn_ship(-SPAWN_MARGIN)

	var i := _decorations.size() - 1
	while i >= 0:
		_decorations[i].y += SCROLL_SPEED * delta
		if _decorations[i].y > _screen_h + SPAWN_MARGIN:
			_decorations.remove_at(i)
		i -= 1
	queue_redraw()

func _draw() -> void:
	for d in _decorations:
		var tex: ImageTexture = d.tex
		draw_texture(tex, Vector2(d.x, d.y), Color(1, 1, 1, d.alpha))

func _spawn_any(y_pos: float) -> void:
	for d in _decorations:
		if d.is_island and absf(d.y - y_pos) < MIN_ISLAND_SPACING:
			return
	var roll := _rng.randf()
	if roll < 0.25 and not _edge_left_textures.is_empty():
		_spawn_edge_left(y_pos)
	elif roll < 0.50 and not _edge_right_textures.is_empty():
		_spawn_edge_right(y_pos)
	else:
		_spawn_island(y_pos)

func _spawn_island(y_pos: float) -> void:
	if _island_textures.is_empty():
		return
	var tex: ImageTexture = _island_textures[_rng.randi_range(0, _island_textures.size() - 1)]
	var tw := tex.get_width()
	var x := _rng.randf_range(20, 720 - tw - 20)
	_decorations.append({
		"x": x, "y": y_pos, "tex": tex,
		"alpha": _rng.randf_range(0.55, 0.80),
		"is_island": true,
	})

func _spawn_edge_left(y_pos: float) -> void:
	var tex: ImageTexture = _edge_left_textures[_rng.randi_range(0, _edge_left_textures.size() - 1)]
	var tw := tex.get_width()
	var x := _rng.randf_range(-tw * 0.4, -tw * 0.05)
	_decorations.append({
		"x": x, "y": y_pos, "tex": tex,
		"alpha": _rng.randf_range(0.55, 0.80),
		"is_island": true,
	})

func _spawn_edge_right(y_pos: float) -> void:
	var tex: ImageTexture = _edge_right_textures[_rng.randi_range(0, _edge_right_textures.size() - 1)]
	var tw := tex.get_width()
	var x := _rng.randf_range(720 - tw * 0.95, 720 - tw * 0.6)
	_decorations.append({
		"x": x, "y": y_pos, "tex": tex,
		"alpha": _rng.randf_range(0.55, 0.80),
		"is_island": true,
	})

func _spawn_ship(y_pos: float) -> void:
	if _ship_textures.is_empty():
		return
	var tex: ImageTexture = _ship_textures[_rng.randi_range(0, _ship_textures.size() - 1)]
	_decorations.append({
		"x": _rng.randf_range(30.0, 680.0),
		"y": y_pos, "tex": tex,
		"alpha": _rng.randf_range(0.45, 0.65),
		"is_island": false,
	})

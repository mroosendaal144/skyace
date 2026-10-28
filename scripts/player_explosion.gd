extends Node2D

var _frames: Array[Texture2D] = []
var _frame_index := 0
var _time := 0.0
var _frame_timer := 0.0
var lifetime := 0.0
const FRAME_DURATION := 0.25
const DURATION := 1.2
const FRAME_COUNT := 4

var _sprite: Sprite2D = null
var _particles: Array[Dictionary] = []

func _ready() -> void:
	for i in range(1, FRAME_COUNT + 1):
		var path := "res://fighter-png/explosion_%d_128.png" % i
		var tex := GameManager.load_texture(path)
		if tex:
			_frames.append(tex)
	_sprite = Sprite2D.new()
	_sprite.scale = Vector2(2.0, 2.0)
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if _frames.size() > 0:
		_sprite.texture = _frames[0]
	add_child(_sprite)
	for i in 8:
		var angle := randf() * TAU
		var speed := randf_range(60, 200)
		_particles.append({
			"pos": Vector2.ZERO,
			"vel": Vector2.RIGHT.rotated(angle) * speed,
			"size": randf_range(2.0, 5.0),
		})

func _process(delta: float) -> void:
	lifetime += delta
	_time += delta
	if lifetime >= DURATION:
		queue_free()
		return
	_frame_timer += delta
	if _frame_timer >= FRAME_DURATION and _frame_index < _frames.size() - 1:
		_frame_timer = 0.0
		_frame_index += 1
		_sprite.texture = _frames[_frame_index]
	var t := lifetime / DURATION
	_sprite.modulate.a = 1.0 - t * t
	_sprite.scale = Vector2(2.0 + t * 1.5, 2.0 + t * 1.5)
	for p in _particles:
		p["pos"] += p["vel"] * delta
		p["vel"] *= 0.95
	queue_redraw()

func _draw() -> void:
	var t := lifetime / DURATION
	var alpha := (1.0 - t) * (1.0 - t)
	for p in _particles:
		var pos: Vector2 = p["pos"]
		var s: float = p["size"] * (1.0 - t * 0.5)
		var r := lerpf(1.0, 0.6, t)
		var g := lerpf(0.8, 0.1, t)
		draw_circle(pos, s, Color(r, g, 0.1, alpha))

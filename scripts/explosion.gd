extends Node2D

var particles: Array[Dictionary] = []
var lifetime := 0.0
var flash_size := 0.0
const DURATION := 0.45
const PARTICLE_COUNT := 14

func _ready() -> void:
	for i in PARTICLE_COUNT:
		var angle := TAU * i / PARTICLE_COUNT + randf_range(-0.3, 0.3)
		var speed := randf_range(80, 220)
		particles.append({
			"pos": Vector2.ZERO,
			"vel": Vector2.RIGHT.rotated(angle) * speed,
			"size": randf_range(2.0, 5.0),
			"seed": randf(),
		})
	flash_size = randf_range(12.0, 18.0)

func _process(delta: float) -> void:
	lifetime += delta
	if lifetime >= DURATION:
		queue_free()
		return
	for p in particles:
		p["pos"] += p["vel"] * delta
		p["vel"] *= 0.94
	queue_redraw()

func _draw() -> void:
	var t := lifetime / DURATION
	var alpha := (1.0 - t) * (1.0 - t)

	if t < 0.25:
		var flash_t := t / 0.25
		var fs := flash_size * (1.0 + flash_t * 3.0)
		var fa := (1.0 - flash_t) * 0.7
		draw_circle(Vector2.ZERO, fs, Color(1, 1, 0.85, fa))
		draw_circle(Vector2.ZERO, fs * 0.5, Color(1, 1, 1, fa * 0.8))

	for p in particles:
		var s: float = p["size"] * (1.0 + t) * (1.0 - t * 0.6)
		var seed_val: float = p["seed"]
		var r := lerpf(1.0, 0.7, t + seed_val * 0.2)
		var g := lerpf(0.85, 0.15, t)
		var b := lerpf(0.2, 0.02, clampf(t * 2.0, 0.0, 1.0))
		var pos: Vector2 = p["pos"]
		draw_rect(Rect2(pos.x - s * 0.5, pos.y - s * 0.5, s, s), Color(r, g, b, alpha))

	if t > 0.1 and t < 0.6:
		var smoke_alpha := (0.6 - t) * 0.3
		var smoke_size := 8.0 + t * 30.0
		draw_circle(Vector2.ZERO, smoke_size, Color(0.3, 0.25, 0.2, smoke_alpha))

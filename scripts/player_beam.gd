extends Area2D

var beam_width := 6.0
var _damage_timer := 0.0
var _time := 0.0
var _current_level := 0
var _visual_length := 1400.0
const DAMAGE_INTERVAL := 0.10
const BEAM_LENGTH := 1400.0

const WIDTHS := {1: 12.0, 2: 22.0, 3: 34.0, 4: 48.0, 5: 64.0}

var _shape_node: CollisionShape2D = null

func _ready() -> void:
	collision_layer = 2
	collision_mask = 4
	update_level(GameManager.weapon_level)

func update_level(level: int) -> void:
	if level == _current_level:
		return
	_current_level = level
	beam_width = WIDTHS.get(level, 6.0)
	_update_shape()

func _update_shape() -> void:
	if _shape_node:
		var rect := _shape_node.shape as RectangleShape2D
		rect.size = Vector2(beam_width, BEAM_LENGTH)
	else:
		_shape_node = CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(beam_width, BEAM_LENGTH)
		_shape_node.shape = rect
		_shape_node.position = Vector2(0, -BEAM_LENGTH * 0.5)
		add_child(_shape_node)

func _process(delta: float) -> void:
	_time += delta
	var closest_y := -BEAM_LENGTH
	var hit_something := false
	_damage_timer -= delta
	for area in get_overlapping_areas():
		if area.has_method("take_hit"):
			var rel_y: float = area.global_position.y - global_position.y
			if rel_y < 0 and rel_y > closest_y:
				closest_y = rel_y
				hit_something = true
			if _damage_timer <= 0.0:
				area.take_hit(1)
	if _damage_timer <= 0.0:
		_damage_timer = DAMAGE_INTERVAL
	if hit_something:
		_visual_length = absf(closest_y)
	else:
		_visual_length = BEAM_LENGTH
	queue_redraw()

func _draw() -> void:
	var w := beam_width
	var pulse := 0.85 + sin(_time * 12.0) * 0.15
	var h := _visual_length
	draw_rect(Rect2(-w * 0.5, -h, w, h), Color(0.2, 0.9, 0.4, 0.08 * pulse))
	draw_rect(Rect2(-w * 0.35, -h, w * 0.7, h), Color(0.3, 1.0, 0.5, 0.15 * pulse))
	draw_rect(Rect2(-w * 0.2, -h, w * 0.4, h), Color(0.5, 1.0, 0.7, 0.35 * pulse))
	draw_rect(Rect2(-1.0, -h, 2.0, h), Color(0.8, 1.0, 0.9, 0.9))
	var flicker := sin(_time * 25.0) * 0.15
	draw_rect(Rect2(-w * 0.5, -h, w, h), Color(1.0, 1.0, 1.0, 0.05 + flicker))
	if _visual_length < BEAM_LENGTH:
		var impact_pulse := 0.6 + sin(_time * 20.0) * 0.4
		draw_circle(Vector2(0, -h), w * 0.8 * impact_pulse, Color(1.0, 1.0, 0.8, 0.6 * impact_pulse))
		draw_circle(Vector2(0, -h), w * 0.4, Color(1.0, 1.0, 1.0, 0.9))

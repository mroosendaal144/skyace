extends Area2D

const SPEED := 900.0

var direction := Vector2.UP:
	set(value):
		direction = value
		rotation = direction.angle() + PI * 0.5

var _time := 0.0
var _hit := false

func _process(delta: float) -> void:
	position += direction * SPEED * delta
	_time += delta
	queue_redraw()
	if position.y < -20 or position.y > get_viewport_rect().size.y + 20 or position.x < -20 or position.x > 740:
		queue_free()

func _draw() -> void:
	var pulse := 0.8 + sin(_time * 40.0) * 0.2
	draw_line(Vector2(0, 14), Vector2(0, -14), Color(0.15, 0.8, 0.3, 0.2 * pulse), 8.0)
	draw_line(Vector2(0, 12), Vector2(0, -12), Color(0.3, 1.0, 0.5, 0.4 * pulse), 4.0)
	draw_line(Vector2(0, 10), Vector2(0, -11), Color(0.7, 1.0, 0.8, 0.9), 2.0)
	draw_circle(Vector2(0, -12), 3.0 * pulse, Color(0.8, 1.0, 0.9, 0.7 * pulse))
	draw_circle(Vector2(0, -12), 1.5, Color(1.0, 1.0, 1.0, 0.9))

func _on_area_entered(area: Area2D) -> void:
	if _hit:
		return
	if area.has_method("take_hit"):
		_hit = true
		area.take_hit(1)
		queue_free()

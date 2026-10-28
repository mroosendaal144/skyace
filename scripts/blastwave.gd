extends Node2D

var _radius := 0.0
var _max_radius := 900.0
var _speed := 600.0
var _origin := Vector2.ZERO
var _hit_enemies: Array = []
var _alpha := 1.0

func setup(origin: Vector2) -> void:
	_origin = origin
	global_position = Vector2.ZERO

func _process(delta: float) -> void:
	_radius += _speed * delta
	_alpha = clampf(1.0 - _radius / _max_radius, 0.0, 1.0)

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or enemy in _hit_enemies:
			continue
		if _origin.distance_to(enemy.global_position) <= _radius:
			_hit_enemies.append(enemy)
			if enemy.has_method("take_hit"):
				enemy.take_hit(50)

	for bullet in get_tree().get_nodes_in_group("enemy_bullets"):
		if not is_instance_valid(bullet):
			continue
		if _origin.distance_to(bullet.global_position) <= _radius:
			GameManager.add_score(10)
			bullet.queue_free()

	if _radius >= _max_radius:
		queue_free()
		return
	queue_redraw()

func _draw() -> void:
	var center := _origin
	var ring_w := 18.0 + _radius * 0.02
	draw_arc(center, _radius, 0, TAU, 64, Color(1.0, 1.0, 1.0, _alpha * 0.9), ring_w)
	if _radius > 20:
		draw_arc(center, _radius - 15, 0, TAU, 48, Color(0.5, 0.7, 1.0, _alpha * 0.5), 6.0)
	draw_arc(center, _radius + 8, 0, TAU, 48, Color(0.3, 0.5, 1.0, _alpha * 0.25), 10.0)
	if _radius < 250:
		var fill_a := (1.0 - _radius / 250.0) * 0.35
		draw_circle(center, _radius * 0.7, Color(0.8, 0.9, 1.0, fill_a))

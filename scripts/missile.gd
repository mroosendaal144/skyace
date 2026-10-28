extends Area2D

const SPEED := 500.0
const TURN_RATE := 4.5
const DAMAGE := 3

var velocity := Vector2.UP * SPEED
var _target: Node2D = null
var _time := 0.0
var _hit := false

func _ready() -> void:
	_find_target()

func _find_target() -> void:
	var enemies := get_tree().get_nodes_in_group("enemies")
	var closest_dist := 999999.0
	_target = null
	for e in enemies:
		if is_instance_valid(e) and e.global_position.y > -50:
			var d := global_position.distance_to(e.global_position)
			if d < closest_dist:
				closest_dist = d
				_target = e

func _process(delta: float) -> void:
	_time += delta
	if not _target or not is_instance_valid(_target):
		if int(_time * 10) % 3 == 0:
			_find_target()
	if _target and is_instance_valid(_target):
		var desired := global_position.direction_to(_target.global_position)
		var current_dir := velocity.normalized()
		var t := clampf(TURN_RATE * delta, 0.0, 1.0)
		var new_dir := current_dir.slerp(desired, t).normalized()
		velocity = new_dir * SPEED
	position += velocity * delta
	rotation = velocity.angle() + PI * 0.5
	queue_redraw()
	if position.y < -40 or position.y > get_viewport_rect().size.y + 40 or position.x < -40 or position.x > 760:
		queue_free()

func _draw() -> void:
	var pulse := 0.8 + sin(_time * 30.0) * 0.2
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -8), Vector2(3, -2), Vector2(3, 6),
		Vector2(5, 8), Vector2(-5, 8), Vector2(-3, 6), Vector2(-3, -2)
	]), Color(0.3, 0.5, 1.0))
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -8), Vector2(-2, -4), Vector2(2, -4)
	]), Color(0.6, 0.8, 1.0))
	draw_circle(Vector2(0, 10), 3.0 * pulse, Color(1.0, 0.6, 0.1, 0.7 * pulse))
	draw_circle(Vector2(0, 10), 1.5, Color(1.0, 0.9, 0.5, 0.9))

func _on_area_entered(area: Area2D) -> void:
	if _hit:
		return
	if area.has_method("take_hit"):
		_hit = true
		area.take_hit(DAMAGE)
		var exp_scene := preload("res://scenes/explosion.tscn")
		var exp := exp_scene.instantiate()
		exp.position = global_position
		exp.scale = Vector2(0.6, 0.6)
		get_tree().current_scene.add_child(exp)
		queue_free()

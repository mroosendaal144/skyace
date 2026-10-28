extends Area2D

enum Type { BEAM, STRAIGHT, SPREAD, MISSILE, SHIELD, HEALTH, SPECIAL }

const COLORS := {
	Type.BEAM: Color(0.2, 1.0, 0.5),
	Type.STRAIGHT: Color(1.0, 0.4, 0.2),
	Type.SPREAD: Color(1.0, 0.85, 0.15),
	Type.MISSILE: Color(0.3, 0.5, 1.0),
	Type.SHIELD: Color(0.2, 0.85, 1.0),
	Type.HEALTH: Color(0.2, 0.9, 0.3),
	Type.SPECIAL: Color(1.0, 0.85, 0.15),
}

const TYPE_TO_WEAPON := {
	Type.BEAM: "beam",
	Type.STRAIGHT: "straight",
	Type.SPREAD: "spread",
}

var pickup_type: Type = Type.SPREAD
var _time := 0.0
const FALL_SPEED := 80.0
const BOB_AMOUNT := 20.0

func _ready() -> void:
	add_to_group("pickups")

func setup(type: Type) -> void:
	pickup_type = type

func _process(delta: float) -> void:
	_time += delta
	position.y += FALL_SPEED * delta
	position.x += sin(_time * 3.0) * BOB_AMOUNT * delta
	queue_redraw()
	if position.y > get_viewport_rect().size.y + 60:
		queue_free()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 15.0, Color(0, 0, 0, 0.7))
	var c: Color = COLORS.get(pickup_type, Color.WHITE)
	var pulse := 0.7 + sin(_time * 5.0) * 0.3
	var glow_c := Color(c.r, c.g, c.b, 0.2 * pulse)
	draw_circle(Vector2.ZERO, 14.0, glow_c)

	match pickup_type:
		Type.BEAM:
			draw_rect(Rect2(-1.5, -10, 3, 20), c)
			draw_rect(Rect2(-4, -10, 8, 20), Color(c.r, c.g, c.b, 0.3))
			draw_circle(Vector2(0, -10), 2.5, Color(1, 1, 1, 0.8))
		Type.STRAIGHT:
			draw_rect(Rect2(-4, -9, 2, 18), c)
			draw_rect(Rect2(2, -9, 2, 18), c)
			draw_circle(Vector2(-3, -9), 1.5, Color(1, 0.8, 0.6))
			draw_circle(Vector2(3, -9), 1.5, Color(1, 0.8, 0.6))
		Type.SPREAD:
			draw_line(Vector2(0, 2), Vector2(0, -10), c, 2.0)
			draw_line(Vector2(0, 2), Vector2(-7, -7), c, 2.0)
			draw_line(Vector2(0, 2), Vector2(7, -7), c, 2.0)
			draw_circle(Vector2(0, -10), 1.5, Color(1, 1, 0.8))
			draw_circle(Vector2(-7, -7), 1.5, Color(1, 1, 0.8))
			draw_circle(Vector2(7, -7), 1.5, Color(1, 1, 0.8))
		Type.MISSILE:
			draw_colored_polygon(PackedVector2Array([
				Vector2(0, -10), Vector2(4, -4), Vector2(4, 6),
				Vector2(7, 10), Vector2(-7, 10), Vector2(-4, 6), Vector2(-4, -4)
			]), c)
			draw_colored_polygon(PackedVector2Array([
				Vector2(-2, -6), Vector2(2, -6), Vector2(2, 2), Vector2(-2, 2)
			]), Color(0.6, 0.75, 1.0))
		Type.SHIELD:
			draw_colored_polygon(PackedVector2Array([
				Vector2(0, -10), Vector2(9, -4), Vector2(9, 3),
				Vector2(0, 10), Vector2(-9, 3), Vector2(-9, -4)
			]), c)
			draw_colored_polygon(PackedVector2Array([
				Vector2(0, -6), Vector2(5, -2), Vector2(5, 1),
				Vector2(0, 6), Vector2(-5, 1), Vector2(-5, -2)
			]), Color(0.5, 0.95, 1.0))
		Type.HEALTH:
			draw_colored_polygon(PackedVector2Array([
				Vector2(-3, -9), Vector2(3, -9), Vector2(3, -3),
				Vector2(9, -3), Vector2(9, 3), Vector2(3, 3),
				Vector2(3, 9), Vector2(-3, 9), Vector2(-3, 3),
				Vector2(-9, 3), Vector2(-9, -3), Vector2(-3, -3)
			]), c)
		Type.SPECIAL:
			var pts := PackedVector2Array()
			for i in 10:
				var angle := TAU * i / 10 - PI * 0.5
				var r := 10.0 if i % 2 == 0 else 5.0
				pts.append(Vector2(cos(angle) * r, sin(angle) * r))
			draw_colored_polygon(pts, c)
			draw_circle(Vector2.ZERO, 3.0, Color(1, 1, 0.8))

	var outline_c := Color(1, 1, 1, 0.4 * pulse)
	draw_arc(Vector2.ZERO, 11.0, 0, TAU, 24, outline_c, 1.0)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		_apply(area)
		queue_free()

func _apply(_player: Node2D) -> void:
	match pickup_type:
		Type.BEAM, Type.STRAIGHT, Type.SPREAD:
			var weapon_name: String = TYPE_TO_WEAPON[pickup_type]
			if GameManager.weapon_type == weapon_name:
				if GameManager.weapon_level < 5:
					GameManager.weapon_level += 1
				else:
					GameManager.add_score(500)
			else:
				GameManager.weapon_type = weapon_name
				GameManager.weapon_level = 1
		Type.MISSILE:
			if GameManager.missile_level < 3:
				GameManager.missile_level += 1
			else:
				GameManager.add_score(500)
		Type.SHIELD:
			if _player.has_method("add_shield"):
				_player.add_shield(30.0)
		Type.HEALTH:
			if _player.has_method("heal"):
				_player.heal(0.25)
		Type.SPECIAL:
			GameManager.special_charges = mini(GameManager.special_charges + 1, 5)

extends Node2D

const RADIUS := 53.0
const SEGMENTS := 36

var _hit_flash := 0.0
var _break_anim := 0.0
var _damage_flash := 0.0
var _pulse_time := 0.0

func _process(delta: float) -> void:
	var player := get_parent()
	var shield_active: bool = player.shield > 0.0 and player.alive
	if shield_active:
		_pulse_time += delta
	if _hit_flash > 0.0:
		_hit_flash = maxf(_hit_flash - delta, 0.0)
	if _damage_flash > 0.0:
		_damage_flash = maxf(_damage_flash - delta, 0.0)
	if _break_anim > 0.0:
		_break_anim = maxf(_break_anim - delta, 0.0)
	if not shield_active and visible and _break_anim <= 0.0 and _damage_flash <= 0.0:
		visible = false
	elif shield_active and not visible:
		visible = true
		_break_anim = 0.0
	elif not shield_active and _break_anim <= 0.0 and _damage_flash <= 0.0:
		visible = false
	queue_redraw()

func hit_flash() -> void:
	_hit_flash = 0.15
	visible = true

func damage_flash() -> void:
	_damage_flash = 0.2
	visible = true

func shield_broke() -> void:
	_break_anim = 0.3
	visible = true

func _draw() -> void:
	if _damage_flash > 0.0:
		_draw_damage_glow()
	var player := get_parent()
	var shield_active: bool = player.shield > 0.0
	if shield_active or _break_anim > 0.0:
		_draw_shield(shield_active)

func _draw_shield(shield_active: bool) -> void:
	var alpha_mult := 1.0
	if not shield_active and _break_anim > 0.0:
		alpha_mult = _break_anim / 0.3

	var pulse := 1.0 + sin(_pulse_time * 3.0) * 0.04
	var r := RADIUS * pulse
	if not shield_active:
		r *= 1.0 + (1.0 - alpha_mult) * 0.5

	var fill_alpha := 0.3 * alpha_mult
	var edge_alpha := 0.8 * alpha_mult
	var fill_c := Color(0.15, 0.4, 1.0, fill_alpha)
	var edge_c := Color(0.4, 0.7, 1.0, edge_alpha)

	if _hit_flash > 0.0 or (not shield_active and _break_anim > 0.0):
		var t := _hit_flash / 0.15 if shield_active else 1.0
		fill_c = fill_c.lerp(Color(1.0, 0.15, 0.1, fill_alpha), t)
		edge_c = edge_c.lerp(Color(1.0, 0.3, 0.2, edge_alpha), t)

	draw_circle(Vector2.ZERO, r, fill_c)
	draw_arc(Vector2.ZERO, r + 3, 0, TAU, SEGMENTS, Color(edge_c.r, edge_c.g, edge_c.b, edge_c.a * 0.25), 5.0, true)
	draw_arc(Vector2.ZERO, r, 0, TAU, SEGMENTS, edge_c, 2.0, true)

func _draw_damage_glow() -> void:
	var t := _damage_flash / 0.2
	var alpha := 0.5 * t
	var r := RADIUS * (1.0 + (1.0 - t) * 0.3)
	draw_circle(Vector2.ZERO, r, Color(1.0, 0.1, 0.05, alpha * 0.5))
	draw_arc(Vector2.ZERO, r, 0, TAU, SEGMENTS, Color(1.0, 0.2, 0.1, alpha), 2.5, true)

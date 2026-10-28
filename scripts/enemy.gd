extends Area2D

signal destroyed

const BULLET_SCENE := preload("res://scenes/enemy_bullet.tscn")
const EXPLOSION_SCENE := preload("res://scenes/explosion.tscn")
const PICKUP_SCENE := preload("res://scenes/pickup.tscn")

@export var enemy_type := "scout"
var hp := 2
var speed := 200.0
var shoot_interval := 2.5
var shoot_timer := 0.0
var move_dir := Vector2.DOWN
var wave_move := false
var wave_dir := Vector2.RIGHT
var wave_amplitude := 100.0
var wave_frequency := 2.5
var _player: Node2D = null
var _hover_y := -1.0
var _strafe_dir := 1.0
var _time := 0.0
var _palette: Dictionary = {}
var _sprite_node: Sprite2D = null

const SPRITE_MAP := {
	1: {
		"scout": "res://sprites/level_01/scout.png",
		"diver": "res://sprites/level_01/scout.png",
		"gunship": "res://sprites/level_01/gunship.png",
		"carrier": "res://sprites/level_01/heavy.png",
		"mini_boss": "res://sprites/level_01/heavy.png",
		"kamikaze": "res://sprites/level_01/scout.png",
	},
	2: {
		"scout": "res://sprites/level_02/scout.png",
		"diver": "res://sprites/level_02/scout.png",
		"gunship": "res://sprites/level_02/gunship_processed.png",
		"carrier": "res://sprites/level_02/heavy_processed.png",
		"mini_boss": "res://sprites/level_02/heavy_processed.png",
		"kamikaze": "res://sprites/level_02/scout.png",
	},
}

const PALETTES := {
	1: {"body": Color(0.35, 0.45, 0.55), "accent": Color(0.5, 0.6, 0.7), "detail": Color(0.75, 0.85, 0.95), "name": "ocean"},
	2: {"body": Color(0.35, 0.38, 0.22), "accent": Color(0.45, 0.48, 0.28), "detail": Color(0.85, 0.8, 0.2), "name": "city"},
	3: {"body": Color(0.28, 0.28, 0.32), "accent": Color(0.18, 0.18, 0.22), "detail": Color(0.9, 0.25, 0.2), "name": "city"},
	4: {"body": Color(0.5, 0.38, 0.18), "accent": Color(0.7, 0.5, 0.22), "detail": Color(1.0, 0.9, 0.3), "name": "industrial"},
	5: {"body": Color(0.42, 0.32, 0.22), "accent": Color(0.55, 0.38, 0.22), "detail": Color(0.85, 0.65, 0.3), "name": "rock"},
	6: {"body": Color(0.6, 0.15, 0.08), "accent": Color(0.9, 0.35, 0.08), "detail": Color(1.0, 0.75, 0.15), "name": "lava"},
	7: {"body": Color(0.6, 0.5, 0.3), "accent": Color(0.5, 0.42, 0.22), "detail": Color(0.85, 0.75, 0.4), "name": "desert"},
	8: {"body": Color(0.32, 0.38, 0.52), "accent": Color(0.22, 0.28, 0.42), "detail": Color(0.45, 0.72, 1.0), "name": "fleet"},
	9: {"body": Color(0.12, 0.4, 0.42), "accent": Color(0.18, 0.52, 0.48), "detail": Color(0.35, 0.85, 0.9), "name": "aqua"},
	10: {"body": Color(0.18, 0.12, 0.28), "accent": Color(0.0, 0.7, 0.42), "detail": Color(0.0, 1.0, 0.8), "name": "cyber"},
}

func _ready() -> void:
	scale = Vector2(1.15, 1.15)
	shoot_timer = randf_range(0.5, shoot_interval)
	add_to_group("enemies")
	_player = get_tree().get_first_node_in_group("player")
	_palette = PALETTES.get(GameManager.current_level, PALETTES[1])
	if enemy_type == "gunship":
		_hover_y = randf_range(100, 350)
	if enemy_type == "mini_boss":
		_hover_y = randf_range(120, 250)
	z_index = 10
	var level_sprites: Dictionary = SPRITE_MAP.get(GameManager.current_level, {})
	var sprite_path: String = level_sprites.get(enemy_type, "")
	if sprite_path != "":
		var tex := GameManager.load_texture(sprite_path)
		if tex:
			_sprite_node = Sprite2D.new()
			_sprite_node.texture = tex
			_sprite_node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			_sprite_node.scale = Vector2(1.625, 1.625)
			if GameManager.current_level == 1:
				_sprite_node.modulate = Color(1.2, 1.2, 1.2, 1.0)
			else:
				_sprite_node.modulate = Color(1.1, 1.1, 1.1, 1.0)
			add_child(_sprite_node)

func _process(delta: float) -> void:
	_time += delta
	if wave_move:
		position += wave_dir * speed * delta
		var perp := Vector2(-wave_dir.y, wave_dir.x)
		position += perp * cos(_time * wave_frequency + global_position.x * 0.005) * wave_amplitude * delta
	else:
		match enemy_type:
			"scout":
				position += move_dir * speed * delta
			"diver":
				_move_diver(delta)
			"gunship":
				_move_gunship(delta)
			"turret":
				var stars := get_tree().current_scene.get_node_or_null("Stars")
				var mult: float = stars._speed_mult if stars else 1.0
				position.y += 20.0 * mult * delta
			"carrier":
				position.y += speed * 0.5 * delta
			"mini_boss":
				_move_gunship(delta)
			"kamikaze":
				_move_kamikaze(delta)
			_:
				position += move_dir * speed * delta

	if not _sprite_node and (enemy_type == "kamikaze" or enemy_type == "mini_boss"):
		queue_redraw()

	if position.y > get_viewport_rect().size.y + 120 or position.y < -100 or position.x < -100 or position.x > 820:
		queue_free()
		return

	if enemy_type != "kamikaze" and position.y > 0 and position.y < 1000:
		shoot_timer -= delta
		if shoot_timer <= 0.0:
			shoot_timer = shoot_interval
			_shoot()

func _move_diver(delta: float) -> void:
	if _player and is_instance_valid(_player):
		var dir := (global_position.direction_to(_player.global_position)).normalized()
		position += dir * speed * delta
	else:
		position.y += speed * delta

func _move_gunship(delta: float) -> void:
	if position.y < _hover_y:
		position.y += speed * delta
	else:
		position.x += _strafe_dir * speed * 0.4 * delta
		if position.x > 650:
			_strafe_dir = -1.0
		elif position.x < 70:
			_strafe_dir = 1.0

func _move_kamikaze(delta: float) -> void:
	if _player and is_instance_valid(_player):
		var dir := global_position.direction_to(_player.global_position).normalized()
		position += dir * speed * 1.3 * delta
	else:
		position.y += speed * delta

func _shoot() -> void:
	match enemy_type:
		"scout":
			_fire_straight()
		"diver":
			pass
		"gunship":
			_fire_aimed()
		"turret":
			_fire_aimed()
		"carrier":
			_fire_spread()
		"mini_boss":
			if randi() % 2 == 0:
				_fire_spread()
			else:
				_fire_aimed()
		_:
			_fire_straight()

func _fire_straight() -> void:
	var b := BULLET_SCENE.instantiate()
	b.position = global_position + Vector2(0, 16)
	b.velocity = Vector2.DOWN * 300.0 * _bullet_speed_mod()
	get_tree().current_scene.add_child(b)

func _fire_aimed() -> void:
	if not _player or not is_instance_valid(_player):
		_fire_straight()
		return
	var dir := global_position.direction_to(_player.global_position).normalized()
	var b := BULLET_SCENE.instantiate()
	b.position = global_position + Vector2(0, 16)
	b.velocity = dir * 320.0 * _bullet_speed_mod()
	get_tree().current_scene.add_child(b)

func _fire_spread() -> void:
	for angle in [-0.3, 0.0, 0.3]:
		var b := BULLET_SCENE.instantiate()
		b.position = global_position + Vector2(0, 16)
		b.velocity = Vector2.DOWN.rotated(angle) * 280.0 * _bullet_speed_mod()
		get_tree().current_scene.add_child(b)

func _bullet_speed_mod() -> float:
	return float(GameManager.get_difficulty_multipliers()["bullet_speed"])

func take_hit(damage: int) -> void:
	hp -= damage
	modulate = Color(3, 3, 3, 1)
	get_tree().create_timer(0.05).timeout.connect(_reset_flash)
	if hp <= 0:
		_spawn_explosion()
		_try_drop_pickup()
		GameManager.add_score(_get_score_value())
		GameManager.level_enemies_destroyed += 1
		if enemy_type == "mini_boss":
			var main := get_tree().current_scene
			if main.has_method("screen_shake"):
				main.screen_shake(10.0)
		destroyed.emit()
		queue_free()

func _spawn_explosion() -> void:
	var exp := EXPLOSION_SCENE.instantiate()
	exp.position = global_position
	get_tree().current_scene.add_child(exp)

func _try_drop_pickup() -> void:
	if not GameManager.test_mode:
		var drop_chance := _get_drop_chance()
		if randf() > drop_chance:
			return
	var pickup := PICKUP_SCENE.instantiate()
	pickup.position = global_position
	pickup.setup(_get_pickup_type())
	get_tree().current_scene.call_deferred("add_child", pickup)

func _get_drop_chance() -> float:
	match enemy_type:
		"carrier": return 1.0
		"mini_boss": return 1.0
		"gunship": return 0.3
		"turret": return 0.25
		"scout": return 0.1
		"diver": return 0.08
		"kamikaze": return 0.0
		_: return 0.1

func _get_pickup_type() -> int:
	var roll := randf()
	if enemy_type == "carrier":
		if roll < 0.15:
			return 0  # BEAM
		elif roll < 0.30:
			return 1  # STRAIGHT
		elif roll < 0.45:
			return 2  # SPREAD
		elif roll < 0.60:
			return 3  # MISSILE
		elif roll < 0.75:
			return 4  # SHIELD
		elif roll < 0.90:
			return 5  # HEALTH
		else:
			return 6  # SPECIAL
	else:
		if roll < 0.20:
			return 0  # BEAM
		elif roll < 0.40:
			return 1  # STRAIGHT
		elif roll < 0.55:
			return 2  # SPREAD
		elif roll < 0.70:
			return 3  # MISSILE
		elif roll < 0.85:
			return 5  # HEALTH
		else:
			return 4  # SHIELD

func _reset_flash() -> void:
	if is_instance_valid(self):
		modulate = Color.WHITE

func _get_score_value() -> int:
	match enemy_type:
		"scout": return 100
		"diver": return 150
		"gunship": return 200
		"turret": return 175
		"carrier": return 300
		"mini_boss": return 500
		"kamikaze": return 125
		_: return 100

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") and area.has_method("take_damage"):
		area.take_damage(20.0)

func _draw() -> void:
	if _sprite_node:
		return
	var body_c: Color = _palette.get("body", Color.RED)
	var accent_c: Color = _palette.get("accent", Color.DARK_RED)
	var detail_c: Color = _palette.get("detail", Color.WHITE)
	match enemy_type:
		"scout": _draw_scout(body_c, accent_c, detail_c)
		"diver": _draw_diver_shape(body_c, accent_c, detail_c)
		"gunship": _draw_gunship(body_c, accent_c, detail_c)
		"turret": _draw_turret(body_c, accent_c, detail_c)
		"carrier": _draw_carrier(body_c, accent_c, detail_c)
		"kamikaze": _draw_kamikaze(body_c, accent_c, detail_c)
		"mini_boss": _draw_mini_boss(body_c, accent_c, detail_c)
		_: _draw_scout(body_c, accent_c, detail_c)

func _draw_scout(body_c: Color, accent_c: Color, detail_c: Color) -> void:
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -12), Vector2(10, 4), Vector2(8, 10),
		Vector2(3, 14), Vector2(-3, 14), Vector2(-8, 10), Vector2(-10, 4)
	]), body_c)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-8, 2), Vector2(-16, 10), Vector2(-14, 12), Vector2(-8, 8)
	]), accent_c)
	draw_colored_polygon(PackedVector2Array([
		Vector2(8, 2), Vector2(16, 10), Vector2(14, 12), Vector2(8, 8)
	]), accent_c)
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -8), Vector2(-4, 0), Vector2(0, 2), Vector2(4, 0)
	]), detail_c)

func _draw_diver_shape(body_c: Color, accent_c: Color, detail_c: Color) -> void:
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -16), Vector2(6, -4), Vector2(8, 8),
		Vector2(4, 16), Vector2(-4, 16), Vector2(-8, 8), Vector2(-6, -4)
	]), body_c)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-6, 0), Vector2(-14, 8), Vector2(-10, 10), Vector2(-6, 6)
	]), accent_c)
	draw_colored_polygon(PackedVector2Array([
		Vector2(6, 0), Vector2(14, 8), Vector2(10, 10), Vector2(6, 6)
	]), accent_c)
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -12), Vector2(-3, -4), Vector2(3, -4)
	]), detail_c)

func _draw_gunship(body_c: Color, accent_c: Color, detail_c: Color) -> void:
	draw_colored_polygon(PackedVector2Array([
		Vector2(-14, -8), Vector2(14, -8), Vector2(16, 4),
		Vector2(10, 14), Vector2(-10, 14), Vector2(-16, 4)
	]), body_c)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-16, -2), Vector2(-22, 4), Vector2(-22, 10), Vector2(-16, 8)
	]), accent_c)
	draw_colored_polygon(PackedVector2Array([
		Vector2(16, -2), Vector2(22, 4), Vector2(22, 10), Vector2(16, 8)
	]), accent_c)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-6, -6), Vector2(6, -6), Vector2(6, 2), Vector2(-6, 2)
	]), accent_c)
	draw_circle(Vector2(0, -2), 3.0, detail_c)

func _draw_turret(body_c: Color, accent_c: Color, detail_c: Color) -> void:
	draw_colored_polygon(PackedVector2Array([
		Vector2(-12, -12), Vector2(12, -12), Vector2(14, -8),
		Vector2(14, 12), Vector2(-14, 12), Vector2(-14, -8)
	]), body_c)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-3, -18), Vector2(3, -18), Vector2(3, -8), Vector2(-3, -8)
	]), accent_c)
	draw_circle(Vector2(0, 2), 5.0, accent_c)
	draw_circle(Vector2(0, 2), 3.0, detail_c)

func _draw_carrier(body_c: Color, accent_c: Color, detail_c: Color) -> void:
	draw_colored_polygon(PackedVector2Array([
		Vector2(-6, -22), Vector2(6, -22), Vector2(20, -8),
		Vector2(22, 10), Vector2(16, 22), Vector2(-16, 22),
		Vector2(-22, 10), Vector2(-20, -8)
	]), body_c)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-18, 0), Vector2(-26, 8), Vector2(-24, 16), Vector2(-18, 12)
	]), accent_c)
	draw_colored_polygon(PackedVector2Array([
		Vector2(18, 0), Vector2(26, 8), Vector2(24, 16), Vector2(18, 12)
	]), accent_c)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-8, -14), Vector2(8, -14), Vector2(10, -4),
		Vector2(8, 4), Vector2(-8, 4), Vector2(-10, -4)
	]), accent_c)
	draw_circle(Vector2(0, -5), 4.0, detail_c)
	draw_circle(Vector2(-6, 12), 2.0, detail_c)
	draw_circle(Vector2(6, 12), 2.0, detail_c)

func _draw_kamikaze(body_c: Color, accent_c: Color, detail_c: Color) -> void:
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -10), Vector2(8, 0), Vector2(6, 8),
		Vector2(0, 12), Vector2(-6, 8), Vector2(-8, 0)
	]), body_c)
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -6), Vector2(4, 0), Vector2(0, 4), Vector2(-4, 0)
	]), detail_c)
	var glow_alpha := 0.3 + sin(_time * 8.0) * 0.2
	draw_circle(Vector2(0, 0), 6.0, Color(detail_c.r, detail_c.g, detail_c.b, glow_alpha))

func _draw_mini_boss(body_c: Color, accent_c: Color, detail_c: Color) -> void:
	draw_colored_polygon(PackedVector2Array([
		Vector2(-8, -28), Vector2(8, -28), Vector2(24, -12),
		Vector2(28, 12), Vector2(20, 28), Vector2(-20, 28),
		Vector2(-28, 12), Vector2(-24, -12)
	]), body_c)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-24, -4), Vector2(-36, 8), Vector2(-34, 18), Vector2(-24, 14)
	]), accent_c)
	draw_colored_polygon(PackedVector2Array([
		Vector2(24, -4), Vector2(36, 8), Vector2(34, 18), Vector2(24, 14)
	]), accent_c)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-10, -20), Vector2(10, -20), Vector2(12, -6),
		Vector2(10, 6), Vector2(-10, 6), Vector2(-12, -6)
	]), accent_c)
	draw_circle(Vector2(0, -7), 5.0, detail_c)
	var glow := 0.4 + sin(_time * 3.0) * 0.2
	draw_circle(Vector2(-10, 16), 3.0, Color(detail_c.r, detail_c.g, detail_c.b, glow))
	draw_circle(Vector2(10, 16), 3.0, Color(detail_c.r, detail_c.g, detail_c.b, glow))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-6, 24), Vector2(-4, 32), Vector2(4, 32), Vector2(6, 24)
	]), accent_c)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-18, 24), Vector2(-16, 30), Vector2(-10, 30), Vector2(-12, 24)
	]), accent_c)
	draw_colored_polygon(PackedVector2Array([
		Vector2(12, 24), Vector2(10, 30), Vector2(16, 30), Vector2(18, 24)
	]), accent_c)

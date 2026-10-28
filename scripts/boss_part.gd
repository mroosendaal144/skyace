extends Area2D

signal part_destroyed

const BULLET_SCENE := preload("res://scenes/enemy_bullet.tscn")
const EXPLOSION_SCENE := preload("res://scenes/explosion.tscn")
const PICKUP_SCENE := preload("res://scenes/pickup.tscn")

var hp := 20.0
var max_hp := 20.0
var part_type := "turret"
var part_style := "turret"
var fire_rate := 2.0
var attacks: Array = []
var _time := 0.0
var _attack_timer := 0.0
var _player: Node2D = null
var _dir := 1.0
var _body_c := Color(0.45, 0.45, 0.5)
var _accent_c := Color(0.65, 0.65, 0.7)
var _glow_c := Color(0.9, 0.3, 0.15)
var _sprite_node: Sprite2D = null

const PART_SPRITES := {
	3: {"wing_left": "res://sprites/level_03/boss_wing_left.png", "wing_right": "res://sprites/level_03/boss_wing_right.png"},
	5: {"turret": "res://sprites/level_05/boss_turret.png"},
	7: {"segment": "res://sprites/level_07/boss_segment.png"},
	9: {"tentacle": "res://sprites/level_09/boss_tentacle.png"},
	10: {"armor": "res://sprites/level_10/boss_armor.png"},
}

func _ready() -> void:
	add_to_group("enemies")
	_player = get_tree().get_first_node_in_group("player")
	_attack_timer = randf_range(0.5, fire_rate)
	_dir = -1.0 if position.x < 0 else 1.0
	var lvl := GameManager.current_level
	if lvl == 6:
		_body_c = Color(0.55, 0.25, 0.12)
		_glow_c = Color(1.0, 0.5, 0.1)
	elif lvl == 7:
		_body_c = Color(0.5, 0.42, 0.28)
		_glow_c = Color(0.9, 0.7, 0.2)
	elif lvl == 9:
		_body_c = Color(0.2, 0.4, 0.45)
		_accent_c = Color(0.3, 0.55, 0.55)
		_glow_c = Color(0.3, 0.9, 0.9)
	elif lvl == 10:
		_body_c = Color(0.2, 0.18, 0.3)
		_accent_c = Color(0.15, 0.5, 0.35)
		_glow_c = Color(0.0, 1.0, 0.7)

func setup(config: Dictionary) -> void:
	part_type = config.get("type", "turret")
	part_style = config.get("style", part_type)
	hp = float(config.get("hp", 20))
	max_hp = hp
	fire_rate = float(config.get("fire_rate", 99.0))
	attacks = config.get("attacks", [])
	var offset: Array = config.get("offset", [0, 0])
	position = Vector2(float(offset[0]), float(offset[1]))
	_load_sprite(config)

func _process(delta: float) -> void:
	_time += delta
	if attacks.size() > 0:
		_attack_timer -= delta
		if _attack_timer <= 0.0:
			_attack_timer = fire_rate
			_fire()
	queue_redraw()

func _fire() -> void:
	var attack: String = attacks[randi() % attacks.size()]
	var spd := 260.0 * float(GameManager.get_difficulty_multipliers()["bullet_speed"])
	match attack:
		"aimed":
			if _player and is_instance_valid(_player):
				var dir := global_position.direction_to(_player.global_position).normalized()
				_spawn_bullet(dir * spd)
			else:
				_spawn_bullet(Vector2.DOWN * spd)
		"spread":
			for angle in [-0.25, 0.0, 0.25]:
				_spawn_bullet(Vector2.DOWN.rotated(angle) * spd)
		_:
			_spawn_bullet(Vector2.DOWN * spd)

func _spawn_bullet(vel: Vector2) -> void:
	if not is_instance_valid(self):
		return
	var b := BULLET_SCENE.instantiate()
	b.position = global_position
	b.velocity = vel
	get_tree().current_scene.add_child(b)

func take_hit(damage: int) -> void:
	hp -= damage
	modulate = Color(3, 3, 3, 1)
	get_tree().create_timer(0.05).timeout.connect(_reset_flash)
	if hp <= 0.0:
		_explode()

func _explode() -> void:
	var exp := EXPLOSION_SCENE.instantiate()
	exp.position = global_position
	get_tree().current_scene.add_child(exp)
	var pickup := PICKUP_SCENE.instantiate()
	pickup.position = global_position
	var types := [0, 1, 2, 3, 4, 5, 6]
	pickup.setup(types[randi() % types.size()])
	get_tree().current_scene.call_deferred("add_child", pickup)
	part_destroyed.emit()
	queue_free()

func _reset_flash() -> void:
	if is_instance_valid(self):
		modulate = Color.WHITE

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") and area.has_method("take_damage"):
		area.take_damage(15.0)

func _load_sprite(config: Dictionary) -> void:
	var lvl := GameManager.current_level
	var sprite_key: String = config.get("sprite", "")
	if sprite_key == "" and PART_SPRITES.has(lvl):
		var level_parts: Dictionary = PART_SPRITES[lvl]
		# Try style-specific key first, then generic type
		if level_parts.has(part_style):
			sprite_key = level_parts[part_style]
		elif level_parts.has(part_type):
			sprite_key = level_parts[part_type]
	if sprite_key == "":
		return
	var tex := GameManager.load_texture(sprite_key)
	if tex:
		_sprite_node = Sprite2D.new()
		_sprite_node.texture = tex
		_sprite_node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_sprite_node.modulate = Color(1.1, 1.1, 1.1, 1.0)
		add_child(_sprite_node)
		var tex_size := _sprite_node.texture.get_size()
		var shape := $Shape.shape as CircleShape2D
		shape.radius = maxf(tex_size.x, tex_size.y) * 0.4

func _draw() -> void:
	if _sprite_node:
		return
	var hp_pct := hp / max_hp
	match part_style:
		"turret": _draw_turret_style(hp_pct)
		"wing": _draw_wing_style(hp_pct)
		"armor": _draw_armor_style(hp_pct)
		"segment": _draw_segment_style(hp_pct)
		"tentacle": _draw_tentacle_style(hp_pct)
		_: _draw_turret_style(hp_pct)

func _draw_turret_style(hp_pct: float) -> void:
	draw_circle(Vector2.ZERO, 12.0, _body_c)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-3, -2), Vector2(-3, 16), Vector2(3, 16), Vector2(3, -2)
	]), _accent_c)
	draw_circle(Vector2.ZERO, 6.0, _accent_c)
	var pulse := 0.5 + sin(_time * 5.0) * 0.3
	draw_circle(Vector2.ZERO, 4.0, Color(_glow_c.r, _glow_c.g, _glow_c.b, pulse))
	if hp_pct < 0.5:
		var smoke := 0.2 + sin(_time * 8.0) * 0.1
		draw_circle(Vector2(randf_range(-3, 3), randf_range(-3, 3)), 5.0, Color(0.3, 0.3, 0.3, smoke))

func _draw_wing_style(hp_pct: float) -> void:
	var d := _dir
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -10), Vector2(22 * d, -6), Vector2(28 * d, 2),
		Vector2(20 * d, 12), Vector2(0, 8)
	]), _body_c)
	draw_colored_polygon(PackedVector2Array([
		Vector2(4 * d, -4), Vector2(18 * d, -2), Vector2(18 * d, 4), Vector2(4 * d, 4)
	]), _accent_c)
	var pulse := 0.6 + sin(_time * 6.0) * 0.3
	draw_circle(Vector2(15 * d, 0), 4.0, Color(_glow_c.r, _glow_c.g, _glow_c.b, pulse * 0.5))
	if hp_pct < 0.4:
		var spark := sin(_time * 12.0) * 0.4
		draw_circle(Vector2(10 * d, 2), 3.0, Color(1.0, 0.8, 0.2, maxf(spark, 0.0)))

func _draw_armor_style(hp_pct: float) -> void:
	draw_colored_polygon(PackedVector2Array([
		Vector2(-14, -18), Vector2(14, -18), Vector2(16, 18), Vector2(-16, 18)
	]), _body_c)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-10, -14), Vector2(10, -14), Vector2(10, 14), Vector2(-10, 14)
	]), Color(_body_c.r + 0.08, _body_c.g + 0.08, _body_c.b + 0.08))
	for ry in [-10, 10]:
		for rx in [-6, 6]:
			draw_circle(Vector2(rx, ry), 1.5, _accent_c)
	var bar_w := 24.0 * hp_pct
	draw_rect(Rect2(-12, -21, 24, 3), Color(0.2, 0.2, 0.2, 0.5))
	draw_rect(Rect2(-12, -21, bar_w, 3), Color(0.2, 0.8, 0.3, 0.7))
	if hp_pct < 0.3:
		var crack_a := 0.3 + sin(_time * 6.0) * 0.15
		draw_line(Vector2(-8, -12), Vector2(4, 8), Color(0.9, 0.5, 0.1, crack_a), 1.5)

func _draw_segment_style(hp_pct: float) -> void:
	draw_colored_polygon(PackedVector2Array([
		Vector2(-16, -12), Vector2(16, -12), Vector2(20, 0),
		Vector2(16, 12), Vector2(-16, 12), Vector2(-20, 0)
	]), _body_c)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-10, -7), Vector2(10, -7), Vector2(12, 0),
		Vector2(10, 7), Vector2(-10, 7), Vector2(-12, 0)
	]), _accent_c)
	var pulse := 0.4 + sin(_time * 4.0) * 0.2
	draw_circle(Vector2.ZERO, 4.0, Color(_glow_c.r, _glow_c.g, _glow_c.b, pulse))
	if hp_pct < 0.5:
		var smoke := 0.15 + sin(_time * 10.0) * 0.1
		draw_circle(Vector2(randf_range(-4, 4), -8), 4.0, Color(0.3, 0.3, 0.3, smoke))

func _draw_tentacle_style(hp_pct: float) -> void:
	var pts_l := PackedVector2Array()
	var pts_r := PackedVector2Array()
	for i in 10:
		var t := float(i) / 9.0
		var wave := sin(_time * 3.5 + t * 4.0) * (4.0 + t * 8.0)
		var w := lerpf(6.0, 2.0, t)
		pts_l.append(Vector2(wave - w, t * 45.0 - 5.0))
		pts_r.append(Vector2(wave + w, t * 45.0 - 5.0))
	var combined := PackedVector2Array()
	combined.append_array(pts_l)
	var rev := PackedVector2Array()
	for i in range(pts_r.size() - 1, -1, -1):
		rev.append(pts_r[i])
	combined.append_array(rev)
	draw_colored_polygon(combined, _body_c)
	var sucker_a := 0.4 + sin(_time * 5.0) * 0.2
	for i in range(2, 8, 2):
		var t := float(i) / 9.0
		var wx := sin(_time * 3.5 + t * 4.0) * (4.0 + t * 8.0)
		draw_circle(Vector2(wx, t * 45.0 - 5.0), 2.0, Color(_accent_c.r, _accent_c.g, _accent_c.b, sucker_a))

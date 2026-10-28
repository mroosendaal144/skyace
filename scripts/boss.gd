extends Area2D

signal defeated
signal health_changed(current: float, maximum: float)

const BULLET_SCENE := preload("res://scenes/enemy_bullet.tscn")
const EXPLOSION_SCENE := preload("res://scenes/explosion.tscn")
const BOSS_PART_SCENE := preload("res://scenes/boss_part.tscn")

var boss_name := "Boss"
var max_hp := 100.0
var hp := 100.0
var phases: Array[Dictionary] = []
var current_phase := 0
var speed := 80.0
var _player: Node2D = null
var _attack_timer := 0.0
var _move_dir := 1.0
var _time := 0.0
var _entering := true
var _target_y := 120.0
var active := false

var _part_system := ""
var _parts_config: Array = []
var _parts: Array[Node] = []
var _active_parts := 0
var _sprite_node: Sprite2D = null

const BOSS_SPRITES := {
	1: "res://sprites/level_01/boss_processed.png",
	2: "res://sprites/level_02/boss_processed.png",
}

func _ready() -> void:
	add_to_group("enemies")
	_player = get_tree().get_first_node_in_group("player")
	position = Vector2(360, -100)
	z_index = 10
	_spawn_parts()
	var sprite_path: String = BOSS_SPRITES.get(GameManager.current_level, "")
	if sprite_path != "":
		var tex := GameManager.load_texture(sprite_path)
		if tex:
			_sprite_node = Sprite2D.new()
			_sprite_node.texture = tex
			_sprite_node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			_sprite_node.scale = Vector2(2.0, 2.0)
			_sprite_node.modulate = Color(1.1, 1.1, 1.1, 1.0)
			add_child(_sprite_node)
			for child in get_children():
				if child is Polygon2D:
					child.visible = false
			var shape := $Shape.shape as RectangleShape2D
			shape.size = Vector2(320, 200)

func setup(config: Dictionary) -> void:
	boss_name = config.get("name", "Boss")
	_part_system = config.get("part_system", "")
	_parts_config = config.get("parts", [])
	var phase_data: Array = config.get("phases", [])
	max_hp = 0.0
	phases.clear()
	for p in phase_data:
		var phase_hp: float = float(p.get("hp", 100))
		max_hp += phase_hp
		phases.append({
			"hp_threshold": max_hp - phase_hp,
			"attacks": p.get("attacks", ["spread"]),
			"bullet_speed": float(p.get("bullet_speed", 300)),
			"fire_rate": float(p.get("fire_rate", 1.5)),
		})
	hp = max_hp
	health_changed.emit(hp, max_hp)
	var diff := GameManager.get_difficulty_multipliers()
	max_hp *= float(diff["enemy_hp"])
	hp = max_hp

func _spawn_parts() -> void:
	_parts.clear()
	_active_parts = 0
	for pc in _parts_config:
		var part := BOSS_PART_SCENE.instantiate()
		part.setup(pc)
		part.part_destroyed.connect(_on_part_destroyed)
		add_child(part)
		_parts.append(part)
		_active_parts += 1

func activate() -> void:
	active = true
	_entering = true

func _process(delta: float) -> void:
	if not active:
		return
	_time += delta
	if _entering:
		position.y = move_toward(position.y, _target_y, 100.0 * delta)
		if absf(position.y - _target_y) < 2.0:
			_entering = false
		return

	var spd := speed
	if _part_system == "wing" and _active_parts == 0:
		spd *= 1.4
	position.x += _move_dir * spd * delta
	if position.x > 580:
		_move_dir = -1.0
	elif position.x < 140:
		_move_dir = 1.0

	_attack_timer -= delta
	if _attack_timer <= 0.0 and current_phase < phases.size():
		var phase := phases[current_phase]
		_attack_timer = phase["fire_rate"]
		var atks: Array = phase["attacks"]
		var attack: String = atks[randi() % atks.size()]
		_do_attack(attack, phase["bullet_speed"])

func _do_attack(attack_name: String, bullet_speed: float) -> void:
	var bspeed: float = bullet_speed * float(GameManager.get_difficulty_multipliers()["bullet_speed"])
	match attack_name:
		"spread":
			_attack_spread(bspeed)
		"aimed":
			_attack_aimed(bspeed)
		"circle":
			_attack_circle(bspeed)
		"barrage":
			_attack_barrage(bspeed)
		"sweep":
			_attack_sweep(bspeed)
		_:
			_attack_spread(bspeed)

func _attack_spread(spd: float) -> void:
	for angle in [-0.4, -0.2, 0.0, 0.2, 0.4]:
		_spawn_bullet(Vector2.DOWN.rotated(angle) * spd)

func _attack_aimed(spd: float) -> void:
	if not _player or not is_instance_valid(_player):
		_attack_spread(spd)
		return
	var dir := global_position.direction_to(_player.global_position).normalized()
	for offset in [-0.1, 0.0, 0.1]:
		_spawn_bullet(dir.rotated(offset) * spd)

func _attack_circle(spd: float) -> void:
	var count := 12
	for i in count:
		var angle := TAU * i / count
		_spawn_bullet(Vector2.RIGHT.rotated(angle) * spd * 0.8)

func _attack_barrage(spd: float) -> void:
	for i in 5:
		var delay := i * 0.1
		get_tree().create_timer(delay).timeout.connect(
			func(): _spawn_bullet(Vector2.DOWN * spd * (0.9 + randf() * 0.2) + Vector2(randf_range(-50, 50), 0))
		)

func _attack_sweep(spd: float) -> void:
	for i in 8:
		var angle := -0.6 + 1.2 * i / 7.0
		var delay := i * 0.08
		get_tree().create_timer(delay).timeout.connect(
			func(): _spawn_bullet(Vector2.DOWN.rotated(angle) * spd)
		)

func _spawn_bullet(vel: Vector2) -> void:
	if not is_instance_valid(self):
		return
	var b := BULLET_SCENE.instantiate()
	b.position = global_position + Vector2(0, 40)
	b.velocity = vel
	get_tree().current_scene.add_child(b)

func take_hit(damage: int) -> void:
	if not active or _entering:
		return
	var actual_damage := damage
	if _part_system == "armor":
		if _active_parts > 0:
			actual_damage = maxi(int(float(damage) * 0.4), 1)
		else:
			actual_damage = int(float(damage) * 1.5)
	hp -= actual_damage
	modulate = Color(3, 3, 3, 1)
	get_tree().create_timer(0.05).timeout.connect(_reset_flash)
	health_changed.emit(hp, max_hp)

	if current_phase < phases.size() - 1:
		var next_threshold: float = phases[current_phase + 1].get("hp_threshold", 0.0)
		if hp <= max_hp - next_threshold:
			current_phase += 1

	if hp <= 0.0:
		for i in 5:
			var exp := EXPLOSION_SCENE.instantiate()
			exp.position = global_position + Vector2(randf_range(-40, 40), randf_range(-30, 30))
			get_tree().current_scene.call_deferred("add_child", exp)
		GameManager.add_score(1000 + GameManager.current_level * 500)
		var main := get_tree().current_scene
		if main.has_method("screen_shake"):
			main.screen_shake(18.0)
		defeated.emit()
		queue_free()

func _on_part_destroyed() -> void:
	_active_parts -= 1
	if _part_system == "wing" and _active_parts == 0:
		speed *= 1.4
	GameManager.add_score(200)
	var main := get_tree().current_scene
	if main.has_method("screen_shake"):
		main.screen_shake(6.0)

func _reset_flash() -> void:
	if is_instance_valid(self):
		modulate = Color.WHITE

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") and area.has_method("take_damage"):
		area.take_damage(30.0)

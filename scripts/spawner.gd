extends Node

signal wave_started(wave_index: int)
signal boss_started(boss_name: String)
signal level_cleared

const ENEMY_SCENE := preload("res://scenes/enemy.tscn")
const BOSS_SCENE := preload("res://scenes/boss.tscn")

var level_data: Dictionary = {}
var waves: Array = []
var boss_config: Dictionary = {}
var wave_index := 0
var level_timer := 0.0
var boss_spawned := false
var boss_defeated := false
var active := false

func load_level(level_number: int) -> void:
	var path := "res://data/levels/level_%02d.json" % level_number
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Could not load level file: " + path)
		return
	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	file.close()
	if err != OK:
		push_error("JSON parse error in " + path)
		return
	level_data = json.data
	waves = level_data.get("waves", [])
	boss_config = level_data.get("boss", {})
	wave_index = 0
	level_timer = 0.0
	boss_spawned = false
	boss_defeated = false
	active = true

func _process(delta: float) -> void:
	if not active:
		return
	level_timer += delta
	while wave_index < waves.size():
		var wave: Dictionary = waves[wave_index]
		var trigger_time: float = float(wave.get("time", 0))
		if level_timer < trigger_time:
			break
		_spawn_wave(wave)
		wave_index += 1

	if wave_index >= waves.size() and not boss_spawned and boss_config.size() > 0:
		_spawn_boss()

func _spawn_wave(wave: Dictionary) -> void:
	var etype: String = wave.get("type", "scout")
	if etype == "checkpoint":
		return
	var count: int = int(wave.get("count", 1))
	var formation: String = wave.get("formation", "line")
	var spd: float = float(wave.get("speed", 200))
	var health: int = int(wave.get("hp", 1))
	var shoot_int: float = float(wave.get("shoot_interval", 2.5))
	var from_side: String = wave.get("side", "top")
	var diff := GameManager.get_difficulty_multipliers()
	health = int(ceilf(health * float(diff["enemy_hp"])))
	wave_started.emit(wave_index)

	var x_positions: Array = wave.get("x_positions", [])
	for i in count:
		var e := ENEMY_SCENE.instantiate()
		e.enemy_type = etype
		e.speed = spd * (1.0 + (GameManager.current_level - 1) * 0.05)
		e.hp = health
		e.shoot_interval = shoot_int

		var pos: Vector2
		if i < x_positions.size():
			pos = Vector2(float(x_positions[i]), -40)
		else:
			pos = _get_formation_position(i, count, formation, from_side)
		e.position = pos

		if from_side == "bottom":
			e.move_dir = Vector2.UP
		elif from_side == "left":
			e.move_dir = Vector2.RIGHT
		elif from_side == "right":
			e.move_dir = Vector2.LEFT

		if formation == "string":
			e.wave_move = true
			if from_side == "left":
				e.wave_dir = Vector2.RIGHT
			elif from_side == "right":
				e.wave_dir = Vector2.LEFT
			else:
				e.wave_dir = Vector2.DOWN
			e.wave_amplitude = randf_range(60.0, 140.0)
			e.wave_frequency = randf_range(1.8, 3.5)

		e.destroyed.connect(_on_enemy_destroyed)
		get_tree().current_scene.call_deferred("add_child", e)

func _get_formation_position(i: int, count: int, formation: String, side: String) -> Vector2:
	var pos := Vector2.ZERO
	match formation:
		"line":
			var spacing := 600.0 / maxf(count - 1, 1)
			pos = Vector2(60 + i * spacing, -40 - i * 12)
		"v":
			var cx := 360.0
			var offset_x := (i - count / 2.0) * 80.0
			var offset_y := absf(i - count / 2.0) * 30.0
			pos = Vector2(cx + offset_x, -40 - offset_y)
		"zigzag":
			var spacing := 600.0 / maxf(count - 1, 1)
			var y_off := -30.0 if i % 2 == 0 else -70.0
			pos = Vector2(60 + i * spacing, y_off)
		"circle":
			var angle := TAU * i / count
			pos = Vector2(360 + cos(angle) * 150, -200 + sin(angle) * 80)
		"column":
			pos = Vector2(randf_range(80, 640), -40 - i * 50)
		"spread":
			var spacing := 500.0 / maxf(count - 1, 1)
			pos = Vector2(110 + i * spacing, -40)
		"swarm":
			pos = Vector2(randf_range(60, 660), randf_range(-120, -40))
		"string":
			match side:
				"left":
					pos = Vector2(-40 - i * 55, randf_range(350, 550))
				"right":
					pos = Vector2(760 + i * 55, randf_range(350, 550))
				_:
					pos = Vector2(-40 - i * 55, randf_range(350, 550))
			return pos
		_:
			pos = Vector2(60 + i * 80, -40)

	match side:
		"left":
			pos = Vector2(-40, 100 + i * 60)
		"right":
			pos = Vector2(760, 100 + i * 60)
		"bottom":
			var spacing := 500.0 / maxf(count - 1, 1)
			pos = Vector2(110 + i * spacing, 1320 + i * 30)
		_:
			pass
	return pos

func _spawn_boss() -> void:
	boss_spawned = true
	boss_started.emit(boss_config.get("name", "Boss"))
	var boss := BOSS_SCENE.instantiate()
	boss.setup(boss_config)
	boss.defeated.connect(_on_boss_defeated)
	boss.health_changed.connect(_on_boss_health_changed)
	get_tree().current_scene.call_deferred("add_child", boss)
	await get_tree().create_timer(0.1).timeout
	boss.activate()

func _on_enemy_destroyed() -> void:
	pass

func _on_boss_defeated() -> void:
	boss_defeated = true
	active = false
	level_cleared.emit()

func _on_boss_health_changed(current: float, maximum: float) -> void:
	var hud := get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("update_boss_health"):
		hud.update_boss_health(current, maximum)

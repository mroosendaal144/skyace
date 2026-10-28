extends Area2D

signal died

const BULLET_SCENE := preload("res://scenes/player_bullet.tscn")
const BEAM_SCENE := preload("res://scenes/player_beam.tscn")
const MISSILE_SCENE := preload("res://scenes/missile.tscn")
const EXPLOSION_SCENE := preload("res://scenes/player_explosion.tscn")
const BLASTWAVE_SCENE := preload("res://scenes/blastwave.tscn")
const MAX_HEALTH := 100.0
const FIRE_INTERVAL := 0.12

const MISSILE_COOLDOWNS := {1: 1.5, 2: 1.2, 3: 0.9}
const MISSILE_COUNTS := {1: 1, 2: 2, 3: 3}

var health := MAX_HEALTH
var shield := 0.0
var max_shield := 50.0
var shield_timer := 0.0
var dragging := false
var _drag_offset := Vector2.ZERO
var fire_timer := 0.0
var missile_timer := 1.0
var invulnerable := false
var _beam: Node2D = null
var _current_weapon := ""
var invuln_timer := 0.0
var alive := true
var _prev_x := 360.0
var _bank_angle := 0.0

func _load_fighter_texture(path: String) -> Texture2D:
	return GameManager.load_texture(path)

func _ready() -> void:
	var vh := get_viewport_rect().size.y
	position = Vector2(360, vh - 230)
	_prev_x = position.x
	$Sprite.texture = _load_fighter_texture(GameManager.selected_fighter)
	_sync_weapon()

func _unhandled_input(event: InputEvent) -> void:
	if not alive:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			dragging = true
			_drag_offset = event.position - position
		else:
			dragging = false
	elif event is InputEventScreenDrag and dragging:
		position = event.position - _drag_offset
		position.x = clampf(position.x, 20, 700)
		position.y = clampf(position.y, 40, get_viewport_rect().size.y - 40)
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				_drag_offset = event.position - position
			else:
				dragging = false
	elif event is InputEventMouseMotion and dragging:
		position = event.position - _drag_offset
		position.x = clampf(position.x, 20, 700)
		position.y = clampf(position.y, 40, get_viewport_rect().size.y - 40)
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			use_special()

func _process(delta: float) -> void:
	if not alive:
		return
	var dx := position.x - _prev_x
	_prev_x = position.x
	var target := clampf(dx * 3.0, -1.0, 1.0)
	_bank_angle = lerpf(_bank_angle, target, 10.0 * delta)
	$Sprite.rotation = 0.0
	$Sprite.scale.x = 1.875
	$Sprite.skew = 0.0
	_sync_weapon()
	if GameManager.weapon_type != "beam":
		fire_timer -= delta
		if fire_timer <= 0.0:
			fire_timer = FIRE_INTERVAL
			_shoot()
	missile_timer -= delta
	if missile_timer <= 0.0:
		var cooldown: float = MISSILE_COOLDOWNS.get(GameManager.missile_level, 1.5)
		missile_timer = cooldown
		_fire_missiles()
	if shield_timer > 0.0:
		shield_timer -= delta
		if shield_timer <= 0.0:
			shield_timer = 0.0
			shield = 0.0
			$ShieldVisual.shield_broke()
	if invulnerable:
		invuln_timer -= delta
		visible = fmod(invuln_timer, 0.15) > 0.075
		if invuln_timer <= 0.0:
			invulnerable = false
			visible = true

func _shoot() -> void:
	match GameManager.weapon_type:
		"straight":
			_shoot_straight()
		"spread":
			_shoot_spread()

func _shoot_straight() -> void:
	var lvl: int = GameManager.weapon_level
	var spacing := 10.0
	var total_w := (lvl - 1) * spacing
	for i in lvl:
		var x_off := -total_w * 0.5 + i * spacing
		_fire_bullet(x_off, 0.0)

func _shoot_spread() -> void:
	match GameManager.weapon_level:
		1:
			_fire_bullet(0.0, 0.0)
		2:
			_fire_bullet(0.0, 0.0)
			_fire_bullet(-10.0, -0.15)
			_fire_bullet(10.0, 0.15)
		3:
			_fire_bullet(0.0, 0.0)
			_fire_bullet(-10.0, -0.2)
			_fire_bullet(10.0, 0.2)
			_fire_bullet(-18.0, -0.35)
			_fire_bullet(18.0, 0.35)
		4:
			_fire_bullet(0.0, 0.0)
			_fire_bullet(-8.0, -0.12)
			_fire_bullet(8.0, 0.12)
			_fire_bullet(-16.0, -0.25)
			_fire_bullet(16.0, 0.25)
			_fire_bullet(-22.0, -0.4)
			_fire_bullet(22.0, 0.4)
		5:
			_fire_bullet(0.0, 0.0)
			_fire_bullet(-8.0, -0.1)
			_fire_bullet(8.0, 0.1)
			_fire_bullet(-14.0, -0.2)
			_fire_bullet(14.0, 0.2)
			_fire_bullet(-20.0, -0.35)
			_fire_bullet(20.0, 0.35)
			_fire_bullet(-26.0, -0.5)
			_fire_bullet(26.0, 0.5)

func _fire_bullet(x_offset: float, angle: float) -> void:
	var b := BULLET_SCENE.instantiate()
	b.position = global_position + Vector2(x_offset, -24)
	b.direction = Vector2.UP.rotated(angle)
	get_tree().current_scene.add_child(b)

func _fire_missiles() -> void:
	var count: int = MISSILE_COUNTS.get(GameManager.missile_level, 1)
	for i in count:
		var m := MISSILE_SCENE.instantiate()
		var spread := (i - (count - 1) / 2.0) * 15.0
		m.position = global_position + Vector2(spread, -20)
		get_tree().current_scene.call_deferred("add_child", m)

func _sync_weapon() -> void:
	var wt := GameManager.weapon_type
	if wt == _current_weapon:
		if _beam and wt == "beam":
			_beam.update_level(GameManager.weapon_level)
		return
	_current_weapon = wt
	if _beam:
		_beam.queue_free()
		_beam = null
	if wt == "beam":
		_beam = BEAM_SCENE.instantiate()
		add_child(_beam)
		_beam.update_level(GameManager.weapon_level)

func use_special() -> void:
	if not alive or GameManager.special_charges <= 0:
		return
	if get_tree().paused:
		return
	GameManager.special_charges -= 1
	GameManager.special_used.emit()
	var wave := BLASTWAVE_SCENE.instantiate()
	wave.setup(global_position)
	get_tree().current_scene.add_child(wave)
	var main := get_tree().current_scene
	if main.has_method("screen_shake"):
		main.screen_shake(15.0)

func take_damage(amount: float) -> void:
	if invulnerable or not alive:
		return
	if shield > 0.0:
		var absorbed := minf(shield, amount)
		shield -= absorbed
		amount -= absorbed
		$ShieldVisual.hit_flash()
		if shield <= 0.0:
			shield_timer = 0.0
			$ShieldVisual.shield_broke()
	if amount > 0.0:
		health -= amount
		$ShieldVisual.damage_flash()
		GameManager.weapon_level = maxi(GameManager.weapon_level - 1, 1)
		GameManager.missile_level = maxi(GameManager.missile_level - 1, 1)
		_current_weapon = ""
	GameManager.reset_chain()
	if health <= 0.0:
		_die()

func _die() -> void:
	alive = false
	visible = false
	if _beam:
		_beam.queue_free()
		_beam = null
		_current_weapon = ""
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	var exp := EXPLOSION_SCENE.instantiate()
	exp.position = global_position
	get_tree().current_scene.add_child(exp)
	var main := get_tree().current_scene
	if main.has_method("screen_shake"):
		main.screen_shake(20.0)
	GameManager.lose_life()
	if GameManager.lives > 0:
		get_tree().create_timer(1.5).timeout.connect(_respawn)
	else:
		died.emit()

func _respawn() -> void:
	health = MAX_HEALTH
	shield = 0.0
	shield_timer = 0.0
	position = Vector2(360, get_viewport_rect().size.y - 230)
	_prev_x = position.x
	_bank_angle = 0.0
	$Sprite.rotation = 0.0
	$Sprite.scale.x = 1.875
	$Sprite.skew = 0.0
	alive = true
	visible = true
	set_deferred("monitorable", true)
	set_deferred("monitoring", true)
	invulnerable = true
	invuln_timer = 2.0
	_current_weapon = ""
	_sync_weapon()

func add_shield(amount: float) -> void:
	shield = minf(shield + amount, max_shield)
	shield_timer = 10.0

func heal(fraction: float) -> void:
	health = minf(health + MAX_HEALTH * fraction, MAX_HEALTH)

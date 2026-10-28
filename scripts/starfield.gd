extends Node2D

@export var level_theme_override := 0
@export var show_mid_layer := true

var level_theme := 1
var _time := 0.0

var _far_tex: Texture2D = null
var _mid_tex: Texture2D = null
var _far_scroll := 0.0
var _mid_scroll := 0.0
var _far_h := 640.0
var _mid_h := 640.0

const W := 720
const FAR_SPEED := 20.0
const MID_SPEED := 40.0
const SPEED_RAMP := 4.0

var _speed_mult := 1.0

func _ready() -> void:
	level_theme = level_theme_override if level_theme_override > 0 else GameManager.current_level
	var bg := get_parent().get_node_or_null("Background") as ColorRect
	if bg:
		bg.color = _bg_color()
	_load_textures()

func _bg_color() -> Color:
	match level_theme:
		1: return Color(0.1, 0.45, 0.65)
		2: return Color(0.35, 0.55, 0.25)
		3: return Color(0.35, 0.38, 0.40)
		4: return Color(0.02, 0.01, 0.04)
		5: return Color(0.01, 0.01, 0.03)
		6: return Color(0.08, 0.03, 0.02)
		7: return Color(0.45, 0.35, 0.18)
		8: return Color(0.02, 0.01, 0.04)
		9: return Color(0.02, 0.06, 0.14)
		10: return Color(0.02, 0.01, 0.03)
		_: return Color(0.04, 0.04, 0.1)

const SHARED_FAR := {5: 4, 8: 4}

func _load_textures() -> void:
	var far_level: int = SHARED_FAR.get(level_theme, level_theme)
	var far_path := "res://textures/backgrounds/bg_%02d_far.png" % far_level
	var mid_path := "res://textures/backgrounds/bg_%02d_mid.png" % level_theme
	var far_tex := GameManager.load_texture(far_path)
	if far_tex:
		_far_tex = far_tex
		_far_h = float(far_tex.get_height())
	if show_mid_layer and ResourceLoader.exists(mid_path):
		var mid_tex := GameManager.load_texture(mid_path)
		if mid_tex:
			_mid_tex = mid_tex
			_mid_h = float(mid_tex.get_height())

func _process(delta: float) -> void:
	_time += delta
	_update_speed_mult()
	_far_scroll = fmod(_far_scroll + FAR_SPEED * _speed_mult * delta, _far_h)
	_mid_scroll = fmod(_mid_scroll + MID_SPEED * _speed_mult * delta, _mid_h)
	queue_redraw()

func _update_speed_mult() -> void:
	var spawner := get_tree().current_scene.get_node_or_null("Spawner")
	if not spawner or spawner.waves.is_empty():
		_speed_mult = 1.0
		return
	var last_wave: Dictionary = spawner.waves[spawner.waves.size() - 1]
	var total_time: float = float(last_wave.get("time", 72))
	var progress := clampf(spawner.level_timer / total_time, 0.0, 1.0)
	_speed_mult = 1.0 + progress * SPEED_RAMP

func _bg_dim() -> Color:
	return Color.WHITE

func _draw() -> void:
	var tint := _bg_dim()
	var vh := get_viewport_rect().size.y
	if _far_tex:
		var copies := ceili(vh / _far_h) + 2
		for i in copies:
			var y := _far_scroll - _far_h + i * _far_h
			draw_texture(_far_tex, Vector2(0, y), tint)
	if _mid_tex:
		var copies := ceili(vh / _mid_h) + 2
		for i in copies:
			var y := _mid_scroll - _mid_h + i * _mid_h
			draw_texture(_mid_tex, Vector2(0, y), tint)

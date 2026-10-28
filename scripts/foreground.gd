extends Node2D

var level_theme := 1
var _near_tex: Texture2D = null
var _near_scroll := 0.0

const NEAR_SPEED := 60.0
const TEX_H := 640.0

func _ready() -> void:
	z_index = 100
	level_theme = GameManager.current_level
	_load_texture()

func _load_texture() -> void:
	var near_path := "res://textures/backgrounds/bg_%02d_near.png" % level_theme
	if not ResourceLoader.exists(near_path):
		return
	var tex := GameManager.load_texture(near_path)
	if tex:
		_near_tex = tex

func _process(delta: float) -> void:
	_near_scroll = fmod(_near_scroll + NEAR_SPEED * delta, TEX_H)
	queue_redraw()

func _draw() -> void:
	if _near_tex:
		for i in 4:
			var y := _near_scroll - TEX_H + i * TEX_H
			draw_texture(_near_tex, Vector2(0, y))

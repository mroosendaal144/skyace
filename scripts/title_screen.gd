extends Node2D

const FIGHTERS := [
	{"name": "INTERCEPTOR", "texture": "res://fighter-png/fighter_start_64.png"},
	{"name": "HEAVY", "texture": "res://fighter-png/fighter2_64.png"},
	{"name": "BOMBER", "texture": "res://fighter-png/fighter3_64.png"},
]

@onready var continue_btn: Button = $UI/ContinueButton
@onready var high_score_label: Label = $UI/HighScoreLabel
@onready var settings_panel: ColorRect = $UI/SettingsPanel

var _select_panel: ColorRect
var _level_panel: ColorRect
var _pending_action := ""
var _test_btn: Button

func _load_fighter_texture(path: String) -> Texture2D:
	return GameManager.load_texture(path)

func _ready() -> void:
	continue_btn.visible = GameManager.unlocked_level > 1
	high_score_label.text = "HIGH SCORE: %d" % GameManager.hi_score
	_style_button($UI/PlayButton)
	_style_button($UI/ContinueButton)
	_style_button($UI/SettingsButton)
	_style_button($UI/SettingsPanel/EasyButton)
	_style_button($UI/SettingsPanel/NormalButton)
	_style_button($UI/SettingsPanel/HardButton)
	_style_button($UI/SettingsPanel/BackButton)
	_style_button($UI/LevelSelectButton)
	_style_button($UI/ExitButton)
	_update_difficulty_display()
	_build_fighter_select()
	_build_level_select()
	_build_test_button()
	_build_version_label()

func _style_button(btn: Button) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.2, 0.35, 0.9)
	style.border_color = Color(0.3, 0.5, 0.8, 0.8)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(8)
	btn.add_theme_stylebox_override("normal", style)
	var hover := style.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.2, 0.3, 0.5, 0.9)
	hover.border_color = Color(0.4, 0.7, 1.0, 1.0)
	btn.add_theme_stylebox_override("hover", hover)
	var pressed := style.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.1, 0.15, 0.25, 0.9)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
	btn.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0))

func _build_fighter_select() -> void:
	_select_panel = ColorRect.new()
	_select_panel.anchor_top = 0.5
	_select_panel.anchor_bottom = 0.5
	_select_panel.offset_left = 60
	_select_panel.offset_top = -325
	_select_panel.offset_right = 660
	_select_panel.offset_bottom = 325
	_select_panel.color = Color(0.08, 0.08, 0.15, 0.95)
	_select_panel.visible = false
	$UI.add_child(_select_panel)

	var title_lbl := Label.new()
	title_lbl.text = "SELECT FIGHTER"
	title_lbl.offset_left = 0
	title_lbl.offset_top = 20
	title_lbl.offset_right = 600
	title_lbl.offset_bottom = 70
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 32)
	title_lbl.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
	title_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_select_panel.add_child(title_lbl)

	var col_width := 200.0
	for i in FIGHTERS.size():
		var f: Dictionary = FIGHTERS[i]
		var cx: float = i * col_width

		var tex := TextureRect.new()
		tex.texture = _load_fighter_texture(f.texture)
		tex.offset_left = cx + 36
		tex.offset_top = 100
		tex.offset_right = cx + 164
		tex.offset_bottom = 228
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_select_panel.add_child(tex)

		var btn := Button.new()
		btn.text = f.name
		btn.offset_left = cx + 15
		btn.offset_top = 250
		btn.offset_right = cx + col_width - 15
		btn.offset_bottom = 310
		btn.add_theme_font_size_override("font_size", 18)
		_style_button(btn)
		btn.pressed.connect(_on_fighter_selected.bind(f.texture))
		_select_panel.add_child(btn)

	var back_btn := Button.new()
	back_btn.text = "BACK"
	back_btn.offset_left = 200
	back_btn.offset_top = 400
	back_btn.offset_right = 400
	back_btn.offset_bottom = 460
	back_btn.add_theme_font_size_override("font_size", 26)
	_style_button(back_btn)
	back_btn.pressed.connect(_on_fighter_back_pressed)
	_select_panel.add_child(back_btn)

func _on_play_pressed() -> void:
	_pending_action = "play"
	_select_panel.visible = true

func _on_continue_pressed() -> void:
	_pending_action = "continue"
	_select_panel.visible = true

func _on_fighter_selected(texture_path: String) -> void:
	GameManager.selected_fighter = texture_path
	GameManager.save_game()
	if _pending_action == "play":
		GameManager.reset_game()
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	elif _pending_action == "continue":
		GameManager.reset_game()
		GameManager.current_level = GameManager.unlocked_level
		get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_fighter_back_pressed() -> void:
	_select_panel.visible = false

func _on_level_select_pressed() -> void:
	_level_panel.visible = true

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_settings_pressed() -> void:
	settings_panel.visible = true

func _on_back_pressed() -> void:
	settings_panel.visible = false

func _on_easy_pressed() -> void:
	GameManager.difficulty = "easy"
	GameManager.save_game()
	_update_difficulty_display()

func _on_normal_pressed() -> void:
	GameManager.difficulty = "normal"
	GameManager.save_game()
	_update_difficulty_display()

func _on_hard_pressed() -> void:
	GameManager.difficulty = "hard"
	GameManager.save_game()
	_update_difficulty_display()

func _update_difficulty_display() -> void:
	var diff := GameManager.difficulty
	var on := Color.WHITE
	var off := Color(0.5, 0.5, 0.5)
	$UI/SettingsPanel/EasyButton.modulate = on if diff == "easy" else off
	$UI/SettingsPanel/NormalButton.modulate = on if diff == "normal" else off
	$UI/SettingsPanel/HardButton.modulate = on if diff == "hard" else off

func _build_level_select() -> void:
	_level_panel = ColorRect.new()
	_level_panel.anchor_top = 0.5
	_level_panel.anchor_bottom = 0.5
	_level_panel.offset_left = 60
	_level_panel.offset_top = -250
	_level_panel.offset_right = 660
	_level_panel.offset_bottom = 250
	_level_panel.color = Color(0.08, 0.08, 0.15, 0.95)
	_level_panel.visible = false
	$UI.add_child(_level_panel)

	var title_lbl := Label.new()
	title_lbl.text = "SELECT LEVEL"
	title_lbl.offset_left = 0
	title_lbl.offset_top = 20
	title_lbl.offset_right = 600
	title_lbl.offset_bottom = 60
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 32)
	title_lbl.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
	title_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_level_panel.add_child(title_lbl)

	var level_names := {
		1: "Ocean", 2: "Small City", 3: "Capital City", 4: "Space Shipyard",
		5: "Asteroid Field", 6: "Lava Planet", 7: "Desert Planet",
		8: "Space Fleet", 9: "Under Water", 10: "Cyberplanet",
	}

	for i in range(1, 11):
		var row := (i - 1) / 2
		var col := (i - 1) % 2
		var btn := Button.new()
		btn.text = "%d: %s" % [i, level_names[i]]
		btn.offset_left = 20 + col * 290
		btn.offset_top = 80 + row * 55
		btn.offset_right = 290 + col * 290
		btn.offset_bottom = 125 + row * 55
		btn.add_theme_font_size_override("font_size", 16)
		_style_button(btn)
		btn.pressed.connect(_on_level_selected.bind(i))
		_level_panel.add_child(btn)

	var back_btn := Button.new()
	back_btn.text = "BACK"
	back_btn.offset_left = 200
	back_btn.offset_top = 370
	back_btn.offset_right = 400
	back_btn.offset_bottom = 420
	back_btn.add_theme_font_size_override("font_size", 26)
	_style_button(back_btn)
	back_btn.pressed.connect(_on_level_back_pressed)
	_level_panel.add_child(back_btn)

func _on_level_selected(level: int) -> void:
	_level_panel.visible = false
	GameManager.reset_game()
	GameManager.test_mode = true
	GameManager.current_level = level
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_level_back_pressed() -> void:
	_level_panel.visible = false

func _build_test_button() -> void:
	_test_btn = Button.new()
	_test_btn.text = "TEST MODE: OFF"
	_test_btn.offset_left = 520
	_test_btn.offset_top = 10
	_test_btn.offset_right = 710
	_test_btn.offset_bottom = 45
	_test_btn.add_theme_font_size_override("font_size", 14)
	_style_button(_test_btn)
	_test_btn.pressed.connect(_on_test_toggle)
	$UI.add_child(_test_btn)
	_update_test_display()

func _build_version_label() -> void:
	var ver: String = ProjectSettings.get_setting("application/config/version", "0.0.0")
	var lbl := Label.new()
	lbl.text = "v%s" % ver
	lbl.anchor_top = 1.0
	lbl.anchor_bottom = 1.0
	lbl.offset_left = 10
	lbl.offset_top = -35
	lbl.offset_right = 200
	lbl.offset_bottom = -5
	lbl.add_theme_font_size_override("font_size", 16)
	lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6, 0.6))
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$UI.add_child(lbl)

func _on_test_toggle() -> void:
	GameManager.test_mode = not GameManager.test_mode
	_update_test_display()

func _update_test_display() -> void:
	if GameManager.test_mode:
		_test_btn.text = "TEST MODE: ON"
		_test_btn.modulate = Color(1.0, 0.4, 0.3)
	else:
		_test_btn.text = "TEST MODE: OFF"
		_test_btn.modulate = Color(0.6, 0.6, 0.6)

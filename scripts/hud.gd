extends CanvasLayer

@onready var score_label: Label = $ScoreLabel
@onready var lives_label: Label = $LivesLabel
@onready var health_bar: ColorRect = $HealthBarBg/HealthBar
@onready var shield_bar: ColorRect = $HealthBarBg/ShieldBar
@onready var shield_timer_display: Control = $HealthBarBg/ShieldTimerDisplay
@onready var boss_bar_bg: ColorRect = $BossBarBg
@onready var boss_bar: ColorRect = $BossBarBg/BossBar
@onready var boss_name_label: Label = $BossBarBg/BossName
@onready var multiplier_label: Label = $MultiplierLabel
@onready var level_label: Label = $LevelLabel
@onready var message_label: Label = $MessageLabel
@onready var special_button: Button = $SpecialButton
@onready var pause_button: Button = $PauseButton
@onready var pause_overlay: ColorRect = $PauseOverlay
@onready var results_overlay: ColorRect = $ResultsOverlay

var _message_timer := 0.0

func _ready() -> void:
	add_to_group("hud")
	boss_bar_bg.visible = false
	message_label.text = ""
	pause_overlay.visible = false
	results_overlay.visible = false
	GameManager.score_updated.connect(_on_score_updated)
	GameManager.life_lost.connect(_on_life_changed)
	GameManager.special_used.connect(_update_special_display)
	_on_life_changed()
	_on_score_updated(GameManager.score, GameManager.chain_multiplier)
	_update_special_display()
	level_label.text = "LEVEL %d" % GameManager.current_level
	_style_button(special_button)
	_style_button(pause_button)

func _process(delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_method("heal"):
		var health_pct: float = player.health / player.MAX_HEALTH
		health_bar.scale.x = health_pct
		var shield_pct: float = player.shield / player.max_shield if player.max_shield > 0 else 0.0
		shield_bar.scale.x = shield_pct
		if player.shield_timer > 0.0:
			shield_timer_display.time_remaining = player.shield_timer
			shield_timer_display.visible = true
		else:
			shield_timer_display.visible = false
	if _message_timer > 0:
		_message_timer -= delta
		if _message_timer <= 0:
			message_label.text = ""

func _on_score_updated(new_score: int, multiplier: int) -> void:
	score_label.text = "SCORE: %d" % new_score
	if multiplier > 1:
		multiplier_label.text = "x%d" % multiplier
		multiplier_label.visible = true
	else:
		multiplier_label.visible = false

func _on_life_changed() -> void:
	lives_label.text = "LIVES: %d" % GameManager.lives

func show_boss_bar(bname: String) -> void:
	boss_bar_bg.visible = true
	boss_name_label.text = bname
	boss_bar.scale.x = 1.0

func hide_boss_bar() -> void:
	boss_bar_bg.visible = false

func update_boss_health(current: float, maximum: float) -> void:
	if maximum > 0:
		boss_bar.scale.x = maxf(current / maximum, 0.0)

func show_message(text: String, duration: float = 2.0) -> void:
	message_label.text = text
	_message_timer = duration

func _update_special_display() -> void:
	special_button.text = "BOMB\n%d" % GameManager.special_charges

func _on_special_pressed() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_method("use_special"):
		player.use_special()
	_update_special_display()

func _on_pause_pressed() -> void:
	get_tree().paused = not get_tree().paused
	pause_overlay.visible = get_tree().paused

func _on_resume_pressed() -> void:
	get_tree().paused = false
	pause_overlay.visible = false

func _on_quit_menu_pressed() -> void:
	get_tree().paused = false
	pause_overlay.visible = false
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")

func show_results(level_score: int, enemies: int) -> void:
	results_overlay.visible = true
	var results_text: Label = results_overlay.get_node("ResultsText")
	results_text.text = "LEVEL %d CLEAR!\n\nSCORE: %d\nENEMIES DESTROYED: %d\nTOTAL SCORE: %d" % [
		GameManager.current_level, level_score, enemies, GameManager.score
	]

func hide_results() -> void:
	results_overlay.visible = false

func _style_button(btn: Button) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.2, 0.35, 0.8)
	style.border_color = Color(0.3, 0.5, 0.8, 0.6)
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(4)
	btn.add_theme_stylebox_override("normal", style)
	var hover := style.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.2, 0.3, 0.5, 0.9)
	btn.add_theme_stylebox_override("hover", hover)
	var pressed := style.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.1, 0.15, 0.25, 0.9)
	btn.add_theme_stylebox_override("pressed", pressed)

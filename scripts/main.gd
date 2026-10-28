extends Node2D

@onready var spawner: Node = $Spawner
@onready var hud: CanvasLayer = $HUD

var _shake_intensity := 0.0

func _ready() -> void:
	GameManager.start_level(GameManager.current_level)
	spawner.load_level(GameManager.current_level)
	spawner.boss_started.connect(_on_boss_started)
	spawner.level_cleared.connect(_on_level_cleared)
	GameManager.game_over.connect(_on_game_over)
	var player := $Player
	if player:
		player.died.connect(_on_player_died)
	hud.show_message("LEVEL %d" % GameManager.current_level, 3.0)

func _process(delta: float) -> void:
	if _shake_intensity > 0.5:
		_shake_intensity *= 0.88
		position = Vector2(randf_range(-_shake_intensity, _shake_intensity), randf_range(-_shake_intensity, _shake_intensity))
	elif _shake_intensity > 0:
		_shake_intensity = 0.0
		position = Vector2.ZERO

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if not get_tree().paused:
			get_tree().paused = true
			hud.pause_overlay.visible = true

func screen_shake(intensity: float = 8.0) -> void:
	_shake_intensity = maxf(_shake_intensity, intensity)

func _on_boss_started(boss_name: String) -> void:
	hud.show_message("WARNING: %s" % boss_name.to_upper(), 2.5)
	hud.show_boss_bar(boss_name)

func _on_level_cleared() -> void:
	hud.hide_boss_bar()
	screen_shake(12.0)
	hud.show_message("LEVEL CLEAR!", 2.0)
	var level_score: int = GameManager.score - GameManager.level_score_start
	var enemies: int = GameManager.level_enemies_destroyed
	await get_tree().create_timer(2.0).timeout
	hud.show_results(level_score, enemies)
	await get_tree().create_timer(3.5).timeout
	hud.hide_results()
	GameManager.advance_level()
	if GameManager.current_level <= GameManager.max_levels:
		get_tree().reload_current_scene()
	else:
		hud.show_message("CONGRATULATIONS! YOU WIN!", 5.0)
		await get_tree().create_timer(5.0).timeout
		get_tree().change_scene_to_file("res://scenes/title_screen.tscn")

func _on_player_died() -> void:
	_show_game_over()

func _on_game_over() -> void:
	_show_game_over()

func _show_game_over() -> void:
	hud.show_message("GAME OVER", 3.0)
	await get_tree().create_timer(3.0).timeout
	hud.show_message("PRESS TO CONTINUE\nSCORE RESETS TO 0", 5.0)
	await get_tree().create_timer(5.0).timeout
	GameManager.score = 0
	GameManager.lives = 3
	GameManager.weapon_type = "spread"
	GameManager.weapon_level = 1
	GameManager.missile_level = 1
	GameManager.special_charges = 2
	GameManager.reset_chain()
	get_tree().reload_current_scene()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().paused = not get_tree().paused
		hud.pause_overlay.visible = get_tree().paused

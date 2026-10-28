extends Node

signal score_updated(new_score: int, multiplier: int)
signal life_lost
signal game_over
signal level_complete
signal special_used

var current_level := 1
var score := 0
var lives := 3
var weapon_type := "spread"
var weapon_level := 1
var missile_level := 1
var special_charges := 2
var test_mode := false
var difficulty := "normal"
var chain_multiplier := 1
var chain_count := 0
var hi_score := 0
var max_levels := 10
var unlocked_level := 1
var level_enemies_destroyed := 0
var level_score_start := 0
var selected_fighter := "res://fighter-png/fighter_start_64.png"

var _next_life_threshold := 50000
const SAVE_PATH := "user://save.cfg"

func _ready() -> void:
	load_save()

func add_score(points: int) -> void:
	chain_count += 1
	if chain_count >= 32:
		chain_multiplier = 8
	elif chain_count >= 16:
		chain_multiplier = 4
	elif chain_count >= 8:
		chain_multiplier = 2
	score += points * chain_multiplier
	if score > hi_score:
		hi_score = score
	score_updated.emit(score, chain_multiplier)
	if score >= _next_life_threshold:
		lives += 1
		_next_life_threshold += 100000
		life_lost.emit()

func reset_chain() -> void:
	chain_count = 0
	chain_multiplier = 1

func lose_life() -> void:
	lives -= 1
	weapon_level = maxi(weapon_level - 1, 1)
	missile_level = maxi(missile_level - 1, 1)
	reset_chain()
	if lives <= 0:
		game_over.emit()
	else:
		life_lost.emit()

func start_level(level: int) -> void:
	current_level = level
	weapon_type = "spread"
	weapon_level = 1
	missile_level = 1
	special_charges = 2
	reset_chain()
	level_enemies_destroyed = 0
	level_score_start = score

func reset_game() -> void:
	score = 0
	lives = _get_starting_lives()
	weapon_type = "spread"
	weapon_level = 1
	missile_level = 1
	special_charges = 2
	current_level = 1
	chain_multiplier = 1
	chain_count = 0
	_next_life_threshold = 50000

func get_difficulty_multipliers() -> Dictionary:
	match difficulty:
		"easy":
			return {"bullet_speed": 0.7, "enemy_hp": 0.75}
		"hard":
			return {"bullet_speed": 1.3, "enemy_hp": 1.25}
		_:
			return {"bullet_speed": 1.0, "enemy_hp": 1.0}

func _get_starting_lives() -> int:
	match difficulty:
		"easy": return 5
		"hard": return 2
		_: return 3

func advance_level() -> void:
	if current_level < max_levels:
		current_level += 1
		if current_level > unlocked_level:
			unlocked_level = current_level
		save_game()
		level_complete.emit()
	else:
		if current_level >= max_levels and unlocked_level < max_levels + 1:
			unlocked_level = max_levels + 1
		save_game()
		level_complete.emit()

func save_game() -> void:
	var config := ConfigFile.new()
	config.set_value("game", "hi_score", hi_score)
	config.set_value("game", "unlocked_level", unlocked_level)
	config.set_value("settings", "difficulty", difficulty)
	config.set_value("settings", "selected_fighter", selected_fighter)
	config.save(SAVE_PATH)

func load_save() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	hi_score = config.get_value("game", "hi_score", 0)
	unlocked_level = config.get_value("game", "unlocked_level", 1)
	difficulty = config.get_value("settings", "difficulty", "normal")
	selected_fighter = config.get_value("settings", "selected_fighter", "res://fighter-png/fighter_start_64.png")

static func load_texture(path: String) -> Texture2D:
	var res = load(path)
	if res is Texture2D:
		return res
	var img := Image.new()
	if img.load(path) == OK:
		return ImageTexture.create_from_image(img)
	return null

static func load_image(path: String) -> Image:
	var res = load(path)
	if res is Texture2D:
		return res.get_image()
	var img := Image.new()
	if img.load(path) == OK:
		return img
	return null

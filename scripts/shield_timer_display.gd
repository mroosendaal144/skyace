extends Control

const RADIUS := 16.0
const RING_WIDTH := 3.0
const MAX_TIME := 10.0
const BG_COLOR := Color(0.1, 0.2, 0.3, 0.5)
const RING_COLOR := Color(0.2, 0.85, 1.0, 0.9)
const WARN_COLOR := Color(1.0, 0.4, 0.2, 0.9)
const TEXT_COLOR := Color(0.9, 0.95, 1.0, 1.0)

var time_remaining := 0.0

func _process(_delta: float) -> void:
	if visible:
		queue_redraw()

func _draw() -> void:
	var center := Vector2(RADIUS + 2, RADIUS + 2)
	draw_circle(center, RADIUS, BG_COLOR)
	var pct := time_remaining / MAX_TIME
	if pct > 0.0:
		var color := RING_COLOR
		if time_remaining <= 3.0:
			var pulse := 0.5 + 0.5 * absf(sin(Time.get_ticks_msec() * 0.005))
			color = WARN_COLOR
			color.a = 0.5 + 0.5 * pulse
		var start_angle := -PI / 2.0
		var end_angle := start_angle + TAU * pct
		draw_arc(center, RADIUS - RING_WIDTH * 0.5, start_angle, end_angle, 32, color, RING_WIDTH, true)
	var text := "%d" % ceili(time_remaining) if time_remaining >= 1.0 else "%.1f" % time_remaining
	var font := ThemeDB.fallback_font
	var font_size := 13
	var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	var text_pos := center - text_size * 0.5 + Vector2(0, text_size.y * 0.3)
	draw_string(font, text_pos, text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, TEXT_COLOR)

extends Node2D

const TARGET_W := 720
const BLEND_HALF := 40

func _ready() -> void:
	var sources := [
		"res://sprites/level_07/bg_01_mid_01.png",
		"res://sprites/level_07/bg_01_mid_02.png",
		"res://sprites/level_07/bg_01_mid_03.png",
	]
	_process_layer(sources, "res://textures/backgrounds/bg_07_far.png")
	get_tree().quit()

func _process_layer(sources: Array, output: String) -> void:
	var tiles: Array[Image] = []
	for path in sources:
		var img := Image.new()
		if img.load(path) != OK:
			print("Failed to load: ", path)
			return
		var scale_f := float(TARGET_W) / float(img.get_width())
		var h := int(img.get_height() * scale_f)
		img.resize(TARGET_W, h, Image.INTERPOLATE_LANCZOS)
		img.convert(Image.FORMAT_RGBA8)
		print("Tile: %dx%d from %s" % [TARGET_W, h, path])
		tiles.append(img)

	var total_h := 0
	for t in tiles:
		total_h += t.get_height()

	var result := Image.create(TARGET_W, total_h, false, Image.FORMAT_RGBA8)

	var y_offset := 0
	for ti in tiles.size():
		var tile := tiles[ti]
		var th := tile.get_height()
		for y in th:
			for x in TARGET_W:
				result.set_pixel(x, y_offset + y, tile.get_pixel(x, y))
		y_offset += th

	y_offset = 0
	for ti in range(tiles.size() - 1):
		y_offset += tiles[ti].get_height()
		_blend_seam(result, y_offset, total_h)

	_blend_wrap(result, total_h)

	print("Final: %dx%d -> %s" % [TARGET_W, total_h, output])
	result.save_png(output)
	print("Saved ", output)

func _blend_seam(img: Image, seam_y: int, total_h: int) -> void:
	var radius := BLEND_HALF
	for dy in range(-radius, radius):
		var y := seam_y + dy
		if y < 0 or y >= total_h:
			continue
		var dist := absf(float(dy)) / float(radius)
		var blur_r := int(lerpf(float(radius), 1.0, dist))
		for x in TARGET_W:
			var r := 0.0
			var g := 0.0
			var b := 0.0
			var count := 0
			for ky in range(-blur_r, blur_r + 1):
				var sy := clampi(y + ky, 0, total_h - 1)
				var c := img.get_pixel(x, sy)
				r += c.r
				g += c.g
				b += c.b
				count += 1
			img.set_pixel(x, y, Color(r / count, g / count, b / count, 1.0))

func _blend_wrap(img: Image, total_h: int) -> void:
	var radius := BLEND_HALF
	for i in radius:
		var dist := float(i) / float(radius)
		var blur_r := int(lerpf(float(radius), 1.0, dist))
		for x in TARGET_W:
			var r_top := 0.0; var g_top := 0.0; var b_top := 0.0
			var r_bot := 0.0; var g_bot := 0.0; var b_bot := 0.0
			var count := 0
			for ky in range(-blur_r, blur_r + 1):
				var sy_top := (i + ky) % total_h
				if sy_top < 0: sy_top += total_h
				var sy_bot := (total_h - 1 - i + ky) % total_h
				if sy_bot < 0: sy_bot += total_h
				var ct := img.get_pixel(x, sy_top)
				var cb := img.get_pixel(x, sy_bot)
				r_top += ct.r; g_top += ct.g; b_top += ct.b
				r_bot += cb.r; g_bot += cb.g; b_bot += cb.b
				count += 1
			img.set_pixel(x, i, Color(r_top / count, g_top / count, b_top / count, 1.0))
			img.set_pixel(x, total_h - 1 - i, Color(r_bot / count, g_bot / count, b_bot / count, 1.0))

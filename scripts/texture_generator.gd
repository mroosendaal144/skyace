extends Node2D

const W := 720
const H := 640
const OUT := "res://textures/backgrounds/"

var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.seed = 42
	_process_cloud_layer()
	print("=== Generating background textures ===")
	for level in range(1, 11):
		print("Level %d..." % level)
		_generate_level(level)
	print("=== Done! ===")
	get_tree().quit()

func _process_cloud_layer() -> void:
	var src_path := "res://textures/backgrounds/level_1_clouds.png"
	var dst_path := OUT + "bg_01_mid.png"
	var img := Image.new()
	if img.load(src_path) != OK:
		return
	print("Processing cloud layer %dx%d..." % [img.get_width(), img.get_height()])
	for y in img.get_height():
		for x in img.get_width():
			var c := img.get_pixel(x, y)
			var brightness := (c.r + c.g + c.b) / 3.0
			if brightness < 0.15:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
			else:
				var alpha := clampf((brightness - 0.15) / 0.35, 0.0, 1.0)
				alpha *= alpha
				img.set_pixel(x, y, Color(c.r, c.g, c.b, alpha * 0.5))
	img.save_png(dst_path)
	print("Cloud layer saved.")

func _generate_level(level: int) -> void:
	if level != 1:
		var far := _create_far(level)
		_make_tileable(far)
		far.save_png(OUT + "bg_%02d_far.png" % level)
		var mid := _create_mid(level)
		_make_tileable(mid)
		mid.save_png(OUT + "bg_%02d_mid.png" % level)
	var near := _create_near(level)
	_make_tileable(near)
	near.save_png(OUT + "bg_%02d_near.png" % level)

func _make_tileable(img: Image) -> void:
	var blend := 48
	for y in blend:
		var t := float(y) / float(blend)
		t = t * t * (3.0 - 2.0 * t)
		var from_y := H - blend + y
		for x in W:
			var cb := img.get_pixel(x, from_y)
			var ct := img.get_pixel(x, y)
			img.set_pixel(x, from_y, cb.lerp(ct, t))

# =============================================
# HELPERS
# =============================================

func _rf(lo: float, hi: float) -> float:
	return _rng.randf_range(lo, hi)

func _ri(lo: int, hi: int) -> int:
	return _rng.randi_range(lo, hi)

func _fill(img: Image, c: Color) -> void:
	img.fill(c)

func _rect(img: Image, x: int, y: int, w: int, h: int, c: Color) -> void:
	for dy in h:
		for dx in w:
			var px := x + dx
			var py := y + dy
			if px >= 0 and px < W and py >= 0 and py < H:
				if c.a >= 0.99:
					img.set_pixel(px, py, c)
				else:
					var ex := img.get_pixel(px, py)
					img.set_pixel(px, py, ex.lerp(Color(c.r, c.g, c.b, 1), c.a))

func _rect_alpha(img: Image, x: int, y: int, w: int, h: int, c: Color) -> void:
	for dy in h:
		for dx in w:
			var px := x + dx
			var py := y + dy
			if px >= 0 and px < W and py >= 0 and py < H:
				var ex := img.get_pixel(px, py)
				var a := c.a
				var inv := 1.0 - a
				img.set_pixel(px, py, Color(
					ex.r * inv + c.r * a,
					ex.g * inv + c.g * a,
					ex.b * inv + c.b * a,
					clampf(ex.a + a * (1.0 - ex.a), 0, 1)))

func _circle_solid(img: Image, cx: int, cy: int, r: int, c: Color) -> void:
	var r2 := r * r
	for dy in range(-r, r + 1):
		for dx in range(-r, r + 1):
			if dx * dx + dy * dy <= r2:
				var px := cx + dx
				var py := cy + dy
				if px >= 0 and px < W and py >= 0 and py < H:
					if c.a >= 0.99:
						img.set_pixel(px, py, c)
					else:
						_rect_alpha(img, px, py, 1, 1, c)

func _simple_cloud(img: Image, cx: int, cy: int, w: int, h: int, c: Color) -> void:
	_circle_solid(img, cx, cy, h, c)
	_circle_solid(img, cx - int(w * 0.3), cy + 2, int(h * 0.8), c)
	_circle_solid(img, cx + int(w * 0.3), cy + 1, int(h * 0.85), c)
	if w > 30:
		_circle_solid(img, cx - int(w * 0.45), cy + 3, int(h * 0.6), c)
		_circle_solid(img, cx + int(w * 0.45), cy + 2, int(h * 0.65), c)

func _draw_asteroid(img: Image, cx: int, cy: int, radius: int, body: Color, dark: Color, light: Color) -> void:
	_circle_solid(img, cx, cy, radius, body)
	for i in 5:
		var angle := TAU * float(i) / 5.0 + float(_ri(0, 100)) * 0.06
		var dist := radius * _rf(0.2, 0.6)
		var bump_x := cx + int(cos(angle) * dist)
		var bump_y := cy + int(sin(angle) * dist)
		_circle_solid(img, bump_x, bump_y, int(radius * _rf(0.3, 0.55)), body)
	_circle_solid(img, cx + radius / 3, cy + radius / 3, int(radius * 0.65), dark)
	_circle_solid(img, cx - radius / 4, cy - radius / 4, int(radius * 0.3), light)
	for i in _ri(1, 3):
		var ca := _rf(0, TAU)
		var cd := _rf(0.15, 0.5) * radius
		_circle_solid(img, cx + int(cos(ca) * cd), cy + int(sin(ca) * cd), _ri(2, maxi(3, radius / 5)), dark)

func _draw_ship_topdown(img: Image, cx: int, cy: int, length: int, width: int, hull: Color, detail: Color, engine: Color) -> void:
	_rect_alpha(img, cx - width / 2, cy, width, length, hull)
	for i in range(1, width / 3 + 1):
		var taper_w := width - i * 3
		if taper_w > 0:
			_rect_alpha(img, cx - taper_w / 2, cy - i * 2, taper_w, 2, hull)
	var bw := maxi(width / 3, 3)
	_rect_alpha(img, cx - bw / 2, cy + length / 4, bw, length / 5, detail)
	var eng_count := maxi(width / 6, 1)
	var eng_spacing := width / (eng_count + 1)
	for i in eng_count:
		var ex := cx - width / 2 + (i + 1) * eng_spacing
		_rect_alpha(img, ex - 1, cy + length, 2, 3, engine)
		_rect_alpha(img, ex, cy + length + 3, 1, 2, Color(engine.r, engine.g, engine.b, engine.a * 0.4))

# =============================================
# FAR LAYERS
# =============================================

func _create_far(level: int) -> Image:
	match level:
		1: return _far_ocean()
		2: return _far_city_night()
		3: return _far_city_dawn()
		4: return _far_shipyard()
		5: return _far_asteroid_field()
		6: return _far_lava()
		7: return _far_desert()
		8: return _far_space_fleet()
		9: return _far_underwater()
		10: return _far_cyber()
		_: return _far_ocean()

func _far_ocean() -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	var base := Color(0.10, 0.22, 0.48)
	_fill(img, base)
	var n1 := FastNoiseLite.new()
	n1.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	n1.frequency = 0.006
	n1.fractal_octaves = 3
	n1.seed = 42
	var n2 := FastNoiseLite.new()
	n2.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	n2.frequency = 0.012
	n2.fractal_octaves = 2
	n2.seed = 100
	var radius := float(H) / TAU
	for y in H:
		var angle := TAU * float(y) / float(H)
		var cy := sin(angle) * radius
		var cz := cos(angle) * radius
		for x in W:
			var v1 := n1.get_noise_3d(float(x), cy, cz) * 0.08
			var v2 := n2.get_noise_3d(float(x), cy, cz) * 0.04
			var r := clampf(base.r + v1 + v2, 0.04, 0.20)
			var g := clampf(base.g + v1 * 1.2 + v2, 0.12, 0.36)
			var b := clampf(base.b + v1 * 0.8 + v2 * 1.5, 0.30, 0.62)
			img.set_pixel(x, y, Color(r, g, b))
	return img

func _far_city_night() -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	_fill(img, Color(0.03, 0.03, 0.05))
	var road_c := Color(0.07, 0.07, 0.09)
	var mark_c := Color(0.18, 0.16, 0.06)
	var light_c := Color(0.85, 0.75, 0.30)
	var v_roads: Array[int] = []
	var x := _ri(50, 90)
	while x < W - 30:
		v_roads.append(x)
		x += _ri(90, 160)
	var h_roads: Array[int] = []
	var y := _ri(40, 70)
	while y < H - 30:
		h_roads.append(y)
		y += _ri(70, 130)
	for rx in v_roads:
		_rect(img, rx - 3, 0, 7, H, road_c)
		for ly in range(0, H, 14):
			_rect(img, rx, ly, 1, 7, mark_c)
		for ly in range(8, H, 35):
			if ly >= 0 and ly < H:
				_rect(img, clampi(rx - 4, 0, W - 1), ly, 1, 1, light_c)
				_rect(img, clampi(rx + 4, 0, W - 1), ly, 1, 1, light_c)
	for ry in h_roads:
		_rect(img, 0, ry - 3, W, 7, road_c)
		for lx in range(0, W, 14):
			_rect(img, lx, ry, 7, 1, mark_c)
		for lx in range(8, W, 35):
			if lx >= 0 and lx < W:
				_rect(img, lx, clampi(ry - 4, 0, H - 1), 1, 1, light_c)
				_rect(img, lx, clampi(ry + 4, 0, H - 1), 1, 1, light_c)
	for rx in v_roads:
		for ry in h_roads:
			_rect(img, rx - 4, ry - 4, 9, 9, road_c)
			_rect(img, rx - 1, ry - 1, 3, 3, Color(0.22, 0.20, 0.08))
	var all_v := v_roads.duplicate()
	all_v.insert(0, 0)
	all_v.append(W)
	var all_h := h_roads.duplicate()
	all_h.insert(0, 0)
	all_h.append(H)
	for bi in range(all_v.size() - 1):
		for bj in range(all_h.size() - 1):
			var bx1: int = int(all_v[bi]) + 5
			var bx2: int = int(all_v[bi + 1]) - 5
			var by1: int = int(all_h[bj]) + 5
			var by2: int = int(all_h[bj + 1]) - 5
			if bx2 - bx1 < 12 or by2 - by1 < 12:
				continue
			var roll := _rng.randf()
			if roll < 0.12:
				_fill_park(img, bx1, by1, bx2 - bx1, by2 - by1)
			elif roll < 0.20:
				_fill_parking(img, bx1, by1, bx2 - bx1, by2 - by1)
			else:
				_fill_buildings(img, bx1, by1, bx2 - bx1, by2 - by1)
			var side_y := _ri(by1 + 3, maxi(by1 + 4, by2 - 3))
			if bx2 - bx1 > 35:
				var alley_x := _ri(bx1 + 15, bx2 - 15)
				_rect(img, alley_x, by1, 2, by2 - by1, Color(0.055, 0.055, 0.07))
			if by2 - by1 > 35:
				var alley_y := _ri(by1 + 15, by2 - 15)
				_rect(img, bx1, alley_y, bx2 - bx1, 2, Color(0.055, 0.055, 0.07))
	return img

func _fill_park(img: Image, x: int, y: int, w: int, h: int) -> void:
	_rect(img, x, y, w, h, Color(0.04, 0.10, 0.03))
	var path_c := Color(0.08, 0.07, 0.06)
	_rect(img, x + w / 2 - 1, y, 2, h, path_c)
	_rect(img, x, y + h / 2 - 1, w, 2, path_c)
	for i in _ri(4, 8):
		var tx := _ri(x + 3, x + w - 4)
		var ty := _ri(y + 3, y + h - 4)
		_circle_solid(img, tx, ty, _ri(2, 4), Color(0.06, 0.14, 0.04))
		_circle_solid(img, tx, ty, 1, Color(0.08, 0.18, 0.06))

func _fill_parking(img: Image, x: int, y: int, w: int, h: int) -> void:
	_rect(img, x, y, w, h, Color(0.06, 0.06, 0.07))
	for row in range(y + 4, y + h - 6, 8):
		_rect(img, x + 2, row, w - 4, 1, Color(0.10, 0.10, 0.08))
		for col in range(x + 4, x + w - 4, 6):
			if _rng.randf() > 0.3:
				var car_c := Color(_rf(0.10, 0.22), _rf(0.10, 0.20), _rf(0.10, 0.22))
				_rect(img, col, row + 1, 3, 5, car_c)

func _fill_buildings(img: Image, x: int, y: int, w: int, h: int) -> void:
	var placed := 0
	var attempts := 0
	while placed < 6 and attempts < 20:
		attempts += 1
		var bw := _ri(maxi(8, w / 5), maxi(12, w / 2))
		var bh := _ri(maxi(8, h / 5), maxi(12, h / 2))
		var bx := _ri(x, x + w - bw)
		var by := _ri(y, y + h - bh)
		if bx + bw > x + w or by + bh > y + h:
			continue
		var shade := _rf(0.06, 0.14)
		var roof := Color(shade, shade, shade * 1.05)
		_rect(img, bx, by, bw, bh, roof)
		_rect(img, bx, by, bw, 1, Color(shade * 1.4, shade * 1.4, shade * 1.5))
		_rect(img, bx, by, 1, bh, Color(shade * 1.3, shade * 1.3, shade * 1.4))
		var wcols := (bw - 3) / 5
		var wrows := (bh - 3) / 5
		for wr in wrows:
			for wc in wcols:
				if _rng.randf() > 0.45:
					var wx := bx + 2 + wc * 5
					var wy := by + 2 + wr * 5
					var warm := _rng.randf()
					var wcolor: Color
					if warm > 0.7:
						wcolor = Color(0.80, 0.70, 0.22)
					elif warm > 0.4:
						wcolor = Color(0.55, 0.45, 0.15)
					else:
						wcolor = Color(0.25, 0.22, 0.10)
					_rect(img, wx, wy, 2, 2, wcolor)
		if _rng.randf() > 0.6:
			_rect(img, bx + bw / 2, by + bh / 2 - 2, 2, 4, Color(shade * 1.6, shade * 1.6, shade * 1.7))
		placed += 1

func _far_city_dawn() -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	_fill(img, Color(0.06, 0.05, 0.08))
	var road_c := Color(0.09, 0.08, 0.10)
	var mark_c := Color(0.20, 0.18, 0.10)
	var light_c := Color(0.80, 0.70, 0.35)
	var boulevard_c := Color(0.10, 0.09, 0.11)
	var v_roads: Array[int] = []
	var x := _ri(60, 100)
	while x < W - 40:
		v_roads.append(x)
		x += _ri(110, 180)
	var h_roads: Array[int] = []
	var y := _ri(50, 80)
	while y < H - 40:
		h_roads.append(y)
		y += _ri(90, 150)
	for rx in v_roads:
		var rw := 8 if _rng.randf() > 0.5 else 6
		_rect(img, rx - rw / 2, 0, rw, H, road_c)
		if rw >= 8:
			_rect(img, rx - rw / 2, 0, rw, H, boulevard_c)
			_rect(img, rx - 1, 0, 1, H, mark_c.lerp(Color.BLACK, 0.5))
			_rect(img, rx + 1, 0, 1, H, mark_c.lerp(Color.BLACK, 0.5))
		for ly in range(0, H, 14):
			_rect(img, rx, ly, 1, 7, mark_c)
		for ly in range(10, H, 30):
			_rect(img, clampi(rx - rw / 2 - 1, 0, W - 1), ly, 1, 1, light_c)
			_rect(img, clampi(rx + rw / 2 + 1, 0, W - 1), ly, 1, 1, light_c)
	for ry in h_roads:
		var rw := 8 if _rng.randf() > 0.5 else 6
		_rect(img, 0, ry - rw / 2, W, rw, road_c)
		if rw >= 8:
			_rect(img, 0, ry - rw / 2, W, rw, boulevard_c)
		for lx in range(0, W, 14):
			_rect(img, lx, ry, 7, 1, mark_c)
	var river_x := _ri(W / 3, 2 * W / 3)
	var river_w := _ri(20, 35)
	for y2 in H:
		var rx2 := river_x + int(sin(float(y2) * 0.008) * 40.0)
		var rw2 := river_w + int(sin(float(y2) * 0.015) * 5.0)
		for dx in rw2:
			var px := rx2 - rw2 / 2 + dx
			if px >= 0 and px < W:
				var edge_dist := absf(float(dx) / float(rw2) - 0.5) * 2.0
				if edge_dist < 0.85:
					img.set_pixel(px, y2, Color(0.06, 0.10, 0.20))
				else:
					img.set_pixel(px, y2, Color(0.08, 0.08, 0.10))
	for y2 in range(0, H, 60):
		var bx := river_x + int(sin(float(y2) * 0.008) * 40.0) - river_w / 2 - 4
		_rect(img, bx, y2, river_w + 8, 3, Color(0.12, 0.11, 0.12))
	var all_v := v_roads.duplicate()
	all_v.insert(0, 0)
	all_v.append(W)
	var all_h := h_roads.duplicate()
	all_h.insert(0, 0)
	all_h.append(H)
	for bi in range(all_v.size() - 1):
		for bj in range(all_h.size() - 1):
			var bx1: int = int(all_v[bi]) + 5
			var bx2: int = int(all_v[bi + 1]) - 5
			var by1: int = int(all_h[bj]) + 5
			var by2: int = int(all_h[bj + 1]) - 5
			if bx2 - bx1 < 14 or by2 - by1 < 14:
				continue
			var roll := _rng.randf()
			if roll < 0.08:
				_fill_park(img, bx1, by1, bx2 - bx1, by2 - by1)
			else:
				_fill_buildings_dawn(img, bx1, by1, bx2 - bx1, by2 - by1)
	return img

func _fill_buildings_dawn(img: Image, x: int, y: int, w: int, h: int) -> void:
	var placed := 0
	var attempts := 0
	while placed < 5 and attempts < 16:
		attempts += 1
		var bw := _ri(maxi(10, w / 4), maxi(14, w * 2 / 3))
		var bh := _ri(maxi(10, h / 4), maxi(14, h * 2 / 3))
		var bx := _ri(x, x + w - bw)
		var by := _ri(y, y + h - bh)
		if bx + bw > x + w or by + bh > y + h:
			continue
		var shade := _rf(0.09, 0.18)
		var roof := Color(shade, shade * 0.95, shade * 0.90)
		_rect(img, bx, by, bw, bh, roof)
		_rect(img, bx, by, bw, 1, Color(shade * 1.5, shade * 1.4, shade * 1.2))
		var wcols := (bw - 3) / 5
		var wrows := (bh - 3) / 5
		for wr in wrows:
			for wc in wcols:
				if _rng.randf() > 0.5:
					var wx := bx + 2 + wc * 5
					var wy := by + 2 + wr * 5
					var wcolor := Color(_rf(0.40, 0.65), _rf(0.35, 0.55), _rf(0.15, 0.30))
					_rect(img, wx, wy, 2, 2, wcolor)
		placed += 1

func _far_shipyard() -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	_fill(img, Color(0.02, 0.02, 0.04))
	for i in 150:
		img.set_pixel(_ri(0, W - 1), _ri(0, H - 1), Color(_rf(0.15, 0.5), _rf(0.15, 0.5), _rf(0.18, 0.55), 1))
	var platform_c := Color(0.08, 0.08, 0.10)
	var frame_c := Color(0.12, 0.12, 0.15)
	var panel_c := Color(0.06, 0.06, 0.08)
	var light_c := Color(0.70, 0.55, 0.15)
	var warn_c := Color(0.75, 0.20, 0.10)
	for i in 3:
		var px := _ri(30, W - 180)
		var py := _ri(20, H - 200)
		var pw := _ri(120, 200)
		var ph := _ri(140, 220)
		_rect(img, px, py, pw, ph, platform_c)
		_rect(img, px, py, pw, 2, frame_c)
		_rect(img, px, py + ph - 2, pw, 2, frame_c)
		_rect(img, px, py, 2, ph, frame_c)
		_rect(img, px + pw - 2, py, 2, ph, frame_c)
		var grid_sp := _ri(20, 30)
		for gx in range(px + grid_sp, px + pw, grid_sp):
			for gy in range(py, py + ph, 4):
				if gx >= 0 and gx < W and gy >= 0 and gy < H:
					img.set_pixel(gx, gy, frame_c)
		for gy in range(py + grid_sp, py + ph, grid_sp):
			for gx in range(px, px + pw, 4):
				if gx >= 0 and gx < W and gy >= 0 and gy < H:
					img.set_pixel(gx, gy, frame_c)
		for j in _ri(2, 4):
			var bx := _ri(px + 8, px + pw - 30)
			var by := _ri(py + 8, py + ph - 30)
			_rect(img, bx, by, _ri(15, 35), _ri(15, 35), panel_c)
		_rect(img, px + 2, py + 2, 2, 2, light_c)
		_rect(img, px + pw - 4, py + 2, 2, 2, light_c)
		_rect(img, px + 2, py + ph - 4, 2, 2, warn_c)
		_rect(img, px + pw - 4, py + ph - 4, 2, 2, warn_c)
	for i in 4:
		var cx := _ri(10, W - 60)
		var cy := _ri(10, H - 40)
		var arm_len := _ri(30, 60)
		var arm_dir := _ri(0, 1)
		if arm_dir == 0:
			_rect(img, cx, cy, arm_len, 2, frame_c)
			_rect(img, cx + arm_len - 2, cy - 6, 2, 14, frame_c)
		else:
			_rect(img, cx, cy, 2, arm_len, frame_c)
			_rect(img, cx - 6, cy + arm_len - 2, 14, 2, frame_c)
		_rect(img, cx - 1, cy - 1, 4, 4, Color(0.14, 0.14, 0.18))
	return img

func _far_asteroid_field() -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	_fill(img, Color(0.01, 0.01, 0.03))
	for i in 200:
		var b := _rf(0.15, 0.55)
		img.set_pixel(_ri(0, W - 1), _ri(0, H - 1), Color(b, b, b * 1.1, 1))
	for i in 25:
		img.set_pixel(_ri(0, W - 1), _ri(0, H - 1), Color(0.85, 0.85, 0.95, 1))
	var body := Color(0.30, 0.25, 0.18)
	var dark := Color(0.15, 0.12, 0.08)
	var light := Color(0.42, 0.38, 0.28)
	for i in 4:
		var cx := _ri(60, W - 60)
		var cy := _ri(60, H - 60)
		var r := _ri(35, 65)
		_draw_asteroid(img, cx, cy, r, body, dark, light)
	for i in 8:
		var cx := _ri(20, W - 20)
		var cy := _ri(20, H - 20)
		var r := _ri(10, 25)
		_draw_asteroid(img, cx, cy, r, body.darkened(0.15), dark, light.darkened(0.1))
	for i in 15:
		var cx := _ri(5, W - 5)
		var cy := _ri(5, H - 5)
		var r := _ri(3, 8)
		_circle_solid(img, cx, cy, r, Color(_rf(0.15, 0.25), _rf(0.12, 0.20), _rf(0.08, 0.15)))
	return img

func _far_lava() -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	var rock_dark := Color(0.05, 0.03, 0.02)
	var rock_mid := Color(0.10, 0.06, 0.04)
	var rock_light := Color(0.14, 0.08, 0.05)
	_fill(img, rock_dark)
	var n := FastNoiseLite.new()
	n.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	n.frequency = 0.004
	n.fractal_octaves = 4
	n.seed = 42
	for y in H:
		for x in W:
			var v := n.get_noise_2d(float(x), float(y)) * 0.5 + 0.5
			if v > 0.50:
				img.set_pixel(x, y, rock_mid)
			if v > 0.65:
				img.set_pixel(x, y, rock_light)
	var lava_paths: Array[Vector2] = []
	for i in 4:
		var start_x := _rf(100, W - 100)
		var cur_x := start_x
		for y in H:
			cur_x += sin(float(y) * 0.012 + float(i) * 2.5) * 1.5 + _rf(-0.5, 0.5)
			cur_x = clampf(cur_x, 20, W - 20)
			var river_w := 6 + int(sin(float(y) * 0.02 + float(i)) * 3.0)
			for dx in range(-river_w, river_w + 1):
				var px := int(cur_x) + dx
				if px >= 0 and px < W:
					var edge_dist := absf(float(dx)) / float(river_w)
					if edge_dist < 0.4:
						img.set_pixel(px, y, Color(1.0, 0.55, 0.10))
					elif edge_dist < 0.7:
						img.set_pixel(px, y, Color(0.85, 0.30, 0.05))
					else:
						img.set_pixel(px, y, Color(0.60, 0.15, 0.03))
	for i in 5:
		var cx := _ri(50, W - 50)
		var cy := _ri(50, H - 50)
		var r := _ri(12, 25)
		_circle_solid(img, cx, cy, r, rock_dark)
		_circle_solid(img, cx, cy, r - 3, Color(0.75, 0.25, 0.04))
		_circle_solid(img, cx, cy, r - 6, Color(0.95, 0.45, 0.08))
	return img

func _far_desert() -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	var sand_base := Color(0.60, 0.48, 0.26)
	var sand_light := Color(0.68, 0.56, 0.32)
	var sand_dark := Color(0.50, 0.40, 0.20)
	var sand_shadow := Color(0.42, 0.34, 0.16)
	_fill(img, sand_base)
	var n := FastNoiseLite.new()
	n.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	n.frequency = 0.004
	n.fractal_octaves = 3
	n.seed = 42
	for y in H:
		for x in W:
			var v := n.get_noise_2d(float(x), float(y)) * 0.5 + 0.5
			if v > 0.58:
				img.set_pixel(x, y, sand_light)
			elif v < 0.35:
				img.set_pixel(x, y, sand_dark)
	for wave_set in 5:
		var spacing := 18 + wave_set * 8
		var offset := wave_set * 50
		for base_y in range(0, H + spacing, spacing):
			for x in range(0, W, 2):
				var wy := base_y + int(sin(float(x + offset) * 0.018) * 3.0)
				if wy >= 0 and wy < H:
					img.set_pixel(x, wy, sand_shadow)
	var rock_c := Color(0.35, 0.28, 0.15)
	var rock_dark := Color(0.25, 0.20, 0.10)
	var n2 := FastNoiseLite.new()
	n2.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	n2.frequency = 0.006
	n2.fractal_octaves = 3
	n2.seed = 300
	for y in H:
		for x in W:
			var v := n2.get_noise_2d(float(x), float(y)) * 0.5 + 0.5
			if v > 0.72:
				img.set_pixel(x, y, rock_c)
			if v > 0.82:
				img.set_pixel(x, y, rock_dark)
	var river_x := _rf(200, W - 200)
	for y in H:
		river_x += sin(float(y) * 0.006) * 1.2 + _rf(-0.3, 0.3)
		var rw := 8 + int(sin(float(y) * 0.015) * 4.0)
		for dx in range(-rw, rw + 1):
			var px := int(river_x) + dx
			if px >= 0 and px < W:
				var edge := absf(float(dx)) / float(rw)
				if edge < 0.6:
					img.set_pixel(px, y, Color(0.48, 0.40, 0.22))
				else:
					img.set_pixel(px, y, sand_shadow)
	for i in 4:
		var rx := _ri(40, W - 60)
		var ry := _ri(40, H - 60)
		var rw := _ri(12, 28)
		var rh := _ri(10, 22)
		_rect(img, rx, ry, rw, rh, Color(0.38, 0.30, 0.18))
		_rect(img, rx + 1, ry + 1, rw - 2, 1, Color(0.45, 0.36, 0.22))
		if _rng.randf() > 0.5:
			_rect(img, rx + rw / 2 - 1, ry + rh / 2 - 1, 3, 3, Color(0.30, 0.24, 0.14))
	return img

func _far_space_fleet() -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	_fill(img, Color(0.01, 0.01, 0.03))
	for i in 200:
		var b := _rf(0.12, 0.50)
		img.set_pixel(_ri(0, W - 1), _ri(0, H - 1), Color(b, b, b * 1.1, 1))
	for i in 35:
		img.set_pixel(_ri(0, W - 1), _ri(0, H - 1), Color(0.80, 0.80, 0.90, 1))
	var n := FastNoiseLite.new()
	n.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	n.frequency = 0.003
	n.fractal_octaves = 3
	n.seed = 42
	for y in H:
		for x in W:
			var v := n.get_noise_2d(float(x), float(y)) * 0.5 + 0.5
			if v > 0.55:
				var t := (v - 0.55) / 0.45
				var ex := img.get_pixel(x, y)
				ex.r += t * t * 0.08
				ex.b += t * t * 0.15
				ex.g += t * t * 0.02
				img.set_pixel(x, y, Color(clampf(ex.r, 0, 1), clampf(ex.g, 0, 1), clampf(ex.b, 0, 1), 1))
	return img

func _far_underwater() -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	var deep := Color(0.02, 0.05, 0.14)
	var mid_c := Color(0.04, 0.08, 0.20)
	_fill(img, deep)
	var n := FastNoiseLite.new()
	n.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	n.frequency = 0.005
	n.fractal_octaves = 3
	n.seed = 42
	var n2 := FastNoiseLite.new()
	n2.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	n2.frequency = 0.008
	n2.fractal_octaves = 2
	n2.seed = 200
	for y in H:
		for x in W:
			var v := n.get_noise_2d(float(x), float(y)) * 0.5 + 0.5
			if v > 0.50:
				img.set_pixel(x, y, mid_c)
			if v > 0.65:
				img.set_pixel(x, y, Color(0.06, 0.12, 0.26))
	var sand_c := Color(0.18, 0.16, 0.10)
	var sand_light := Color(0.22, 0.20, 0.13)
	for y in H:
		for x in W:
			var v := n2.get_noise_2d(float(x), float(y)) * 0.5 + 0.5
			if v > 0.65:
				img.set_pixel(x, y, sand_c)
			if v > 0.75:
				img.set_pixel(x, y, sand_light)
	var trench_x := _rf(150, W - 150)
	for y in H:
		trench_x += sin(float(y) * 0.005) * 1.0 + _rf(-0.2, 0.2)
		var tw := 15 + int(sin(float(y) * 0.01) * 5.0)
		for dx in range(-tw, tw + 1):
			var px := int(trench_x) + dx
			if px >= 0 and px < W:
				var edge := absf(float(dx)) / float(tw)
				if edge < 0.5:
					img.set_pixel(px, y, Color(0.01, 0.02, 0.06))
				elif edge < 0.8:
					img.set_pixel(px, y, Color(0.02, 0.04, 0.10))
	for i in 6:
		var cx := _ri(30, W - 30)
		var cy := _ri(30, H - 30)
		var r := _ri(15, 35)
		_circle_solid(img, cx, cy, r, Color(0.12, 0.10, 0.07))
		_circle_solid(img, cx - 2, cy - 2, int(r * 0.5), Color(0.16, 0.13, 0.09))
	return img

func _far_cyber() -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	_fill(img, Color(0.02, 0.01, 0.04))
	var trace_c := Color(0.0, 0.10, 0.05)
	var trace_bright := Color(0.0, 0.20, 0.10)
	var node_c := Color(0.0, 0.35, 0.18)
	var node_glow := Color(0.0, 0.50, 0.25)
	var nodes: Array[Vector2i] = []
	for i in 25:
		nodes.append(Vector2i(_ri(20, W - 20), _ri(20, H - 20)))
	for i in nodes.size():
		var closest_dist := 99999.0
		var closest_j := -1
		for j in nodes.size():
			if i == j:
				continue
			var d := Vector2(nodes[i]).distance_to(Vector2(nodes[j]))
			if d < closest_dist:
				closest_dist = d
				closest_j = j
		if closest_j >= 0:
			var a := nodes[i]
			var b := nodes[closest_j]
			if absi(a.x - b.x) > absi(a.y - b.y):
				var mid_x := (a.x + b.x) / 2
				for x in range(mini(a.x, mid_x), maxi(a.x, mid_x) + 1):
					if x >= 0 and x < W and a.y >= 0 and a.y < H:
						img.set_pixel(x, a.y, trace_c)
				for y2 in range(mini(a.y, b.y), maxi(a.y, b.y) + 1):
					if mid_x >= 0 and mid_x < W and y2 >= 0 and y2 < H:
						img.set_pixel(mid_x, y2, trace_c)
				for x in range(mini(mid_x, b.x), maxi(mid_x, b.x) + 1):
					if x >= 0 and x < W and b.y >= 0 and b.y < H:
						img.set_pixel(x, b.y, trace_c)
			else:
				var mid_y := (a.y + b.y) / 2
				for y2 in range(mini(a.y, mid_y), maxi(a.y, mid_y) + 1):
					if a.x >= 0 and a.x < W and y2 >= 0 and y2 < H:
						img.set_pixel(a.x, y2, trace_c)
				for x in range(mini(a.x, b.x), maxi(a.x, b.x) + 1):
					if x >= 0 and x < W and mid_y >= 0 and mid_y < H:
						img.set_pixel(x, mid_y, trace_c)
				for y2 in range(mini(mid_y, b.y), maxi(mid_y, b.y) + 1):
					if b.x >= 0 and b.x < W and y2 >= 0 and y2 < H:
						img.set_pixel(b.x, y2, trace_c)
	for nd in nodes:
		_rect(img, nd.x - 2, nd.y - 2, 5, 5, node_c)
		_rect(img, nd.x - 1, nd.y - 1, 3, 3, node_glow)
		img.set_pixel(nd.x, nd.y, Color(0.0, 0.70, 0.35))
	for i in 8:
		var cx := _ri(30, W - 50)
		var cy := _ri(30, H - 50)
		var cw := _ri(15, 35)
		var ch := _ri(15, 35)
		_rect(img, cx, cy, cw, ch, Color(0.02, 0.03, 0.05))
		_rect(img, cx, cy, cw, 1, trace_c)
		_rect(img, cx, cy + ch, cw, 1, trace_c)
		_rect(img, cx, cy, 1, ch, trace_c)
		_rect(img, cx + cw, cy, 1, ch, trace_c)
		for dy in range(4, ch - 2, 4):
			for dx in range(3, cw - 2, 5):
				if _rng.randf() > 0.4:
					_rect(img, cx + dx, cy + dy, 2, 1, trace_bright)
	var n := FastNoiseLite.new()
	n.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	n.frequency = 0.006
	n.fractal_octaves = 2
	n.seed = 42
	for y in H:
		for x in W:
			var v := n.get_noise_2d(float(x), float(y)) * 0.5 + 0.5
			if v > 0.75:
				var ex := img.get_pixel(x, y)
				var glow := (v - 0.75) / 0.25
				img.set_pixel(x, y, Color(
					ex.r, clampf(ex.g + glow * 0.06, 0, 1),
					clampf(ex.b + glow * 0.02, 0, 1), 1))
	return img

# =============================================
# MID LAYERS
# =============================================

func _create_mid(level: int) -> Image:
	match level:
		1: return _mid_ocean_features()
		2: return _mid_city_buildings()
		3: return _mid_capital_skyscrapers()
		4: return _mid_shipyard_structures()
		5: return _mid_asteroids()
		6: return _mid_lava_rocks()
		7: return _mid_desert_features()
		8: return _mid_fleet_ships()
		9: return _mid_coral_reef()
		10: return _mid_cyber_data()
		_: return _mid_ocean_features()

func _mid_ocean_features() -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for i in 4:
		var sx := _ri(40, W - 50)
		var sy := _ri(40, H - 80)
		var ship_w := _ri(8, 14)
		var ship_h := _ri(28, 50)
		var grey := _rf(0.28, 0.42)
		var hull_c := Color(grey, grey, grey * 0.9, 0.50)
		_rect_alpha(img, sx, sy, ship_w, ship_h, hull_c)
		_rect_alpha(img, sx + 2, sy - 3, ship_w - 4, 3, hull_c)
		_rect_alpha(img, sx + 3, sy - 5, ship_w - 6, 2, hull_c)
		_rect_alpha(img, sx + 2, sy + ship_h / 3, ship_w - 4, 4, Color(grey * 1.3, grey * 1.3, grey * 1.2, 0.50))
		for w in range(1, 20):
			var wy := sy + ship_h + w * 3
			if wy < H:
				var wake_w := 1 + w / 4
				var wake_a := 0.12 * (1.0 - float(w) / 20.0)
				_rect_alpha(img, sx + ship_w / 2 - wake_w, wy, wake_w * 2, 1, Color(0.45, 0.55, 0.65, wake_a))
	for i in 3:
		var cx := _ri(40, W - 40)
		var cy := _ri(30, H - 30)
		_simple_cloud(img, cx, cy, _ri(50, 90), _ri(14, 22), Color(0.75, 0.80, 0.85, 0.25))
	return img

func _mid_city_buildings() -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for i in 10:
		var bw := _ri(20, 50)
		var bh := _ri(40, 140)
		var bx := _ri(5, W - bw - 5)
		var by := _ri(5, H - bh - 5)
		var shade := _rf(0.06, 0.11)
		_rect_alpha(img, bx, by, bw, bh, Color(shade, shade, shade * 1.1, 0.75))
		_rect_alpha(img, bx, by, bw, 1, Color(shade * 1.6, shade * 1.6, shade * 1.7, 0.60))
		_rect_alpha(img, bx + bw - 1, by, 1, bh, Color(shade * 0.5, shade * 0.5, shade * 0.6, 0.60))
		var wcols := (bw - 4) / 5
		var wrows := (bh - 4) / 5
		for wr in wrows:
			for wc in wcols:
				if _rng.randf() > 0.35:
					var wx := bx + 2 + wc * 5
					var wy := by + 2 + wr * 5
					var warm := _rng.randf()
					var wc2: Color
					if warm > 0.7:
						wc2 = Color(0.80, 0.68, 0.20, 0.55)
					elif warm > 0.4:
						wc2 = Color(0.55, 0.45, 0.14, 0.45)
					else:
						wc2 = Color(0.25, 0.20, 0.08, 0.30)
					_rect_alpha(img, wx, wy, 2, 3, wc2)
		if bh > 80 and _rng.randf() > 0.4:
			_rect_alpha(img, bx + bw / 2, by - 8, 2, 10, Color(0.15, 0.15, 0.18, 0.65))
			_rect_alpha(img, bx + bw / 2, by - 9, 1, 1, Color(0.9, 0.2, 0.15, 0.70))
	return img

func _mid_capital_skyscrapers() -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for i in 12:
		var bw := _ri(25, 60)
		var bh := _ri(50, 180)
		var bx := _ri(5, W - bw - 5)
		var by := _ri(5, H - bh - 5)
		var shade := _rf(0.08, 0.15)
		_rect_alpha(img, bx, by, bw, bh, Color(shade, shade * 0.95, shade * 0.92, 0.80))
		_rect_alpha(img, bx, by, bw, 2, Color(shade * 1.6, shade * 1.5, shade * 1.3, 0.65))
		var wcols := (bw - 4) / 5
		var wrows := (bh - 4) / 5
		for wr in wrows:
			for wc in wcols:
				if _rng.randf() > 0.40:
					var wx := bx + 2 + wc * 5
					var wy := by + 2 + wr * 5
					var wcolor := Color(_rf(0.40, 0.60), _rf(0.35, 0.50), _rf(0.15, 0.30), 0.50)
					_rect_alpha(img, wx, wy, 2, 3, wcolor)
		if bh > 100:
			_rect_alpha(img, bx + bw / 2, by - 12, 2, 14, Color(0.18, 0.17, 0.20, 0.70))
			_rect_alpha(img, bx + bw / 2, by - 13, 1, 1, Color(0.9, 0.2, 0.15, 0.75))
	return img

func _mid_shipyard_structures() -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for i in 3:
		var sx := _ri(30, W - 100)
		var sy := _ri(30, H - 120)
		var sw := _ri(50, 90)
		var sh := _ri(70, 120)
		var hull_c := Color(0.18, 0.18, 0.22, 0.60)
		_rect_alpha(img, sx, sy, sw, sh, hull_c)
		_rect_alpha(img, sx + sw / 4, sy - 6, sw / 2, 6, hull_c)
		var scaffold := Color(0.10, 0.10, 0.14, 0.40)
		for gx in range(sx - 8, sx + sw + 8, 12):
			_rect_alpha(img, gx, sy - 4, 1, sh + 8, scaffold)
		for gy in range(sy - 4, sy + sh + 4, 12):
			_rect_alpha(img, sx - 8, gy, sw + 16, 1, scaffold)
		for j in _ri(2, 4):
			var lx := _ri(sx + 3, sx + sw - 5)
			var ly := _ri(sy + 3, sy + sh - 5)
			_rect_alpha(img, lx, ly, 2, 2, Color(0.85, 0.55, 0.10, 0.55))
	for i in 5:
		var cx := _ri(10, W - 60)
		var cy := _ri(10, H - 10)
		var arm_len := _ri(25, 55)
		_rect_alpha(img, cx, cy, arm_len, 2, Color(0.14, 0.14, 0.18, 0.50))
		_rect_alpha(img, cx + arm_len - 1, cy - 4, 2, 10, Color(0.14, 0.14, 0.18, 0.50))
		_rect_alpha(img, cx - 1, cy - 1, 3, 4, Color(0.20, 0.18, 0.12, 0.50))
	return img

func _mid_asteroids() -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for i in 10:
		var cx := _ri(15, W - 15)
		var cy := _ri(15, H - 15)
		var r := _ri(6, 18)
		var shade := _rf(0.18, 0.30)
		_circle_solid(img, cx, cy, r, Color(shade, shade * 0.85, shade * 0.65, 0.65))
		_circle_solid(img, cx + r / 3, cy + r / 3, int(r * 0.55), Color(shade * 0.6, shade * 0.5, shade * 0.35, 0.50))
		_circle_solid(img, cx - r / 4, cy - r / 4, int(r * 0.3), Color(shade * 1.3, shade * 1.1, shade * 0.8, 0.45))
	for i in 40:
		var sx := _ri(0, W - 1)
		var sy := _ri(0, H - 1)
		var b := _rf(0.20, 0.50)
		img.set_pixel(sx, sy, Color(b, b * 0.85, b * 0.65, 0.65))
	return img

func _mid_lava_rocks() -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for i in 8:
		var cx := _ri(15, W - 15)
		var cy := _ri(15, H - 15)
		var r := _ri(10, 28)
		var shade := _rf(0.08, 0.14)
		_circle_solid(img, cx, cy, r, Color(shade, shade * 0.45, shade * 0.15, 0.55))
		_circle_solid(img, cx + 2, cy + 2, int(r * 0.6), Color(shade * 0.5, shade * 0.2, shade * 0.08, 0.40))
		_circle_solid(img, cx, cy, int(r * 0.25), Color(0.65, 0.20, 0.04, 0.30))
	for i in 6:
		var sx := _ri(10, W - 10)
		var sy := _ri(10, H - 10)
		var len := _ri(15, 40)
		for l in len:
			var px := sx + int(sin(float(l) * 0.3 + float(i)) * 3.0)
			var py := sy + l
			if px >= 0 and px < W and py >= 0 and py < H:
				_rect_alpha(img, px, py, 2, 1, Color(0.80, 0.25, 0.04, 0.15))
	return img

func _mid_desert_features() -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for i in 6:
		var cx := _ri(20, W - 30)
		var cy := _ri(20, H - 30)
		var r := _ri(12, 30)
		var shade := _rf(0.32, 0.42)
		_circle_solid(img, cx, cy, r, Color(shade, shade * 0.82, shade * 0.55, 0.45))
		_circle_solid(img, cx - 2, cy - 2, int(r * 0.5), Color(shade * 1.2, shade, shade * 0.7, 0.35))
		_circle_solid(img, cx + r / 3, cy + r / 3, int(r * 0.4), Color(shade * 0.7, shade * 0.55, shade * 0.35, 0.40))
	for i in 3:
		var rx := _ri(20, W - 40)
		var ry := _ri(20, H - 40)
		var rw := _ri(14, 30)
		var rh := _ri(10, 22)
		_rect_alpha(img, rx, ry, rw, rh, Color(0.38, 0.30, 0.18, 0.40))
		_rect_alpha(img, rx + 1, ry + 1, rw - 2, 1, Color(0.45, 0.36, 0.22, 0.35))
		_rect_alpha(img, rx + 2, ry + 3, rw / 3, rh / 3, Color(0.28, 0.22, 0.14, 0.30))
		if _rng.randf() > 0.5:
			_rect_alpha(img, rx + rw / 2 - 1, ry - 4, 2, 6, Color(0.35, 0.28, 0.18, 0.40))
	for i in 4:
		var base_y := _ri(40, H - 40)
		var shade := _rf(0.48, 0.55)
		for x in W:
			var wy := base_y + int(sin(float(x) * 0.012 + float(i) * 1.8) * 12.0)
			var dune_h := _ri(6, 14)
			for dy in dune_h:
				var py := wy + dy
				if py >= 0 and py < H:
					var a := (1.0 - float(dy) / float(dune_h)) * 0.20
					_rect_alpha(img, x, py, 1, 1, Color(shade, shade * 0.85, shade * 0.45, a))
	return img

func _mid_fleet_ships() -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for i in 2:
		var cx := _ri(100, W - 100)
		var cy := _ri(60, H - 150)
		var length := _ri(80, 130)
		var width := _ri(25, 40)
		_draw_ship_topdown(img, cx, cy, length, width,
			Color(0.20, 0.20, 0.25, 0.55),
			Color(0.25, 0.25, 0.30, 0.50),
			Color(0.30, 0.50, 0.90, 0.60))
	for i in 5:
		var cx := _ri(30, W - 30)
		var cy := _ri(30, H - 80)
		var length := _ri(25, 45)
		var width := _ri(8, 16)
		_draw_ship_topdown(img, cx, cy, length, width,
			Color(0.18, 0.18, 0.22, 0.45),
			Color(0.22, 0.22, 0.26, 0.40),
			Color(0.25, 0.45, 0.80, 0.50))
	for i in 12:
		var fx := _ri(10, W - 10)
		var fy := _ri(10, H - 10)
		_rect_alpha(img, fx, fy, 2, 4, Color(0.15, 0.15, 0.20, 0.40))
		_rect_alpha(img, fx, fy + 4, 1, 2, Color(0.20, 0.40, 0.70, 0.35))
	return img

func _mid_coral_reef() -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var coral_colors := [
		Color(0.55, 0.20, 0.25, 0.40),
		Color(0.60, 0.40, 0.15, 0.40),
		Color(0.25, 0.50, 0.35, 0.40),
		Color(0.50, 0.25, 0.50, 0.40),
		Color(0.55, 0.50, 0.20, 0.40),
	]
	for i in 8:
		var cx := _ri(20, W - 20)
		var cy := _ri(20, H - 20)
		var cc: Color = coral_colors[_ri(0, coral_colors.size() - 1)]
		for j in _ri(3, 6):
			var bx := cx + _ri(-12, 12)
			var by := cy + _ri(-12, 12)
			_circle_solid(img, bx, by, _ri(4, 10), cc)
		_circle_solid(img, cx, cy, _ri(3, 6), Color(cc.r * 1.3, cc.g * 1.3, cc.b * 1.3, cc.a * 0.8))
	for i in 7:
		var base_x := _ri(20, W - 20)
		var base_y := _ri(int(H * 0.3), H - 10)
		var height := _ri(40, 100)
		var green := _rf(0.20, 0.40)
		for seg in range(0, height, 3):
			var sy := base_y - seg
			if sy < 0:
				break
			var sway := int(sin(float(seg) * 0.08 + float(i) * 1.5) * 8.0)
			var sx := base_x + sway
			var a := 0.25 * (1.0 - float(seg) / float(height))
			_rect_alpha(img, sx - 1, sy, 3, 3, Color(0.10, green, 0.08, a))
	for i in 10:
		var fx := _ri(5, W - 5)
		var fy := _ri(5, H - 5)
		_circle_solid(img, fx, fy, _ri(2, 5), Color(0.25, 0.45, 0.60, 0.15))
	return img

func _mid_cyber_data() -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for i in 12:
		var sx := _ri(0, W - 1)
		var sy := _ri(0, H - 80)
		var length := _ri(30, 80)
		var hue := _rng.randf()
		var stream_c: Color
		if hue < 0.5:
			stream_c = Color(0.0, 0.45, 0.22, 0.18)
		else:
			stream_c = Color(0.0, 0.22, 0.45, 0.18)
		for l in length:
			if sy + l < H:
				var bright := 0.5 + sin(float(l) * 0.3) * 0.5
				_rect_alpha(img, sx, sy + l, 1, 1, Color(stream_c.r, stream_c.g * bright, stream_c.b * bright, stream_c.a))
	for i in 10:
		var cx := _ri(30, W - 30)
		var cy := _ri(30, H - 30)
		_circle_solid(img, cx, cy, _ri(10, 22), Color(0.0, 0.35, 0.18, 0.06))
		_rect_alpha(img, cx - 1, cy - 1, 3, 3, Color(0.0, 0.65, 0.32, 0.35))
	for i in 4:
		var hx := _ri(20, W - 40)
		var hy := _ri(20, H - 30)
		var hw := _ri(10, 25)
		var hh := _ri(8, 18)
		_rect_alpha(img, hx, hy, hw, hh, Color(0.0, 0.30, 0.15, 0.08))
		_rect_alpha(img, hx, hy, hw, 1, Color(0.0, 0.50, 0.25, 0.20))
		_rect_alpha(img, hx, hy + hh, hw, 1, Color(0.0, 0.50, 0.25, 0.20))
		_rect_alpha(img, hx, hy, 1, hh, Color(0.0, 0.50, 0.25, 0.20))
		_rect_alpha(img, hx + hw, hy, 1, hh, Color(0.0, 0.50, 0.25, 0.20))
	return img

# =============================================
# NEAR LAYERS
# =============================================

func _create_near(level: int) -> Image:
	match level:
		1: return _near_clouds_high()
		2: return _near_smog()
		3: return _near_mist()
		4: return _near_sparks()
		5: return _near_streaks()
		6: return _near_smoke()
		7: return _near_sand_particles()
		8: return _near_exhaust()
		9: return _near_bubbles()
		10: return _near_scan_lines()
		_: return _near_clouds_high()

func _near_clouds_high() -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for i in 4:
		var cx := _ri(30, W - 30)
		var cy := _ri(30, H - 30)
		_simple_cloud(img, cx, cy, _ri(60, 120), _ri(18, 30), Color(0.88, 0.90, 0.94, 0.35))
	return img

func _near_smog() -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for i in 4:
		var cx := _ri(40, W - 40)
		var cy := _ri(40, H - 40)
		_simple_cloud(img, cx, cy, _ri(70, 140), _ri(14, 24), Color(0.22, 0.20, 0.16, 0.10))
	return img

func _near_mist() -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for i in 3:
		var cx := _ri(50, W - 50)
		var cy := _ri(50, H - 50)
		_simple_cloud(img, cx, cy, _ri(100, 180), _ri(20, 35), Color(0.55, 0.48, 0.40, 0.07))
	return img

func _near_sparks() -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for i in 6:
		var cx := _ri(5, W - 5)
		var cy := _ri(5, H - 5)
		var r := _ri(2, 5)
		_circle_solid(img, cx, cy, r, Color(_rf(0.12, 0.22), _rf(0.10, 0.18), _rf(0.08, 0.14), 0.50))
	for i in 15:
		var sx := _ri(0, W - 1)
		var sy := _ri(0, H - 1)
		_rect_alpha(img, sx, sy, 1, 1, Color(0.90, 0.70, 0.20, 0.55))
	for i in 8:
		var sx := _ri(0, W - 1)
		var sy := _ri(0, H - 1)
		_rect_alpha(img, sx, sy, 1, 1, Color(0.95, 0.85, 0.40, 0.65))
	return img

func _near_streaks() -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for i in 10:
		var sx := _ri(0, W - 1)
		var sy := _ri(0, H - 80)
		var length := _ri(20, 60)
		var b := _rf(0.30, 0.65)
		for l in length:
			if sy + l < H:
				_rect_alpha(img, sx, sy + l, 1, 1, Color(b, b, b * 1.1, 0.40))
	return img

func _near_smoke() -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for i in 5:
		var cx := _ri(40, W - 40)
		var cy := _ri(40, H - 40)
		_simple_cloud(img, cx, cy, _ri(50, 100), _ri(14, 24), Color(0.18, 0.12, 0.08, 0.15))
	return img

func _near_sand_particles() -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for i in 35:
		img.set_pixel(_ri(0, W - 1), _ri(0, H - 1), Color(0.68, 0.58, 0.28, 0.28))
	for i in 2:
		var cx := _ri(60, W - 60)
		var cy := _ri(60, H - 60)
		_simple_cloud(img, cx, cy, _ri(80, 140), _ri(15, 25), Color(0.55, 0.45, 0.22, 0.05))
	return img

func _near_exhaust() -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for i in 3:
		var cx := _ri(50, W - 50)
		var cy := _ri(50, H - 50)
		_simple_cloud(img, cx, cy, _ri(40, 80), _ri(10, 18), Color(0.30, 0.35, 0.50, 0.06))
	for i in 6:
		var sx := _ri(0, W - 1)
		var sy := _ri(0, H - 60)
		var length := _ri(15, 40)
		var b := _rf(0.25, 0.55)
		for l in length:
			if sy + l < H:
				_rect_alpha(img, sx, sy + l, 1, 1, Color(b, b, b * 1.1, 0.35))
	return img

func _near_bubbles() -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for i in 4:
		var rx := _ri(40, W - 40)
		var ry := _ri(0, H - 120)
		var ray_w := _ri(20, 40)
		var ray_h := _ri(150, 300)
		for dy in ray_h:
			var py := ry + dy
			if py >= H:
				break
			var fade := 1.0 - float(dy) / float(ray_h)
			for dx in ray_w:
				var px := rx - ray_w / 2 + dx
				if px >= 0 and px < W:
					var edge := 1.0 - absf(float(dx) / float(ray_w) - 0.5) * 2.0
					var a := 0.04 * fade * maxf(edge, 0.0)
					_rect_alpha(img, px, py, 1, 1, Color(0.20, 0.45, 0.65, a))
	for i in 18:
		var bx := _ri(5, W - 5)
		var by := _ri(5, H - 5)
		var br := _ri(2, 5)
		_circle_solid(img, bx, by, br, Color(0.35, 0.60, 0.80, 0.12))
		if br > 2:
			_rect_alpha(img, bx - 1, by - 1, 1, 1, Color(0.55, 0.80, 0.95, 0.18))
	return img

func _near_scan_lines() -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for i in 10:
		var sx := _ri(0, W - 1)
		var sy := _ri(0, H - 60)
		var length := _ri(25, 65)
		var b := _rf(0.30, 0.65)
		for l in length:
			if sy + l < H:
				_rect_alpha(img, sx, sy + l, _ri(1, 2), 1, Color(0.0, b, b * 0.5, 0.45))
	for i in 4:
		var ly := _ri(0, H - 1)
		var lw := _ri(40, 100)
		var lx := _ri(30, W - lw - 30)
		for dx in lw:
			_rect_alpha(img, lx + dx, ly, 1, 1, Color(0.0, 0.55, 0.28, 0.05))
	return img

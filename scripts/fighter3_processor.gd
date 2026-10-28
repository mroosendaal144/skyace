extends Node2D

const THRESHOLD := 0.10

func _ready() -> void:
	_process_sprite("res://fighter-png/fighter3_start_64.png", "res://fighter-png/fighter3_64.png", 64)
	print("Fighter 3 processed.")
	get_tree().quit()

func _process_sprite(src: String, dst: String, target_size: int) -> void:
	var img := Image.new()
	if img.load(src) != OK:
		print("Failed to load: ", src)
		return

	img.convert(Image.FORMAT_RGBA8)
	var ow := img.get_width()
	var oh := img.get_height()
	print("Source: ", src, " ", ow, "x", oh)

	var aspect := float(ow) / float(oh)
	var tw: int
	var th: int
	if aspect >= 1.0:
		tw = target_size
		th = int(target_size / aspect)
	else:
		th = target_size
		tw = int(target_size * aspect)

	img.resize(tw, th, Image.INTERPOLATE_LANCZOS)
	print("  Scaled to: ", tw, "x", th)

	var removed := _flood_fill_remove(img)
	print("  Removed ", removed, " background pixels")

	img.save_png(dst)
	print("  Saved: ", dst)

func _flood_fill_remove(img: Image) -> int:
	var w := img.get_width()
	var h := img.get_height()

	var visited := PackedByteArray()
	visited.resize(w * h)
	visited.fill(0)

	var queue: Array[Vector2i] = []
	for x in w:
		queue.append(Vector2i(x, 0))
		queue.append(Vector2i(x, h - 1))
	for y in h:
		queue.append(Vector2i(0, y))
		queue.append(Vector2i(w - 1, y))

	var dirs: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	var removed := 0

	while queue.size() > 0:
		var p: Vector2i = queue.pop_back()
		if p.x < 0 or p.x >= w or p.y < 0 or p.y >= h:
			continue
		var idx: int = p.y * w + p.x
		if visited[idx]:
			continue
		visited[idx] = 1
		var c := img.get_pixel(p.x, p.y)
		var brightness := c.r * 0.299 + c.g * 0.587 + c.b * 0.114
		if brightness < THRESHOLD:
			img.set_pixel(p.x, p.y, Color(0, 0, 0, 0))
			removed += 1
			for d in dirs:
				var np: Vector2i = p + d
				if np.x >= 0 and np.x < w and np.y >= 0 and np.y < h:
					var ni: int = np.y * w + np.x
					if not visited[ni]:
						queue.append(np)
	return removed
